## =============================================================================
## GBD 2021 Meningitis — BAPC Hindcast  (v4-H07-RW2, SELF-CONTAINED, CHECKPOINTED)
## -----------------------------------------------------------------------------
## ONE training window / forecast horizon
##   H07 : train 1990-2014 -> predict 2015-2021  (7 y)
##
## LOCATION SETS
##   Deaths    : Global + all 21 GBD regions                        (22)
##   Incidence : Global + all 21 GBD regions                        (22)
##   YLDs      : Global + all 21 GBD regions                        (22)
##
## Prior
##   RW2 only
##
## Sex "Both" | Focus age "<5 years" | plus age-standardised rate
##
## OUTPUT FORMAT
##   measure, location, sex, year, age, cause, location_id, cmlsa, metric,
##   pointdata, mean, startpred_postion,
##   x_0.025Q, x_0.05Q, x_0.1Q, ... , x_0.95Q, x_0.975Q
##   (+ horizon, prior, train_period, pred_period, is_pred, lead)
##   Rows cover ALL years 1990-2021: fitted values for the training period
##   (retro = TRUE) and projections thereafter.
##
## FIXES CARRIED OVER
##   [F1] INLA 24.x rejects non-integer Poisson responses -> counts rounded
##   [F2] agespec.proj() returns COUNTS -> rate = count / population * 1e5
##   [F3] agestd.proj() is scaled by total population -> PER-YEAR calibration
##   [F4] Quantile column names taken literally, verified at run time
##   [F5] Model list derived from BAPC's own defaults
##   [F6] Per-fit checkpointing: nothing is lost if the session dies
## =============================================================================

library(data.table)
library(readxl)
library(INLA)
library(BAPC)

inla.setOption(inla.mode   = "classic")
inla.setOption(num.threads = "1:1")
inla.setOption(safe        = TRUE)

## =============================================================================
## 1. CONFIGURATION
## =============================================================================
DP       <- "C:/Users/Rensh/AppData/Local/R/win-library/4.4/gR/data"
OUT_DIR  <- "C:/BAPC_hindcast_out"

## Dedicated checkpoint directory for H07 + RW2 only.
## This prevents old H10/H15/RW1 checkpoints from being assembled accidentally.
CKPT_DIR <- file.path(OUT_DIR, "ckpt_H07_RW2")

dir.create(OUT_DIR,  showWarnings = FALSE, recursive = TRUE)
dir.create(CKPT_DIR, showWarnings = FALSE, recursive = TRUE)

stopifnot(exists("df0"))

SEX          <- "Both"
CAUSE        <- "Meningitis"
FOCUS_AGE    <- "<5 years"
METRIC_LABEL <- "Rate (per 100,000)"
RATE_SCALE   <- 1e5

## RW2 only
PRIORS       <- c("rw2")

ROUND_COUNTS <- TRUE
YEAR_START   <- 1990
YEAR_END     <- 2021
ALL_YEARS    <- YEAR_START:YEAR_END
ALL_YEARS_CH <- as.character(ALL_YEARS)

## H07 only
HORIZONS <- list(
    H07 = list(label = "train1990-2014_pred2015-2021", train_end = 2014, npredict = 7)
)

REGION21 <- c(
    "East Asia", "Southeast Asia", "Oceania",
    "Central Asia", "Central Europe", "Eastern Europe",
    "High-income Asia Pacific", "Australasia", "Western Europe",
    "Southern Latin America", "High-income North America",
    "Caribbean", "Andean Latin America", "Central Latin America",
    "Tropical Latin America", "North Africa and Middle East", "South Asia",
    "Central Sub-Saharan Africa", "Eastern Sub-Saharan Africa",
    "Southern Sub-Saharan Africa", "Western Sub-Saharan Africa")
stopifnot(length(REGION21) == 21)

LOC_FULL <- c("Global", REGION21)

MEASURE_LOCS <- list(
    Deaths    = LOC_FULL,
    Incidence = LOC_FULL,
    YLDs      = LOC_FULL
)

MEASURES <- names(MEASURE_LOCS)
ALL_LOCS <- unique(unlist(MEASURE_LOCS))

AGE20 <- c("<5 years", "5-9 years", "10-14 years", "15-19 years", "20-24 years",
           "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years",
           "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70-74 years",
           "75-79 years", "80-84 years", "85-89 years", "90-94 years", "95+ years")

## --- Full percentile grid -----------------------------------------------------
QS   <- c(0.025, seq(0.05, 0.95, by = 0.05), 0.975)
QNM  <- paste0(as.character(QS), "Q")
QOUT <- paste0("x_", QNM)

## =============================================================================
## 2. STANDARD WEIGHTS (WHO 2000; 95-99 + 100+ collapsed into "95+")
## =============================================================================
who_raw <- read_excel(file.path(DP, "who2000standardpop.xlsx"))
names(who_raw)[1:2] <- c("AgeGroup", "Weight")
who_raw$Weight <- as.numeric(who_raw$Weight)
w_map <- setNames(who_raw$Weight, who_raw$AgeGroup)

wstd_raw <- c(w_map[["0-4"]],   w_map[["5-9"]],   w_map[["10-14"]], w_map[["15-19"]],
              w_map[["20-24"]], w_map[["25-29"]], w_map[["30-34"]], w_map[["35-39"]],
              w_map[["40-44"]], w_map[["45-49"]], w_map[["50-54"]], w_map[["55-59"]],
              w_map[["60-64"]], w_map[["65-69"]], w_map[["70-74"]], w_map[["75-79"]],
              w_map[["80-84"]], w_map[["85-89"]], w_map[["90-94"]],
              w_map[["95-99"]] + w_map[["100+"]])
names(wstd_raw) <- AGE20
WSTD <- wstd_raw / sum(wstd_raw)
stopifnot(length(WSTD) == 20, abs(sum(WSTD) - 1) < 1e-10)

## =============================================================================
## 3. NUMERATOR / DENOMINATOR / LOCATION IDS
## =============================================================================
dt_num <- as.data.table(df0)[
    sex == SEX & metric == "Number" & measure %in% MEASURES &
        age %in% AGE20 & location %in% ALL_LOCS &
        year >= YEAR_START & year <= YEAR_END,
    .(location, measure, year, age, count = val)]

gp      <- fread(file.path(DP, "gbd_population.txt"))
loc_key <- unique(as.data.table(df0)[location %in% ALL_LOCS, .(location_id, location)])
LOC_ID  <- setNames(loc_key$location_id, loc_key$location)

dt_pop <- merge(
    gp[sex == SEX & age %in% AGE20 & year >= YEAR_START & year <= YEAR_END,
       .(location_id, year, age, pop)],
    loc_key, by = "location_id")[, .(location, year, age, pop)]

## --- GBD official rates, kept for independent validation ----------------------
dt_rate_gbd <- as.data.table(df0)[
    sex == SEX & metric == "Rate" & measure %in% MEASURES &
        age == FOCUS_AGE & location %in% ALL_LOCS &
        year >= YEAR_START & year <= YEAR_END,
    .(location, measure, year, gbd_rate = val)]

## =============================================================================
## 4. PRE-FLIGHT
## =============================================================================
preflight <- function() {
    cat("\n===== PRE-FLIGHT =====\n")
    need <- length(AGE20) * length(ALL_YEARS)
    bad <- FALSE
    
    for (L in ALL_LOCS) {
        n <- nrow(dt_pop[location == L])
        if (n != need) {
            cat(sprintf("  !! %-30s pop rows %d (need %d)\n", L, n, need))
            bad <- TRUE
        }
    }
    
    for (meas in MEASURES) {
        for (L in MEASURE_LOCS[[meas]]) {
            n <- nrow(dt_num[measure == meas & location == L])
            if (n != need) {
                cat(sprintf("  !! %-10s %-30s count rows %d (need %d)\n",
                            meas, L, n, need))
                bad <- TRUE
            }
        }
    }
    
    if (!bad) cat("  All location x measure blocks complete.\n")
    
    miss_id <- setdiff(ALL_LOCS, names(LOC_ID))
    if (length(miss_id)) {
        cat("  !! location_id missing for:",
            paste(miss_id, collapse = ", "), "\n")
    }
    
    chk <- merge(
        dt_rate_gbd[measure == "Deaths" & location == "Global", .(year, gbd_rate)],
        merge(dt_num[measure == "Deaths" & age == FOCUS_AGE & location == "Global"],
              dt_pop[age == FOCUS_AGE & location == "Global"],
              by = c("location", "year", "age"))[, .(year, my_rate = count / pop * 1e5)],
        by = "year")
    
    cat("  Rate reconstruction median ratio (want 1.000):",
        round(median(chk$my_rate / chk$gbd_rate), 5), "\n")
    
    z <- dt_num[count < 0.5]
    cat(sprintf("  Cells rounded to zero: %d / %d (%.3f%%)\n",
                nrow(z), nrow(dt_num), 100 * nrow(z) / nrow(dt_num)))
    
    if (nrow(z)) {
        cat("  Affected age groups:", paste(unique(z$age), collapse = ", "), "\n")
        cat("  FOCUS_AGE affected? ",
            ifelse(FOCUS_AGE %in% unique(z$age), "YES - INVESTIGATE", "NO"), "\n")
    }
    
    cat("======================\n\n")
}
preflight()

## =============================================================================
## 5. HELPERS
## =============================================================================
make_mats <- function(loc, meas, train_end) {
    cw <- as.data.frame(dcast(dt_num[location == loc & measure == meas],
                              year ~ age, value.var = "count"))
    pw <- as.data.frame(dcast(dt_pop[location == loc],
                              year ~ age, value.var = "pop"))
    
    rownames(cw) <- cw$year
    cw$year <- NULL
    
    rownames(pw) <- pw$year
    pw$year <- NULL
    
    cw <- cw[ALL_YEARS_CH, AGE20, drop = FALSE]
    pw <- pw[ALL_YEARS_CH, AGE20, drop = FALSE]
    
    if (anyNA(pw)) stop(sprintf("Population NA: %s", loc))
    if (anyNA(cw)) stop(sprintf("Counts NA before masking: %s / %s", loc, meas))
    
    if (ROUND_COUNTS) cw <- round(cw)
    
    obs <- cw
    cw[as.character((train_end + 1):YEAR_END), ] <- NA
    
    list(cases = cw, pop = pw, obs = obs)
}

make_model_safe <- function(rw = "rw2") {
    def <- eval(formals(BAPC)$model)
    def$age$model    <- rw
    def$period$model <- rw
    def$cohort$model <- rw
    def
}

get_mat <- function(mm) {
    mm <- as.matrix(mm)
    rn <- rownames(mm)
    
    if (!is.null(rn) && all(ALL_YEARS_CH %in% rn)) {
        return(mm[ALL_YEARS_CH, , drop = FALSE])
    }
    
    if (nrow(mm) == length(ALL_YEARS)) {
        rownames(mm) <- ALL_YEARS_CH
        return(mm)
    }
    
    stop("Unexpected row count from BAPC: ", nrow(mm))
}

check_qcols <- function(mm) {
    miss <- setdiff(c("mean", QNM), colnames(mm))
    if (length(miss)) {
        stop("Missing columns: ", paste(miss, collapse = ", "),
             " | available: ", paste(colnames(mm), collapse = ", "))
    }
    invisible(TRUE)
}

build_block <- function(mm, scale_vec, pointdata, loc, meas, age_lab, hz, rw) {
    check_qcols(mm)
    
    q <- mm[, QNM, drop = FALSE] * scale_vec
    colnames(q) <- QOUT
    
    dt <- data.table(
        measure           = meas,
        location          = loc,
        sex               = SEX,
        year              = ALL_YEARS,
        age               = age_lab,
        cause             = CAUSE,
        location_id       = unname(LOC_ID[loc]),
        cmlsa             = paste(CAUSE, meas, loc, SEX, age_lab, sep = " | "),
        metric            = METRIC_LABEL,
        pointdata         = as.numeric(pointdata),
        mean              = as.numeric(mm[, "mean"] * scale_vec),
        startpred_postion = hz$train_end + 1L,
        horizon           = hz$label,
        prior             = toupper(rw),
        train_period      = paste0(YEAR_START, "-", hz$train_end),
        pred_period       = paste0(hz$train_end + 1, "-", YEAR_END),
        is_pred           = ALL_YEARS > hz$train_end,
        lead              = pmax(ALL_YEARS - hz$train_end, 0L)
    )
    
    cbind(dt, as.data.table(q))
}

## =============================================================================
## 6. CORE FIT
## =============================================================================
fit_one <- function(loc, meas, hz, rw) {
    m   <- make_mats(loc, meas, hz$train_end)
    apc <- APCList(m$cases, m$pop, gf = 5)
    
    res <- BAPC(
        apc,
        predict    = list(npredict = hz$npredict, retro = TRUE),
        model      = make_model_safe(rw),
        secondDiff = FALSE,
        stdweight  = WSTD,
        verbose    = FALSE
    )
    
    res <- qapc(res, percentiles = QS)
    
    asp <- agespec.proj(res)
    stopifnot(length(asp) == length(AGE20))
    
    ## ---- (a) "<5 years" age-specific rate ------------------------------------
    sub     <- get_mat(asp[[which(AGE20 == FOCUS_AGE)]])
    pop_v   <- m$pop[ALL_YEARS_CH, FOCUS_AGE]
    obs_cnt <- m$obs[ALL_YEARS_CH, FOCUS_AGE]
    f       <- RATE_SCALE / pop_v
    
    age_out <- build_block(sub, f, obs_cnt * f, loc, meas, FOCUS_AGE, hz, rw)
    age_out[, `:=`(population = pop_v, obs_count = obs_cnt)]
    
    ## ---- (b) age-standardised rate, per-year calibration ---------------------
    pop_mat <- as.matrix(m$pop[ALL_YEARS_CH, AGE20])
    cnt_med <- sapply(asp, function(a) get_mat(a)[, "0.5Q"])
    colnames(cnt_med) <- AGE20
    
    asr_manual <- as.numeric((cnt_med / pop_mat) %*% WSTD) * RATE_SCALE
    obs_asr    <- as.numeric((as.matrix(m$obs[ALL_YEARS_CH, AGE20]) / pop_mat) %*% WSTD) *
        RATE_SCALE
    
    asr_raw <- get_mat(agestd.proj(res))
    check_qcols(asr_raw)
    
    sf_year <- asr_manual / asr_raw[, "0.5Q"]
    
    asr_out <- build_block(
        asr_raw, sf_year, obs_asr, loc, meas,
        "Age-standardised", hz, rw
    )
    asr_out[, sf_year := sf_year]
    
    ## ---- sanity guard ---------------------------------------------------------
    bad <- age_out[get("x_0.5Q") < get("x_0.025Q") |
                       get("x_0.5Q") > get("x_0.975Q")]
    bad2 <- asr_out[get("x_0.5Q") < get("x_0.025Q") |
                        get("x_0.5Q") > get("x_0.975Q")]
    
    if (nrow(bad) || nrow(bad2)) {
        warning(sprintf("Median outside interval: %s/%s/%s/%s",
                        loc, meas, hz$label, rw))
    }
    
    list(age = age_out, asr = asr_out)
}

## =============================================================================
## 7. CHECKPOINTED RUNNER
## =============================================================================
job_tag <- function(meas, loc, hzname, rw) {
    gsub("[^A-Za-z0-9]+", "_", paste(meas, loc, hzname, rw, sep = "__"))
}

build_jobs <- function() {
    rbindlist(lapply(MEASURES, function(mm) {
        CJ(
            measure  = mm,
            location = MEASURE_LOCS[[mm]],
            hz       = names(HORIZONS),
            prior    = PRIORS,
            sorted   = FALSE
        )
    }))
}

current_job_tags <- function() {
    jobs <- build_jobs()
    jobs[, tag := mapply(job_tag, measure, location, hz, prior)]
    jobs$tag
}

run_all_ckpt <- function(force = FALSE) {
    jobs  <- build_jobs()
    total <- nrow(jobs)
    
    cat("Total fits:", total, "| checkpoint dir:", CKPT_DIR, "\n\n")
    t0 <- Sys.time()
    
    for (i in seq_len(total)) {
        j   <- jobs[i]
        tag <- job_tag(j$measure, j$location, j$hz, j$prior)
        fp  <- file.path(CKPT_DIR, paste0(tag, ".rds"))
        
        if (!force && file.exists(fp)) {
            cat(sprintf("[%3d/%3d] SKIP  %s\n", i, total, tag))
            next
        }
        
        hz <- HORIZONS[[j$hz]]
        
        cat(sprintf("[%3d/%3d] %-30s %-10s %-4s %s\n",
                    i, total, j$location, j$measure, toupper(j$prior), hz$label))
        
        out <- tryCatch(
            fit_one(j$location, j$measure, hz, j$prior),
            error = function(e) {
                message("   !! ", conditionMessage(e))
                NULL
            }
        )
        
        saveRDS(list(job = j, out = out), fp)
        
        if (i %% 20 == 0) {
            cat("   ... elapsed",
                round(difftime(Sys.time(), t0, units = "mins"), 1),
                "min\n")
        }
    }
    
    cat("\nAll jobs attempted in",
        round(difftime(Sys.time(), t0, units = "mins"), 1),
        "min\n")
    
    invisible(TRUE)
}

assemble_all <- function() {
    allowed_tags <- current_job_tags()
    fs_all <- list.files(CKPT_DIR, pattern = "\\.rds$", full.names = TRUE)
    
    if (!length(fs_all)) {
        stop("Checkpoint dir is empty. Run run_all_ckpt() first.")
    }
    
    fs_tag <- sub("\\.rds$", "", basename(fs_all))
    fs <- fs_all[fs_tag %in% allowed_tags]
    
    if (!length(fs)) {
        stop("No H07/RW2 checkpoints found in CKPT_DIR. Run run_all_ckpt() first.")
    }
    
    bits <- lapply(fs, readRDS)
    ok   <- Filter(function(b) !is.null(b$out), bits)
    bad  <- Filter(function(b)  is.null(b$out), bits)
    
    cat("Checkpoints in dir:", length(fs_all),
        "| H07/RW2 checkpoints:", length(fs),
        "| ok:", length(ok),
        "| failed:", length(bad), "\n")
    
    list(
        age    = rbindlist(lapply(ok, function(b) b$out$age), fill = TRUE),
        asr    = rbindlist(lapply(ok, function(b) b$out$asr), fill = TRUE),
        failed = if (length(bad)) rbindlist(lapply(bad, function(b) b$job)) else NULL,
        total  = length(fs)
    )
}

## =============================================================================
## 8. VALIDATION METRICS
## =============================================================================
interval_score <- function(y, l, u, alpha = 0.05) {
    (u - l) +
        (2 / alpha) * (l - y) * (y < l) +
        (2 / alpha) * (y - u) * (y > u)
}

make_eval <- function(d) {
    e <- copy(d[is_pred == TRUE])
    
    e[, obs_rate  := pointdata]
    e[, pred_rate := e[["x_0.5Q"]]]
    e[, lo95      := e[["x_0.025Q"]]]
    e[, hi95      := e[["x_0.975Q"]]]
    e[, lo50      := e[["x_0.25Q"]]]
    e[, hi50      := e[["x_0.75Q"]]]
    
    e[, `:=`(
        err       = pred_rate - obs_rate,
        pct_error = 100 * (pred_rate - obs_rate) /
            pmax(abs(obs_rate), .Machine$double.eps),
        ape       = abs(pred_rate - obs_rate) /
            pmax(abs(obs_rate), .Machine$double.eps),
        sape      = abs(pred_rate - obs_rate) /
            pmax((abs(pred_rate) + abs(obs_rate)) / 2, .Machine$double.eps),
        cov95     = as.integer(obs_rate >= lo95 & obs_rate <= hi95),
        cov50     = as.integer(obs_rate >= lo50 & obs_rate <= hi50),
        piw95     = hi95 - lo95
    )]
    
    e[, is95 := interval_score(obs_rate, lo95, hi95)]
    e[, period_flag := ifelse(year <= 2019, "pre-pandemic", "pandemic")][]
}

summarise_metrics <- function(e, by_lead = FALSE) {
    keys <- c("measure", "location", "horizon", "prior", "age")
    if (by_lead) keys <- c(keys, "lead")
    
    e[, .(
        n             = .N,
        MAE           = mean(abs(err)),
        RMSE          = sqrt(mean(err^2)),
        MAPE_pct      = 100 * mean(ape),
        sMAPE_pct     = 100 * mean(sape),
        MeanBias_pct  = mean(pct_error),
        Coverage_50   = 100 * mean(cov50),
        Coverage_95   = 100 * mean(cov95),
        MeanPIW_95    = mean(piw95),
        IntervalScore = mean(is95)
    ), by = keys]
}

make_wide <- function(e, digits = 2) {
    w <- copy(e)
    
    w[, cell := sprintf(
        paste0("%.", digits, "f (%.", digits, "f to %.", digits, "f)"),
        pred_rate, lo95, hi95
    )]
    
    dcast(
        w,
        measure + location + age + horizon + prior ~ year,
        value.var = "cell"
    )
}

validate_vs_gbd <- function(e) {
    v <- merge(
        e[age == FOCUS_AGE],
        dt_rate_gbd,
        by = c("location", "measure", "year"),
        all.x = TRUE
    )
    
    if (!nrow(v)) {
        cat("\n[validate] no GBD Rate rows matched.\n")
        return(NULL)
    }
    
    v[, rel_diff := abs(pointdata - gbd_rate) / pmax(gbd_rate, 1e-12)]
    
    cat("\n===== DENOMINATOR CHECK: derived rate vs GBD published Rate =====\n")
    cat("  max relative difference:", signif(max(v$rel_diff, na.rm = TRUE), 4), "\n")
    
    if (max(v$rel_diff, na.rm = TRUE) > 0.01) {
        warning("Derived rate deviates >1% from GBD's published Rate: check the denominator.")
    } else {
        cat("  OK (<1%): numerator and denominator are aligned.\n")
    }
    
    cat("=================================================================\n")
    
    v[, .(
        measure,
        location,
        year,
        derived_rate = pointdata,
        gbd_rate,
        rel_diff
    )]
}

## =============================================================================
## 9. EXPORT
## =============================================================================
export_all <- function(ALL) {
    ea <- make_eval(ALL$age)
    es <- make_eval(ALL$asr)
    
    ## --- full-period tables ---------------------------------------------------
    fwrite(ALL$age, file.path(OUT_DIR, "pred_under5_FULL_allyears.csv"))
    fwrite(ALL$asr, file.path(OUT_DIR, "pred_ASR_FULL_allyears.csv"))
    
    ## --- prediction years only ------------------------------------------------
    fwrite(ALL$age[is_pred == TRUE], file.path(OUT_DIR, "pred_under5_PREDONLY.csv"))
    fwrite(ALL$asr[is_pred == TRUE], file.path(OUT_DIR, "pred_ASR_PREDONLY.csv"))
    
    ## --- H07-only convenience files ------------------------------------------
    fwrite(
        ALL$age,
        file.path(OUT_DIR, "pred_under5_H07_RW2.csv")
    )
    
    fwrite(
        ALL$asr,
        file.path(OUT_DIR, "pred_ASR_H07_RW2.csv")
    )
    
    ## --- publication tables and metrics --------------------------------------
    fwrite(make_wide(ea), file.path(OUT_DIR, "pred_under5_rate_WIDE_H07_RW2.csv"))
    fwrite(make_wide(es), file.path(OUT_DIR, "pred_ASR_WIDE_H07_RW2.csv"))
    
    fwrite(summarise_metrics(ea),       file.path(OUT_DIR, "metrics_under5_H07_RW2.csv"))
    fwrite(summarise_metrics(es),       file.path(OUT_DIR, "metrics_ASR_H07_RW2.csv"))
    fwrite(summarise_metrics(ea, TRUE), file.path(OUT_DIR, "metrics_under5_by_lead_H07_RW2.csv"))
    
    fwrite(
        ea[, .(
            n            = .N,
            MAE          = mean(abs(err)),
            sMAPE_pct    = 100 * mean(sape),
            MeanBias_pct = mean(pct_error),
            Coverage_95  = 100 * mean(cov95)
        ), by = .(measure, horizon, prior, period_flag)],
        file.path(OUT_DIR, "metrics_under5_pandemic_split_H07_RW2.csv")
    )
    
    fwrite(
        ea[year >= 2015,
           .(
               n             = .N,
               MAE           = mean(abs(err)),
               sMAPE_pct     = 100 * mean(sape),
               MeanBias_pct  = mean(pct_error),
               Coverage_95   = 100 * mean(cov95),
               IntervalScore = mean(is95)
           ),
           by = .(measure, location, horizon, prior)],
        file.path(OUT_DIR, "metrics_under5_commonwindow2015_2021_H07_RW2.csv")
    )
    
    vg <- validate_vs_gbd(ea)
    if (!is.null(vg)) {
        fwrite(vg, file.path(OUT_DIR, "check_rate_vs_GBD_H07_RW2.csv"))
    }
    
    if (!is.null(ALL$failed)) {
        fwrite(ALL$failed, file.path(OUT_DIR, "failed_fits_H07_RW2.csv"))
    }
    
    cat("\nWritten to:", OUT_DIR,
        "| failed:", if (is.null(ALL$failed)) 0 else nrow(ALL$failed),
        "/", ALL$total, "\n")
    
    invisible(list(eval_age = ea, eval_asr = es))
}

## =============================================================================
## 10. EXECUTE
## =============================================================================
smoke <- function() {
    cat("\n===== SMOKE TEST: Global / Deaths / H07 / RW2 =====\n")
    
    t <- fit_one("Global", "Deaths", HORIZONS$H07, "rw2")
    
    print(t$age[, .(
        year,
        is_pred,
        lead,
        pointdata = round(pointdata, 3),
        med       = round(get("x_0.5Q"),   3),
        lo95      = round(get("x_0.025Q"), 3),
        hi95      = round(get("x_0.975Q"), 3)
    )])
    
    cat("Quantile columns produced:", ncol(t$age), "\n")
    cat("==================================================\n\n")
    
    invisible(t)
}

## Run these lines one by one if preferred:
tst <- smoke()
run_all_ckpt()
ALL <- assemble_all()
str(ALL, max.level = 1)
saveRDS(ALL, file.path(OUT_DIR, "ALL_raw_results_H07_RW2.rds"))
EV <- export_all(ALL)

## =============================================================================
## 预测值 vs. GBD 官方 Rate —— H07 / RW2 独立校验
## <5 years / Both / Meningitis
## =============================================================================

library(data.table)
library(dplyr)
library(tidyr)

## -------------------------------------------------------------------- 0. 配置
OUT_DIR     <- "C:/BAPC_hindcast_out"
output_stem <- file.path(OUT_DIR, "validation_under5_H07_RW2")

SEX        <- "Both"
FOCUS_AGE  <- "<5 years"
CAUSE      <- "Meningitis"
RATE_LABEL <- "Rate (per 100,000)"
COMMON_WINDOW <- 2015:2021

stopifnot(exists("df0"))

## 读预测结果
pp_predonly <- file.path(OUT_DIR, "pred_under5_PREDONLY.csv")
pp_full     <- file.path(OUT_DIR, "pred_under5_FULL_allyears.csv")

if (file.exists(pp_predonly)) {
    pred_raw <- as.data.frame(fread(pp_predonly))
} else if (file.exists(pp_full)) {
    pred_raw <- as.data.frame(fread(pp_full))
    pred_raw <- pred_raw[pred_raw$is_pred %in% c(TRUE, "TRUE"), , drop = FALSE]
} else {
    stop("找不到预测结果 CSV，请先运行 export_all()。")
}

## H07 + RW2 only guard
pred_raw <- pred_raw %>%
    filter(
        horizon == "train1990-2014_pred2015-2021",
        prior == "RW2"
    )

if (nrow(pred_raw) == 0) {
    stop("预测结果中没有 H07 + RW2 记录，请确认已运行本版代码。")
}

## =============================================================================
## 1. 构造预测数据框 df_pred
## =============================================================================
df_pred <- pred_raw %>%
    transmute(
        measure,
        sex = SEX,
        location,
        age = FOCUS_AGE,
        cause = CAUSE,
        metric = RATE_LABEL,
        horizon,
        prior,
        train_period,
        pred_period,
        year,
        lead,
        pred_val     = `x_0.5Q`,
        pred_lower   = `x_0.025Q`,
        pred_upper   = `x_0.975Q`,
        pred_lower50 = `x_0.25Q`,
        pred_upper50 = `x_0.75Q`,
        obs_rate_derived = pointdata
    )

cat("预测记录数：", nrow(df_pred), "\n")
cat("涉及 horizon：", paste(unique(df_pred$horizon), collapse = " | "), "\n")
cat("涉及 prior  ：", paste(unique(df_pred$prior),   collapse = " | "), "\n\n")

## =============================================================================
## 2. 构造实际数据框 df_actual —— GBD 官方 Rate
## =============================================================================
dt0     <- as.data.table(df0)
have_ci <- all(c("lower", "upper") %in% names(dt0))

gbd_rate <- dt0[
    sex == SEX & metric == "Rate" & age == FOCUS_AGE,
    .(
        measure,
        location,
        year,
        val       = val,
        val_lower = if (have_ci) lower else NA_real_,
        val_upper = if (have_ci) upper else NA_real_
    )
]

df_actual <- gbd_rate %>%
    as.data.frame() %>%
    mutate(
        sex    = SEX,
        age    = FOCUS_AGE,
        cause  = CAUSE,
        metric = RATE_LABEL
    ) %>%
    semi_join(
        distinct(df_pred, measure, location, year),
        by = c("measure", "location", "year")
    )

cat("实际记录数（GBD 官方 Rate）：", nrow(df_actual), "\n")

if (nrow(df_actual) == 0) {
    stop("未取到 GBD 官方 Rate，请确认 df0 中 metric=='Rate' 且 age=='<5 years' 的记录存在。")
}

## =============================================================================
## 3. 匹配键与序列键
## =============================================================================
join_keys   <- c("measure", "sex", "location", "age", "cause", "year")
series_keys <- c("measure", "sex", "location", "age", "cause", "horizon", "prior")

## =============================================================================
## 4. 双向未匹配检查
## =============================================================================
pred_keys <- df_pred   %>% distinct(across(all_of(join_keys)))
act_keys  <- df_actual %>% distinct(across(all_of(join_keys)))

unmatched_pred   <- anti_join(pred_keys, act_keys,  by = join_keys)
unmatched_actual <- anti_join(act_keys,  pred_keys, by = join_keys)

cat("预测数据未匹配组合数：", nrow(unmatched_pred),   "\n")
cat("实际数据未匹配组合数：", nrow(unmatched_actual), "\n")

if (nrow(unmatched_pred) > 0) {
    p <- paste0(output_stem, "_unmatched_pred.csv")
    write.csv(unmatched_pred, p, row.names = FALSE, fileEncoding = "UTF-8", na = "")
    stop("存在无对应 GBD 实际值的预测记录，不能静默丢弃。见：", p)
}

if (nrow(unmatched_actual) > 0) {
    p <- paste0(output_stem, "_unmatched_actual.csv")
    write.csv(unmatched_actual, p, row.names = FALSE, fileEncoding = "UTF-8", na = "")
    warning("部分 GBD 实际值无对应预测，已输出清单：", p)
}

## =============================================================================
## 5. 合并
## =============================================================================
df_all <- df_pred %>%
    inner_join(
        df_actual %>% select(all_of(join_keys), val, val_lower, val_upper),
        by = join_keys
    ) %>%
    arrange(measure, location, horizon, prior, year)

if (nrow(df_all) == 0) {
    stop("合并后为 0 行，请检查连接字段。")
}

if (nrow(df_all) != nrow(df_pred)) {
    warning("合并后行数(", nrow(df_all), ") != 预测记录数(", nrow(df_pred),
            ")，可能存在实际值缺年或重复键。")
}

## =============================================================================
## 6. 口径交叉核对：GBD 官方 Rate vs 自算 Number/人口
## =============================================================================
cat("\n===== 口径核对（GBD 官方 Rate vs. 自算率）=====\n")

xchk <- df_all %>%
    mutate(rel_diff = abs(obs_rate_derived - val) / pmax(val, 1e-12)) %>%
    group_by(measure, location) %>%
    summarise(max_rel_diff = max(rel_diff), .groups = "drop") %>%
    arrange(desc(max_rel_diff))

cat("全局最大相对偏差：", signif(max(xchk$max_rel_diff), 4), "\n")

if (max(xchk$max_rel_diff) > 0.01) {
    write.csv(
        xchk,
        paste0(output_stem, "_caliber_check.csv"),
        row.names = FALSE,
        fileEncoding = "UTF-8",
        na = ""
    )
    warning("官方 Rate 与自算率相对偏差 > 1%，分母口径可能不一致。")
} else {
    cat("口径一致（<1%），分子分母对齐无误。\n")
}

## =============================================================================
## 7. H07 序列完整性
## =============================================================================
horizon_years <- df_pred %>%
    group_by(horizon) %>%
    summarise(
        n_year_expected = n_distinct(year),
        years_expected  = paste(sort(unique(year)), collapse = ", "),
        .groups = "drop"
    )

cat("\nH07 评价年份：\n")
print(as.data.frame(horizon_years))

series_completeness <- df_all %>%
    group_by(across(all_of(series_keys))) %>%
    summarise(
        n_year = n_distinct(year),
        included_years = paste(sort(unique(year)), collapse = ", "),
        .groups = "drop"
    ) %>%
    left_join(horizon_years, by = "horizon")

incomplete_series <- series_completeness %>%
    filter(n_year != n_year_expected | included_years != years_expected)

cat("误差评价分组数：", nrow(series_completeness), "\n")
cat("年份不完整序列数：", nrow(incomplete_series), "\n")

if (nrow(incomplete_series) > 0) {
    p <- paste0(output_stem, "_incomplete_series.csv")
    write.csv(incomplete_series, p, row.names = FALSE, fileEncoding = "UTF-8", na = "")
    stop("部分序列年份不完整，见：", p)
}

## =============================================================================
## 8. 数值有效性检查
## =============================================================================
num_cols <- c("val", "pred_val", "pred_lower", "pred_upper")

if (sum(is.na(df_all[, num_cols])) > 0 ||
    sum(!is.finite(as.matrix(df_all[, num_cols]))) > 0) {
    stop("存在缺失/非有限值，不能可靠计算误差。")
}

if (any(df_all$val == 0)) {
    stop("GBD 实际值中存在 0，MAPE 无法按当前公式计算。")
}

bad_interval <- df_all %>%
    filter(pred_lower > pred_val | pred_val > pred_upper)

if (nrow(bad_interval) > 0) {
    warning("有 ", nrow(bad_interval),
            " 行不满足 lower<=median<=upper，请核对分位数列。")
}

write.csv(
    df_all,
    paste0(output_stem, "_matched_detail.csv"),
    row.names = FALSE,
    fileEncoding = "UTF-8",
    na = ""
)

## =============================================================================
## 9. 误差指标
## =============================================================================
interval_score <- function(y, l, u, alpha = 0.05) {
    (u - l) +
        (2 / alpha) * (l - y) * (y < l) +
        (2 / alpha) * (y - u) * (y > u)
}

## =============================================================================
## 10. 主结果：measure × location × H07 × RW2
## =============================================================================
result <- df_all %>%
    group_by(across(all_of(series_keys))) %>%
    summarise(
        train_period = first(train_period),
        pred_period  = first(pred_period),
        n_obs        = n(),
        MAE          = mean(abs(val - pred_val)),
        RMSE         = sqrt(mean((val - pred_val)^2)),
        MAPE         = mean(abs((val - pred_val) / val)) * 100,
        sMAPE        = mean(abs(val - pred_val) /
                                ((abs(val) + abs(pred_val)) / 2)) * 100,
        R_2          = 1 - sum((val - pred_val)^2) /
            sum((val - mean(val))^2),
        MeanBias_pct     = mean((pred_val - val) / val) * 100,
        Coverage_50      = mean(val >= pred_lower50 & val <= pred_upper50) * 100,
        Coverage_95      = mean(val >= pred_lower   & val <= pred_upper)   * 100,
        Mean_95_PI_width = mean(pred_upper - pred_lower),
        IntervalScore_95 = mean(interval_score(val, pred_lower, pred_upper)),
        low_credibility  = as.integer(
            mean(abs((val - pred_val) / val)) * 100 > 100 |
                max(pred_upper) > 10 * max(val)
        ),
        .groups = "drop"
    ) %>%
    arrange(measure, location, horizon, prior)

chk <- result %>%
    left_join(horizon_years, by = "horizon") %>%
    filter(n_obs != n_year_expected)

if (nrow(chk) > 0) {
    print(as.data.frame(chk))
    stop("部分分组年度记录数与 H07 应有年份不符。")
}

if (min(result$n_obs) < 7) {
    warning("最短序列仅 ", min(result$n_obs),
            " 个评价点，请以 MAPE/sMAPE + Coverage 为主。")
}

## =============================================================================
## 11. 共同窗口 2015-2021
## =============================================================================
result_common <- df_all %>%
    filter(year %in% COMMON_WINDOW) %>%
    group_by(across(all_of(series_keys))) %>%
    summarise(
        n_obs = n(),
        MAE   = mean(abs(val - pred_val)),
        sMAPE = mean(abs(val - pred_val) /
                         ((abs(val) + abs(pred_val)) / 2)) * 100,
        MeanBias_pct     = mean((pred_val - val) / val) * 100,
        Coverage_95      = mean(val >= pred_lower & val <= pred_upper) * 100,
        IntervalScore_95 = mean(interval_score(val, pred_lower, pred_upper)),
        .groups = "drop"
    ) %>%
    arrange(measure, location, horizon, prior)

## =============================================================================
## 12. 输出
## =============================================================================
write.csv(
    result,
    paste0(output_stem, "_error_by_series.csv"),
    row.names = FALSE,
    fileEncoding = "UTF-8",
    na = ""
)

write.csv(
    result_common,
    paste0(output_stem, "_commonwindow_2015_2021.csv"),
    row.names = FALSE,
    fileEncoding = "UTF-8",
    na = ""
)

low_cred <- result %>%
    filter(low_credibility == 1) %>%
    select(
        measure,
        location,
        horizon,
        prior,
        MAPE,
        Coverage_95,
        Mean_95_PI_width
    )

if (nrow(low_cred) > 0) {
    write.csv(
        low_cred,
        paste0(output_stem, "_low_credibility.csv"),
        row.names = FALSE,
        fileEncoding = "UTF-8",
        na = ""
    )
}

cat("\n========================================\n")
cat("误差结果（measure × location × H07 × RW2）\n")
cat("========================================\n")
print(as.data.frame(result), row.names = FALSE)

cat("\n低可信序列数：", nrow(low_cred), "\n")
cat("匹配明细：", paste0(output_stem, "_matched_detail.csv"), "\n")
cat("误差结果：", paste0(output_stem, "_error_by_series.csv"), "\n")
cat("共同窗口：", paste0(output_stem, "_commonwindow_2015_2021.csv"), "\n")
cat("校验完成。\n")

