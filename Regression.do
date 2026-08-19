clear all
set more off
local results_dir "/Users/youshan/Documents/Research/Replication Code and Data/Results"
capture mkdir "`results_dir'"
cd "`results_dir'"



* 1. Import data from the working directory
import delimited "regress_data_wide_baseline.csv", clear

* 2. Treatment indicators
gen GPT = (condition == 2)
gen DS  = (condition == 3)

* 3. Outcome variable: task share
replace ytask = ytask

* 4. Create three round-type categories
gen round_type = .
replace round_type = 1 if inlist(round, 2, 8, 10, 12, 13, 14, 16, 18, 20, 22)
replace round_type = 2 if inlist(round, 1, 3, 4, 6, 9, 11, 15, 17, 19, 21)
replace round_type = 3 if inlist(round, 5, 7)

*---------------------------------------------------------------*
* Run regressions and Wald tests for GPT = DS
*---------------------------------------------------------------*

est clear

* (1) Control only for round fixed effects
reghdfe ytask GPT DS, absorb(round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "No"
estadd local RoundFE "Yes"
est store m1

* (2) Control for individual and round fixed effects
reghdfe ytask GPT DS, absorb(prolificid round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "Yes"
estadd local RoundFE "Yes"
est store m2

* (3) Subsample: r1 < r2（round_type==1）
reghdfe ytask GPT DS if round_type == 1, absorb(prolificid round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "Yes"
estadd local RoundFE "Yes"
est store m3

* (4) Subsample: r1 = r2（round_type==3）
reghdfe ytask GPT DS if round_type == 3, absorb(prolificid round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "Yes"
estadd local RoundFE "Yes"
est store m4

* (5) Subsample: r1 > r2（round_type==2）
reghdfe ytask GPT DS if round_type == 2, absorb(prolificid round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "Yes"
estadd local RoundFE "Yes"
est store m5

*---------------------------------------------------------------*
* Export the table with Wald-test p-values
*---------------------------------------------------------------*

esttab m1 m2 m3 m4 m5 ///
    using "Extended Data Table 3.tex", replace ///
    booktabs ///
    keep(GPT DS) ///
    order(GPT DS) ///
    nomtitles ///
    ci(3) b(3) level(95) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    s(IndFE RoundFE N r2 p_wald, ///
      label("Individual FE" "Round FE" "Observations" "\$R^2\$" "Wald test \$p\$-value (GPT = DS)") ///
      fmt(%s %s %9.0fc %9.3f %9.3f)) ///
    nonotes ///
    substitute("\_" "_") ///
    fragment ///
    prehead( ///
        "\begin{table}[H]" ///
        "\centering" ///
        "\caption{Task Shares in the Baseline Experiment}" ///
        "\footnotesize" ///
        "\begin{threeparttable}" ///
        "\begin{tabular}{l*{5}{c}}" ///
        "\toprule\toprule" ///
        "\multicolumn{6}{c}{Dep. Var: Task Shares \$s_{ijt}\$ (\%)} \\" ///
        " & \multicolumn{2}{c}{ALL} & \multicolumn{1}{c}{\$r_1 < r_2\$} & \multicolumn{1}{c}{\$r_1 = r_2\$} & \multicolumn{1}{c}{\$r_1 > r_2\$} \\" ///
        "\cmidrule(lr){2-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5} \cmidrule(lr){6-6}" ///
    ) ///
    prefoot( ///
        "\midrule" ///
    ) ///
    postfoot( ///
        "\bottomrule\bottomrule" ///
        "\end{tabular}" ///
        "\begin{tablenotes}[flushleft]" ///
        "\footnotesize" ///
        "\item \textit{Notes:} 95\% confidence intervals based on standard errors clustered at the individual level are in brackets. The Wald test \$p\$-value corresponds to the null hypothesis that the coefficients on GPT and DS are equal. ***\$p<0.001\$, **\$p<0.01\$, *\$p<0.05\$." ///
        "\end{tablenotes}" ///
        "\end{threeparttable}" ///
        "\end{table}" ///
    )


	
	
	
	*===============================================================================
* Task Shares and Perceived Closeness in the Baseline Experiment
*===============================================================================
clear all
set more off
local results_dir "/Users/youshan/Documents/Research/Replication Code and Data/Results"
capture mkdir "`results_dir'"
cd "`results_dir'"



import delimited "regress_data_wide_baseline.csv", clear

*-------------------------------------------------------------------------------
* Construct variables
*-------------------------------------------------------------------------------
* Treatment indicators
gen GPT = (condition == 2)
gen DS  = (condition == 3)

* IOS differences between AI and human
gen diff_ios_gpt = ios_gpt - ios_human
gen diff_ios_ds  = ios_ds  - ios_human

* Generate interaction terms for esttab labels
gen iosgpt_x_gpt = ios_gpt   * GPT
gen iosh_x_gpt   = ios_human * GPT
gen iosds_x_ds   = ios_ds    * DS
gen iosh_x_ds    = ios_human * DS

*===============================================================================
* GPT vs Control (H-H and H-GPT)
*===============================================================================

* (1) Distant: IOS_GPT < IOS_H
reghdfe ytask GPT if condition != 3 & diff_ios_gpt < 0, ///
    absorb(prolificid round) cluster(prolificid)
estadd local indFE   "Yes"
estadd local roundFE "Yes"
est store m1

* (2) Close: IOS_GPT >= IOS_H
reghdfe ytask GPT if condition != 3 & diff_ios_gpt >= 0, ///
    absorb(prolificid round) cluster(prolificid)
estadd local indFE   "Yes"
estadd local roundFE "Yes"
est store m2

* (3) Pooled: Continuous IOS interactions
reghdfe ytask GPT iosgpt_x_gpt iosh_x_gpt if condition <= 2, ///
    absorb(prolificid round) cluster(prolificid)
estadd local indFE   "Yes"
estadd local roundFE "Yes"
est store m3

*===============================================================================
* DS vs Control (H-H and H-DS)
*===============================================================================

* (4) Distant: IOS_DS < IOS_H
reghdfe ytask DS if condition != 2 & diff_ios_ds < 0, ///
    absorb(prolificid round) cluster(prolificid)
estadd local indFE   "Yes"
estadd local roundFE "Yes"
est store m4

* (5) Close: IOS_DS >= IOS_H
reghdfe ytask DS if condition != 2 & diff_ios_ds >= 0, ///
    absorb(prolificid round) cluster(prolificid)
estadd local indFE   "Yes"
estadd local roundFE "Yes"
est store m5

* (6) Pooled: Continuous IOS interactions
reghdfe ytask DS iosds_x_ds iosh_x_ds if inlist(condition, 1, 3), ///
    absorb(prolificid round) cluster(prolificid)
estadd local indFE   "Yes"
estadd local roundFE "Yes"
est store m6

*===============================================================================
* Export the LaTeX table
*===============================================================================
esttab m1 m2 m3 m4 m5 m6 ///
    using "Table 1.tex", replace ///
    booktabs fragment nomtitles nonumbers ///
    keep(GPT iosgpt_x_gpt iosh_x_gpt DS iosds_x_ds iosh_x_ds) ///
    order(GPT iosgpt_x_gpt iosh_x_gpt DS iosds_x_ds iosh_x_ds) ///
    coeflabels( ///
        GPT          "GPT" ///
        iosgpt_x_gpt "IOS\$_{\text{GPT}}\times\$ GPT" ///
        iosh_x_gpt   "IOS\$_{\text{H}}\times\$ GPT" ///
        DS           "DS" ///
        iosds_x_ds   "IOS\$_{\text{DS}}\times\$ DS" ///
        iosh_x_ds    "IOS\$_{\text{H}}\times\$ DS" ///
    ) ///
    b(3) ci(3) level(95) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    s(indFE roundFE N r2, ///
      label("Individual FE" "Round FE" "Observations" "\$R^2\$") ///
      fmt(%s %s %9.0fc %9.3f)) ///
    nonotes ///
    substitute("\_" "_") ///
    prehead( ///
        "\begin{table}[H]" ///
        "\centering" ///
        "\caption{Task Shares and Perceived Closeness in the Baseline Experiment}" ///
        "\footnotesize" ///
        "\begin{threeparttable}" ///
        "\begin{tabular}{l*{6}{c}}" ///
        "\toprule\toprule" ///
        "& \multicolumn{6}{c}{Dep. Var: Task Shares \$s_{ijt}\$ (\%)} \\" ///
        "& \multicolumn{3}{c}{H--H and H--GPT} & \multicolumn{3}{c}{H--H and H--DS} \\" ///
        "\cmidrule(lr){2-4} \cmidrule(lr){5-7}" ///
        "& Distant & Close & Pooled & Distant & Close & Pooled \\" ///
        "& {\scriptsize IOS\$_{\text{GPT}}<\$ IOS\$_{\text{H}}\$} & {\scriptsize IOS\$_{\text{GPT}}\geq\$ IOS\$_{\text{H}}\$} & & {\scriptsize IOS\$_{\text{DS}}<\$ IOS\$_{\text{H}}\$} & {\scriptsize IOS\$_{\text{DS}}\geq\$ IOS\$_{\text{H}}\$} & \\" ///
        "& (1) & (2) & (3) & (4) & (5) & (6) \\" ///
        "\midrule" ///
    ) ///
    prefoot("\midrule") ///
    postfoot( ///
        "\bottomrule\bottomrule" ///
        "\end{tabular}" ///
        "\begin{tablenotes}" ///
        "\footnotesize" ///
        "\item Notes: 95\% confidence intervals in brackets, clustered at the individual level. ***\$p<0.001\$, **\$p<0.01\$, *\$p<0.05\$." ///
        "\end{tablenotes}" ///
        "\end{threeparttable}" ///
        "\end{table}" ///
    )


*===============================================================================
* Section 1: Economic interpretation of a one-SD change in IOS
*===============================================================================

* Loop inputs: treatment, IOS variable, interaction, pooled model, and sample condition
local treats  "GPT DS"
local iosvar_GPT   "ios_gpt"
local iosvar_DS    "ios_ds"
local inter_GPT    "iosgpt_x_gpt"
local inter_DS     "iosds_x_ds"
local model_GPT    "m3"
local model_DS     "m6"
local sample_GPT   "condition <= 2"
local sample_DS    "inlist(condition, 1, 3)"

foreach t of local treats {

    *--- Step 1: Compute IOS SD at the individual level in the estimation sample ---
    preserve
        quietly keep if `sample_`t''
        quietly bysort prolificid: keep if _n == 1
        quietly summarize `iosvar_`t''
        local sd_`t' = r(sd)
        local n_`t'  = r(N)
    restore

    *--- Step 2: Compute the one-SD effect with lincom standard errors and confidence intervals ---
    quietly est restore `model_`t''
    local b_`t' = _b[`inter_`t'']

    quietly lincom `sd_`t''*`inter_`t''
    local eff_`t' = r(estimate)
    local se_`t'  = r(se)
    local df      = e(df_r)
    local t_`t'   = `eff_`t'' / `se_`t''
    local p_`t'   = 2*ttail(`df', abs(`t_`t''))
    local lo_`t'  = `eff_`t'' - invttail(`df', 0.025)*`se_`t''
    local hi_`t'  = `eff_`t'' + invttail(`df', 0.025)*`se_`t''
}

*--- Print summary output ---
foreach t of local treats {
    di as text "{hline 66}"
    di as text "Economic interpretation: IOS_`t' × `t'  (pooled model `model_`t'')"
    di as text "{hline 66}"
    di as text "  Number of unique participants                = " as result %9.0f  `n_`t''
    di as text "  IOS_`t' SD at the individual level   = " as result %9.4f `sd_`t''
    di as text "  Interaction coefficient                  = " as result %9.4f `b_`t''
    di as text "  Effect of a one-SD change on ytask    = " as result %9.4f `eff_`t'' ///
       as text "  (se = " as result %6.4f `se_`t'' as text ")"
    di as text "  Two-sided p-value                   = " as result %9.4f `p_`t''
    di as text "  95% CI                      = [" as result %8.4f `lo_`t'' ///
       as text ", " as result %8.4f `hi_`t'' as text "]"
}
di as text "{hline 66}"


*===============================================================================
* Section 2: Coefficient-difference tests by subgroup (z-test, Distant vs. Close)
*===============================================================================

capture program drop coef_compare
program define coef_compare
    * Syntax: coef_compare modelA modelB coefficient "labelA" "labelB"
    args mA mB coef labA labB

    quietly est restore `mA'
    local bA  = _b[`coef']
    local seA = _se[`coef']

    quietly est restore `mB'
    local bB  = _b[`coef']
    local seB = _se[`coef']

    local diff = `bA' - `bB'
    local sed  = sqrt(`seA'^2 + `seB'^2)
    local z    = `diff' / `sed'
    local p    = 2*(1 - normal(abs(`z')))
    local lo   = `diff' - invnormal(0.975)*`sed'
    local hi   = `diff' + invnormal(0.975)*`sed'

    di as text "{hline 66}"
    di as text "`coef' coefficient comparison: `labA' (`mA') vs. `labB' (`mB')"
    di as text "{hline 66}"
    di as text "  `mA' (`labA'):  b = " as result %8.4f `bA' ///
       as text "   se = " as result %7.4f `seA'
    di as text "  `mB' (`labB'):  b = " as result %8.4f `bB' ///
       as text "   se = " as result %7.4f `seB'
    di as text "  Coefficient difference (bA - bB)  = " as result %8.4f `diff'
    di as text "  Standard error of the difference        = " as result %8.4f `sed'
    di as text "  z-statistic            = " as result %8.4f `z'
    di as text "  Two-sided p-value           = " as result %8.4f `p'
    di as text "  95% CI              = [" as result %8.4f `lo' ///
       as text ", " as result %8.4f `hi' as text "]"
end

coef_compare m1 m2 GPT "Distant" "Close"
coef_compare m4 m5 DS  "Distant" "Close"
di as text "{hline 66}"










clear all
set more off
local results_dir "/Users/youshan/Documents/Research/Replication Code and Data/Results"
capture mkdir "`results_dir'"
cd "`results_dir'"
*===============================================================================
* 0. Import data and create treatment indicators
*===============================================================================
import delimited ///
    "regress_data_wide_baseline.csv", ///
    clear

gen GPT = (condition == 2)
gen DS  = (condition == 3)
	
	
*===============================================================================
* 1. Regressions and one-SD AI-intensity effects
*===============================================================================
local intensity_vars ai_days1 ai_days2 ai_hours1 ai_hours2 ///
                     improvement_scores1 improvement_scores2

local i = 0
foreach v of local intensity_vars {
    local ++i

    gen ai_intensity = `v'

    reghdfe ytask ///
        c.ai_intensity##c.GPT ///
        c.ai_intensity##c.DS ///
        , absorb(round prolificid) cluster(prolificid)

    *--- (a) Individual-level SD of AI intensity in the estimation sample -----------------------
    preserve
        keep if e(sample)
        bysort prolificid: keep if _n == 1     // One row per participant
        qui sum ai_intensity
        local sd_int = r(sd)
    restore

    *--- (b) Treatment-effect heterogeneity for a one-SD change ---------
    * GPT
    lincom `sd_int' * c.ai_intensity#c.GPT
    estadd scalar eff_gpt    = r(estimate)
    estadd scalar eff_gpt_lb = r(lb)
    estadd scalar eff_gpt_ub = r(ub)

    * DS
    lincom `sd_int' * c.ai_intensity#c.DS
    estadd scalar eff_ds    = r(estimate)
    estadd scalar eff_ds_lb = r(lb)
    estadd scalar eff_ds_ub = r(ub)

    estadd scalar sd_int = `sd_int'

    *--- (c) Print a readable interpretation -----------------------------------------
    di as text _n "===== Model `i' (`v') ====="
    di as text "SD of AI intensity (individual level): " as result %6.3f `sd_int'
    di as text "1 SD -> GPT effect: " as result %6.3f _b[c.ai_intensity#c.GPT]*`sd_int' ///
       as text " pp of task share"
    di as text "1 SD -> DS  effect: " as result %6.3f _b[c.ai_intensity#c.DS]*`sd_int' ///
       as text " pp of task share"

    estadd local indFE   "Yes"
    estadd local roundFE "Yes"
    est store m`i'

    drop ai_intensity
}
esttab m1 m2 m3 m4 m5 m6 ///
    using "Extended Data Table 4.tex", replace ///
    booktabs fragment nomtitles ///
    keep(GPT DS c.ai_intensity#c.GPT c.ai_intensity#c.DS) ///
    order(GPT DS c.ai_intensity#c.GPT c.ai_intensity#c.DS) ///
    coeflabels( ///
        c.ai_intensity#c.GPT "\$AI_{intensity} \times GPT\$" ///
        c.ai_intensity#c.DS  "\$AI_{intensity} \times DS\$" ///
    ) ///
    b(3) ci(3) level(95) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    s(sd_int eff_gpt eff_ds indFE roundFE N r2, ///
      label("SD of \$AI_{intensity}\$" ///
            "Effect of 1 SD (GPT, pp)" ///
            "Effect of 1 SD (DS, pp)" ///
            "Individual FE" "Round FE" "Observations" "\$R^2\$") ///
      fmt(%9.3f %9.3f %9.3f %s %s %9.0fc %9.3f)) ///
    nonotes ///
    substitute("\_" "_") ///
    prehead( ///
        "\begin{table}[H]" ///
        "\centering" ///
        "\caption{Task Shares and AI Usage Intensity in the Baseline Experiment}" ///
        "\footnotesize" ///
        "\begin{threeparttable}" ///
        "\begin{tabular}{l*{6}{c}}" ///
        "\toprule\toprule" ///
        "& \multicolumn{6}{c}{Dep. Var: Task Shares \$s_{ijt}\$ (\%)} \\" ///
        "\cmidrule(lr){2-7}" ///
        "& Days & Days & Hours & Hours & Improvement & Improvement \\" ///
        "& (Work) & (Out of Work) & (Work) & (Out of Work) & (Work) & (Out of Work) \\" ///
    ) ///
    prefoot("\midrule") ///
    postfoot( ///
        "\bottomrule\bottomrule" ///
        "\end{tabular}" ///
        "\begin{tablenotes}" ///
        "\footnotesize" ///
        "\item \textit{Notes:} 95\% confidence intervals in brackets. Standard errors clustered at the individual level. ***\$p<0.001\$, **\$p<0.01\$, *\$p<0.05\$." ///
        "\end{tablenotes}" ///
        "\end{threeparttable}" ///
        "\end{table}" ///
    )

	

	
	
	
	
	
	
	
	
	
clear all
set more off
local results_dir "/Users/youshan/Documents/Research/Replication Code and Data/Results"
capture mkdir "`results_dir'"
cd "`results_dir'"

/********************************************************************
* 2. Individual-by-condition-by-round panel: ytask
*    Single regressions with pairwise Wald tests and two-panel output
********************************************************************/

*===========================================================
* 0. Path settings
*===========================================================
local path "/Users/youshan/Documents/Research/Replication Code and Data/Results"
local filename "Extended Data Table 5.tex"
local caption  "Task Shares in the Minimal and Political Group Experiments"

*===========================================================
* 1. Define a helper for regressions, Wald tests, and storage
*===========================================================
capture program drop run_reg
program define run_reg
    syntax name(name=mname) [if]

    reghdfe ytask H_d AI_s AI_d `if', absorb(prolificid round) cluster(prolificid)
    estadd local IndFE   "Yes"
    estadd local RoundFE "Yes"

    * ---- Wald tests for pairwise coefficient equality ----
    quietly test H_d = AI_s
    local p1 = cond(r(p)<0.001, "\$<\$0.001", string(r(p), "%9.3f"))
    estadd local p_H_AIin "`p1'"

    quietly test H_d = AI_d
    local p2 = cond(r(p)<0.001, "\$<\$0.001", string(r(p), "%9.3f"))
    estadd local p_H_AIout "`p2'"

    quietly test AI_s = AI_d
    local p3 = cond(r(p)<0.001, "\$<\$0.001", string(r(p), "%9.3f"))
    estadd local p_AIin_AIout "`p3'"

    est store `mname'
end

*===========================================================
* 2. Define shared data-preparation helper
*===========================================================
capture program drop prep_data
program define prep_data
    gen H_d  = (condition == 2)
    gen AI_s = (condition == 3)
    gen AI_d = (condition == 4)

    gen round_type = .
    replace round_type = 1 if inlist(round, 2, 8, 10, 12, 13, 14, 16, 18, 20, 22)
    replace round_type = 2 if inlist(round, 1, 3, 4, 6, 9, 11, 15, 17, 19, 21)
    replace round_type = 3 if inlist(round, 5, 7)
end

*==================================================================
* Study 2: Minimal
*==================================================================
import delimited "`path'/regress_data_wide_minimal.csv", clear
prep_data

run_reg m1                          // (1) ALL
run_reg m2 if round_type == 1       // (2) r1 < r2
run_reg m3 if round_type == 3       // (3) r1 = r2
run_reg m4 if round_type == 2       // (4) r1 > r2

*==================================================================
* Study 3: Political
*==================================================================
import delimited "`path'/regress_data_wide_political.csv", clear
prep_data

run_reg m5                          // (1) ALL
run_reg m6 if round_type == 1       // (2) r1 < r2
run_reg m7 if round_type == 3       // (3) r1 = r2
run_reg m8 if round_type == 2       // (4) r1 > r2

*==================================================================
* 3. Export the table: Panel (a) Minimal and Panel (b) Political
*==================================================================

* -------- Panel (a): Minimal --------
esttab m1 m2 m3 m4 using "`filename'", replace ///
    booktabs fragment ///
    keep(H_d AI_s AI_d) ///
    order(H_d AI_s AI_d) ///
    coeflabels(H_d  "\$H_{out}\$" ///
               AI_s "\$AI_{in}\$" ///
               AI_d "\$AI_{out}\$") ///
    nomtitles ///
    ci(3) b(3) level(95) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    s(p_H_AIin p_H_AIout p_AIin_AIout IndFE RoundFE N r2, ///
      label("\$p\;(H_{out} = AI_{in})\$" ///
            "\$p\;(H_{out} = AI_{out})\$" ///
            "\$p\;(AI_{in} = AI_{out})\$" ///
            "Individual FE" "Round FE" "Observations" "\$R^2\$") ///
      fmt(%s %s %s %s %s %9.0fc %9.3f)) ///
    nonotes ///
    substitute("\_" "_") ///
    prehead( ///
        "\begin{table}[H]" ///
        "\centering" ///
        "\caption{`caption'}" ///
        "\footnotesize" ///
        "\begin{threeparttable}" ///
        "\begin{tabular}{l*{4}{c}}" ///
        "\toprule\toprule" ///
        " & \multicolumn{4}{c}{Dep. Var: Task Shares \$s_{ijt}\$ (\%)} \\" ///
        "\cmidrule(lr){2-5}" ///
        " & ALL & \$r_1 < r_2\$ & \$r_1 = r_2\$ & \$r_1 > r_2\$ \\" ///
    ) ///
    posthead( ///
        "\midrule" ///
        "\multicolumn{5}{l}{\textit{Panel (a): Minimal Group Experiment}} \\" ///
    ) ///
    prefoot("\midrule") ///
    postfoot("\midrule\midrule")

* -------- Panel (b): Political --------
esttab m5 m6 m7 m8 using "`filename'", append ///
    booktabs fragment ///
    keep(H_d AI_s AI_d) ///
    order(H_d AI_s AI_d) ///
    coeflabels(H_d  "\$H_{out}\$" ///
               AI_s "\$AI_{in}\$" ///
               AI_d "\$AI_{out}\$") ///
    nomtitles nonumbers ///
    ci(3) b(3) level(95) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    s(p_H_AIin p_H_AIout p_AIin_AIout IndFE RoundFE N r2, ///
      label("\$p\;(H_{out} = AI_{in})\$" ///
            "\$p\;(H_{out} = AI_{out})\$" ///
            "\$p\;(AI_{in} = AI_{out})\$" ///
            "Individual FE" "Round FE" "Observations" "\$R^2\$") ///
      fmt(%s %s %s %s %s %9.0fc %9.3f)) ///
    nonotes ///
    substitute("\_" "_") ///
    prehead( ///
        " & ALL & \$r_1 < r_2\$ & \$r_1 = r_2\$ & \$r_1 > r_2\$ \\" ///
        " & (1) & (2) & (3) & (4) \\" ///
    ) ///
    posthead( ///
        "\midrule" ///
        "\multicolumn{5}{l}{\textit{Panel (b): Political Group Experiment}} \\" ///
    ) ///
    prefoot("\midrule") ///
    postfoot( ///
        "\bottomrule\bottomrule" ///
        "\end{tabular}" ///
        "\begin{tablenotes}[flushleft]" ///
        "\footnotesize" ///
        "\item \textit{Notes:} 95\% confidence intervals based on standard errors clustered at the individual level are in brackets. \$p\$-values are from Wald tests of pairwise equality of treatment coefficients. ***\$p<0.001\$, **\$p<0.01\$, *\$p<0.05\$." ///
        "\end{tablenotes}" ///
        "\end{threeparttable}" ///
        "\end{table}" ///
    )


	
	
	
	
	



	
	
clear all
set more off
local results_dir "/Users/youshan/Documents/Research/Replication Code and Data/Results"
capture mkdir "`results_dir'"
cd "`results_dir'"
	

********************************************************************************
* Pooled regressions combining Minimal and Political samples
* Output format follows: Extended Data Table 7
********************************************************************************

*------------------------------*
* 1. Read and append the two datasets
*------------------------------*

* Read the Political sample
import delimited ///
    "regress_data_wide_political.csv", ///
    clear
gen sample = "political"

tempfile political_data
save `political_data'

* Read the Minimal sample
import delimited ///
    "regress_data_wide_minimal.csv", ///
    clear
gen sample = "minimal"

* Append datasets
append using `political_data'


* Treatment indicators
gen H_d  = (condition==2)
gen AI_s = (condition==3)
gen AI_d = (condition==4)

*==========================================================*
* Notes and section labels standardized in English.
*
* Notes and section labels standardized in English.
* Each participant has 22 rounds; compute SD after keeping one row per participant
*==========================================================*

* Notes and section labels standardized in English.
local dummy_A "H_d"
local dummy_B "AI_s"
local dummy_C "AI_d"
local cond_A  2
local cond_B  3
local cond_C  4

* --- In-group baseline closeness measures ---
local in_ios  "ios_human_same"
local in_like "hs_like"
local in_care "hs_care"

* --- Treatment closeness measures ---
local tr_A_ios  "ios_human_different"
local tr_A_like "hd_like"
local tr_A_care "hd_care"
local tr_B_ios  "ios_ai_same"
local tr_B_like "ais_like"
local tr_B_care "ais_care"
local tr_C_ios  "ios_ai_different"
local tr_C_like "aid_like"
local tr_C_care "aid_care"

foreach p in A B C {

    local D   "`dummy_`p''"
    local cnd  `cond_`p''

    foreach m in ios like care {

        * Use common variable names for esttab alignment
        gen C_in    = `in_`m''
        gen C_treat = `tr_`p'_`m''

        reghdfe ytask ///
            c.C_treat##c.`D' ///
            c.C_in#c.`D' ///
            if condition==1 | condition==`cnd' ///
            , absorb(prolificid round) cluster(prolificid)

        *----------------------------------------------------------*
        * Effect of a one-SD change in C_treat on the treatment effect
        *----------------------------------------------------------*
        preserve
            keep if e(sample)                        // Keep the estimation sample only
            duplicates drop prolificid, force  // Keep one row per participant
            * To compute SD within the treatment group only, add: keep if `D'==1
            qui sum C_treat
            local sd = r(sd)
        restore

        qui lincom `sd' * c.C_treat#c.`D'
        local lb = r(estimate) - invttail(r(df), 0.025)*r(se)
        local ub = r(estimate) + invttail(r(df), 0.025)*r(se)

        di as text "[Panel `p', `m'] SD(Closeness) = " as result %6.3f `sd' ///
           as text " | 1 SD effect = "  as result %6.3f r(estimate) ///
           as text " [95% CI: " as result %6.3f `lb' as text ", " ///
           as result %6.3f `ub' as text "]"

        * Store estimates for table output
        estadd scalar sd_x      = `sd'
        estadd scalar sd_effect = r(estimate)
        estadd scalar sd_se     = r(se)
        estadd local  indFE   "Yes"
        estadd local  roundFE "Yes"
     

        est store p`p'_`m'

        drop C_in C_treat
    }
}

*==========================================================*
* Step 4: Export the LaTeX table
*==========================================================*
local tabfile "Extended Data Table 7.tex"
local statsblock ///
    s(sd_x sd_effect indFE roundFE N r2, ///
      label("SD of Closeness" "Effect of 1 SD Closeness" ///
            "Individual FE" "Round FE"  ///
            "Observations" "\(R^2\)") ///
      fmt(%9.3f %9.3f %s %s %9.0fc %9.3f))

*--- Panel (a): H_out ---*
esttab pA_ios pA_like pA_care using "`tabfile'", replace ///
    booktabs fragment nomtitles nonumbers ///
    keep(H_d c.C_treat#c.H_d c.C_in#c.H_d) ///
    order(H_d c.C_treat#c.H_d c.C_in#c.H_d) ///
    coeflabels( ///
        H_d             "\$H_{out}\$" ///
        c.C_treat#c.H_d "\$\text{Close}_{H_{out}} \times H_{out}\$" ///
        c.C_in#c.H_d    "\$\text{Close}_{H_{in}} \times H_{out}\$" ///
    ) ///
    ci(3) b(3) level(95) star(* 0.05 ** 0.01 *** 0.001) ///
    `statsblock' nonotes ///
    prehead( ///
        "\begin{table}[H]" ///
        "\centering" ///
        "\caption{Task Shares and Perceived Closeness in the Minimal and Political Group Experiments}" ///
        "\footnotesize" ///
        "\begin{threeparttable}" ///
        "\begin{tabular}{l*{3}{c}}" ///
        "\toprule\toprule" ///
        "& \multicolumn{3}{c}{Dep.\ Var.: Task Share \$s_{ijt}\$ (\%)} \\" ///
        "\cmidrule(lr){2-4}" ///
        "& IOS & Willingness & Care \\" ///
        "& (1) & (2) & (3) \\" ///
        "\midrule" ///
        "\multicolumn{4}{l}{\textit{Panel (a): \$H_{in}\$-\$H_{in}\$ and \$H_{in}\$-\$H_{out}\$}} \\" ///
    ) ///
    postfoot("")

*--- Panel (b): AI_in ---*
esttab pB_ios pB_like pB_care using "`tabfile'", append ///
    booktabs fragment nomtitles nonumbers ///
    keep(AI_s c.C_treat#c.AI_s c.C_in#c.AI_s) ///
    order(AI_s c.C_treat#c.AI_s c.C_in#c.AI_s) ///
    coeflabels( ///
        AI_s             "\$AI_{in}\$" ///
        c.C_treat#c.AI_s "\$\text{Close}_{AI_{in}} \times AI_{in}\$" ///
        c.C_in#c.AI_s    "\$\text{Close}_{H_{in}} \times AI_{in}\$" ///
    ) ///
    ci(3) b(3) level(95) star(* 0.05 ** 0.01 *** 0.001) ///
    `statsblock' nonotes ///
    prehead( ///
        "\midrule" ///
        "& (1) & (2) & (3) \\" ///
        "\midrule" ///
        "\multicolumn{4}{l}{\textit{Panel (b): \$H_{in}\$-\$H_{in}\$ and \$H_{in}\$-\$AI_{in}\$}} \\" ///
    ) ///
    postfoot("")

*--- Panel (c): AI_out ---*
esttab pC_ios pC_like pC_care using "`tabfile'", append ///
    booktabs fragment nomtitles nonumbers ///
    keep(AI_d c.C_treat#c.AI_d c.C_in#c.AI_d) ///
    order(AI_d c.C_treat#c.AI_d c.C_in#c.AI_d) ///
    coeflabels( ///
        AI_d             "\$AI_{out}\$" ///
        c.C_treat#c.AI_d "\$\text{Close}_{AI_{out}} \times AI_{out}\$" ///
        c.C_in#c.AI_d    "\$\text{Close}_{H_{in}} \times AI_{out}\$" ///
    ) ///
    ci(3) b(3) level(95) star(* 0.05 ** 0.01 *** 0.001) ///
    `statsblock' nonotes ///
    prehead( ///
        "\midrule" ///
        "& (1) & (2) & (3) \\" ///
        "\midrule" ///
        "\multicolumn{4}{l}{\textit{Panel (c): \$H_{in}\$-\$H_{in}\$ and \$H_{in}\$-\$AI_{out}\$}} \\" ///
    ) ///
    postfoot( ///
        "\bottomrule\bottomrule" ///
        "\end{tabular}" ///
        "\begin{tablenotes}" ///
        "\footnotesize" ///
        "\item \textit{Notes:} 95\% confidence intervals based on standard errors clustered at the individual level are in brackets. ***\$p<0.001\$, **\$p<0.01\$, *\$p<0.05\$." ///
        "\end{tablenotes}" ///
        "\end{threeparttable}" ///
        "\end{table}" ///
    )
	
	
	

	
	
	
	
	
clear all
set more off
local results_dir "/Users/youshan/Documents/Research/Replication Code and Data/Results"
capture mkdir "`results_dir'"
cd "`results_dir'"
	

********************************************************************************
* Pooled regressions combining Minimal and Political samples
* Output format follows: Extended Data Table 8
********************************************************************************

*------------------------------*
* 1. Read and append the two datasets
*------------------------------*

* Read the Political sample
import delimited ///
    "regress_data_wide_political.csv", ///
    clear
gen sample = "political"

tempfile political_data
save `political_data'

* Read the Minimal sample
import delimited ///
    "regress_data_wide_minimal.csv", ///
    clear
gen sample = "minimal"

* Append datasets
append using `political_data'


encode prolificid, gen(newid)

* Treatment indicators
gen H_d  = (condition == 2)   // Human, out-group
gen AI_s = (condition == 3)   // AI, in-group
gen AI_d = (condition == 4)   // AI, out-group

*------------------------------*
* Notes and section labels standardized in English.
*    Each column uses one AI-usage intensity measure
*------------------------------*

local intvars ai_days1 ai_days2 ai_hours1 ai_hours2 ///
              improvement_scores1 improvement_scores2

local i = 1
foreach v of local intvars {

    gen ai_int = `v'   // Use a common variable name to align coefficients across columns

    reghdfe ytask ///
        c.ai_int##c.H_d ///
        c.ai_int##c.AI_s ///
        c.ai_int##c.AI_d, ///
        absorb(newid round) ///
        cluster(newid)

    estadd local controls "Yes"
    est store m`i'

    drop ai_int
    local ++i
}

********************************************************************************
* 3. Export the LaTeX table
********************************************************************************

esttab m1 m2 m3 m4 m5 m6 ///
    using "Extended Data Table 8.tex", replace ///
    booktabs fragment ///
    nomtitles nonumbers collabels(none) nogaps ///
    keep(H_d AI_s AI_d ///
         c.ai_int#c.H_d c.ai_int#c.AI_s c.ai_int#c.AI_d) ///
    order(H_d AI_s AI_d ///
          c.ai_int#c.H_d c.ai_int#c.AI_s c.ai_int#c.AI_d) ///
    coeflabels( ///
        H_d              "\$\mathrm{H}_{\text{out}}\$" ///
        AI_s             "\$\mathrm{AI}_{\text{in}}\$" ///
        AI_d             "\$\mathrm{AI}_{\text{out}}\$" ///
        c.ai_int#c.H_d   "\$\mathrm{AI}_{\text{intensity}} \times \mathrm{H}_{\text{out}}\$" ///
        c.ai_int#c.AI_s  "\$\mathrm{AI}_{\text{intensity}} \times \mathrm{AI}_{\text{in}}\$" ///
        c.ai_int#c.AI_d  "\$\mathrm{AI}_{\text{intensity}} \times \mathrm{AI}_{\text{out}}\$" ///
    ) ///
    b(3) ci(3) level(95) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    stats(controls N r2, ///
        label("Controls" "Observations" "\$R^2\$") ///
        fmt(%s %9.0fc %9.3f)) ///
    nonotes ///
    substitute("\_" "_") ///
    prehead( ///
        "\begin{table}[H]" ///
        "\centering" ///
        "\caption{Task Shares and AI Usage Intensity in the Minimal and Political Group Experiments}" ///
        "\footnotesize" ///
        "\begin{threeparttable}" ///
        "\begin{tabular}{l*{6}{c}}" ///
        "\toprule\toprule" ///
        "& \multicolumn{6}{c}{Dep. Var: Task Shares \$s_{ijt}\$ (\%)} \\" ///
        "\cmidrule(lr){2-7}" ///
        "& Days & Days & Hours & Hours & Improvement & Improvement \\" ///
        "& (Work) & (Out of Work) & (Work) & (Out of Work) & (Work) & (Out of Work) \\" ///
        "\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}" ///
        "& (1) & (2) & (3) & (4) & (5) & (6) \\" ///
        "\midrule" ///
    ) ///
    prefoot("\midrule") ///
    postfoot( ///
        "\bottomrule\bottomrule" ///
        "\end{tabular}" ///
        "\begin{tablenotes}" ///
        "\footnotesize" ///
        "\item \textit{Notes:} Brackets report 95\% confidence intervals based on standard errors clustered at the individual level. ***\$p<0.001\$, **\$p<0.01\$, *\$p<0.05\$." ///
        "\end{tablenotes}" ///
        "\end{threeparttable}" ///
        "\end{table}" ///
    )
	
	
	

	
	
clear all
set more off
local results_dir "/Users/youshan/Documents/Research/Replication Code and Data/Results"
capture mkdir "`results_dir'"
cd "`results_dir'"	
********************************************************************************
* Append the two datasets
********************************************************************************

* Read the Minimal sample
import delimited ///
    "regress_data_wide_minimal.csv", ///
    clear

gen study = 1
tostring prolificid, replace force
replace prolificid = "min_" + prolificid

tempfile minimal_data
save `minimal_data'

* Read the Political sample
import delimited ///
    "regress_data_wide_political.csv", ///
    clear

gen study = 2
tostring prolificid, replace force
replace prolificid = "pol_" + prolificid

* Notes and section labels standardized in English.
append using `minimal_data'

* Create a numeric ID for fixed effects
encode prolificid, gen(id_num)

********************************************************************************
* Prepare data and run regressions
********************************************************************************

eststo clear

* Treatment indicators
gen H_d  = (condition==2)
gen AI_s = (condition==3)
gen AI_d = (condition==4)

* Variable order matches the table layout:
* Writing / Practical Guidance / Technical Help / Multimedia /
* Seeking Information / Self-Expression / Other-Unknown
local varlist "writing practicalguidance technicalhelp multimedia seekinginformation expressionandinteraction other_use"

local i = 1
foreach var of local varlist {
    gen temp_exp = `var'

    reghdfe ytask c.temp_exp##c.H_d c.temp_exp##c.AI_s c.temp_exp##c.AI_d, ///
        absorb(id_num round) cluster(id_num)

    * --- Compute and store the mean of AI_activity in the estimation sample---
    quietly summarize temp_exp if e(sample)
    local mval : display %4.1f 100*r(mean)
    estadd local MeanAI "`mval'\%"

    estadd local Controls "Yes"
    estadd local IndFE    "Yes"
    estadd local RoundFE  "Yes"

    est store m`i'
    drop temp_exp
    local i = `i' + 1
}

********************************************************************************
* Export the LaTeX table
********************************************************************************

esttab m1 m2 m3 m4 m5 m6 m7 ///
    using "Extended Data Table 9.tex", replace ///
    booktabs ///
    nomtitles numbers ///
    mgroups("Writing" "\shortstack{Practical\\Guidance}" "\shortstack{Technical\\Help}" ///
            "Multimedia" "\shortstack{Seeking\\Information}" "\shortstack{Self-\\Expression}" ///
            "\shortstack{Other/\\Unknown}", ///
        pattern(1 1 1 1 1 1 1) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    keep(H_d AI_s AI_d c.temp_exp#c.H_d c.temp_exp#c.AI_s c.temp_exp#c.AI_d) ///
    order(H_d AI_s AI_d c.temp_exp#c.H_d c.temp_exp#c.AI_s c.temp_exp#c.AI_d) ///
    coeflabels( ///
        H_d               "\$\mathrm{H_{out}}\$" ///
        AI_s              "\$\mathrm{AI_{in}}\$" ///
        AI_d              "\$\mathrm{AI_{out}}\$" ///
        c.temp_exp#c.H_d  "\$\mathrm{AI_{activity}} \times \mathrm{H_{out}}\$" ///
        c.temp_exp#c.AI_s "\$\mathrm{AI_{activity}} \times \mathrm{AI_{in}}\$" ///
        c.temp_exp#c.AI_d "\$\mathrm{AI_{activity}} \times \mathrm{AI_{out}}\$" ///
    ) ///
    b(3) ci(3) level(95) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    s(MeanAI Controls IndFE RoundFE N r2, ///
      label("Mean of \$\mathrm{AI_{activity}}\$" "Controls" "Individual FE" ///
            "Round FE" "Observations" "\$R^2\$") ///
      fmt(%s %s %s %s %9.0fc %9.3f)) ///
    nonotes ///
    substitute("\_" "_") ///
    prehead( ///
        "\begin{table}[H]" ///
        "\centering" ///
        "\caption{Task Shares and AI Usage Activities in the Minimal and Political Group Experiments (Pooled Sample)}" ///
        "\footnotesize" ///
        "\begin{threeparttable}" ///
        "\begin{tabular}{l*{7}{c}}" ///
        "\toprule\toprule" ///
        "& \multicolumn{7}{c}{Dep. Var: Task Shares \$s_{ijt}\$ (\%)} \\" ///
        "\cmidrule(lr){2-8}" ///
    ) ///
    prefoot( ///
        "\midrule" ///
    ) ///
    postfoot( ///
        "\bottomrule\bottomrule" ///
        "\end{tabular}" ///
        "\begin{tablenotes}" ///
        "\footnotesize" ///
        "\item \textit{Notes:} 95\% confidence intervals based on standard errors clustered at the individual level are reported in brackets. ***\$p<0.001\$, **\$p<0.01\$, *\$p<0.05\$." ///
        "\end{tablenotes}" ///
        "\end{threeparttable}" ///
        "\end{table}" ///
    )


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
clear all
set more off
local results_dir "/Users/youshan/Documents/Research/Replication Code and Data/Results"
capture mkdir "`results_dir'"
cd "`results_dir'"

********************************************************************************
* Table: Task Shares and Perceived Relationship with AI
* Pooled Minimal + Political samples; two-panel layout (cols 1-4 / 5-9)
********************************************************************************

eststo clear

********************************************************************************
* Step 1: Read and prepare the Minimal sample
********************************************************************************
import delimited ///
    "regress_data_wide_minimal.csv", ///
    clear

gen study = 1
tostring prolificid, replace
replace prolificid = "min_" + prolificid

tempfile minimal_data
save `minimal_data'

********************************************************************************
* Step 2: Read and prepare the Political sample
********************************************************************************
import delimited ///
    "regress_data_wide_political.csv", ///
    clear

gen study = 2
tostring prolificid, replace
replace prolificid = "pol_" + prolificid

********************************************************************************
* Step 3: Append the two datasets
********************************************************************************
append using `minimal_data'

* Treatment indicators
gen H_d  = (condition==2)
gen AI_s = (condition==3)
gen AI_d = (condition==4)

* Numeric ID for clustering
encode prolificid, gen(id_num)

********************************************************************************
* Step 4: Run nine regressions in table-column order
********************************************************************************
local varlist "smart_assistant collaborative_partner knowledge_consultant social_companion functional_tool big_tech potential_risk_threat not_use_genai other_relations"
local i = 1

foreach var of local varlist {
    capture confirm variable `var'
    if _rc == 0 {
        gen temp_exp = `var'
        reghdfe ytask c.temp_exp##c.H_d c.temp_exp##c.AI_s c.temp_exp##c.AI_d, ///
            absorb(id_num round) cluster(id_num)

        * Mean of AI_rela. (estimation sample, in %)
        quietly summarize temp_exp if e(sample)
        estadd local MeanRel = string(100*r(mean), "%9.1f") + "\%"
        estadd local Controls "Yes"

        est store m`i'
        drop temp_exp
    }
    local ++i
}

********************************************************************************
* Notes and section labels standardized in English.
********************************************************************************

*--- Panel A: columns (1)-(4) ---*
esttab m1 m2 m3 m4 ///
    using "Table 2.tex", replace fragment ///
    booktabs nomtitles nonumbers ///
    keep(H_d AI_s AI_d c.temp_exp#c.H_d c.temp_exp#c.AI_s c.temp_exp#c.AI_d) ///
    order(H_d AI_s AI_d c.temp_exp#c.H_d c.temp_exp#c.AI_s c.temp_exp#c.AI_d) ///
    coeflabels( ///
        H_d               "\$H_{out}\$" ///
        AI_s              "\$AI_{in}\$" ///
        AI_d              "\$AI_{out}\$" ///
        c.temp_exp#c.H_d  "\$AI_{rela.} \times H_{out}\$" ///
        c.temp_exp#c.AI_s "\$AI_{rela.} \times AI_{in}\$" ///
        c.temp_exp#c.AI_d "\$AI_{rela.} \times AI_{out}\$" ///
    ) ///
    ci(3) b(3) level(95) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    s(MeanRel Controls N r2, ///
        label("Mean of \$AI_{rela.}\$" "Controls" "Observations" "\$R^2\$") ///
        fmt(%s %s %9.0fc %9.3f)) ///
    nonotes ///
    substitute("\_" "_") ///
    prehead( ///
        "\begin{table}[htbp]" ///
        "\centering" ///
        "\caption{Task Shares and Perceived Relationship with AI in the Minimal and Political Group Experiments}" ///
        "\label{tab:ai_relation}" ///
        "\scriptsize" ///
        "\begin{threeparttable}" ///
        "\begin{tabular}{l*{5}{c}}" ///
        "\toprule\toprule" ///
        " & \multicolumn{5}{c}{Dep.\ Var: Task Shares \$s_{ijt}\$ (\%)} \\" ///
        "\cmidrule(lr){2-6}" ///
        " & Smart & Collaborative & Knowledge & Social & \\" ///
        " & Assistant & Partner & Consultant & Companion & \\" ///
        "\cmidrule(lr){2-5}" ///
        " & (1) & (2) & (3) & (4) & \\" ///
        "\midrule" ///
    ) ///
    postfoot("\midrule")

*--- Panel B: columns (5)-(9) ---*
esttab m5 m6 m7 m8 m9 ///
    using "Table 2.tex", append fragment ///
    booktabs nomtitles nonumbers ///
    keep(H_d AI_s AI_d c.temp_exp#c.H_d c.temp_exp#c.AI_s c.temp_exp#c.AI_d) ///
    order(H_d AI_s AI_d c.temp_exp#c.H_d c.temp_exp#c.AI_s c.temp_exp#c.AI_d) ///
    coeflabels( ///
        H_d               "\$H_{out}\$" ///
        AI_s              "\$AI_{in}\$" ///
        AI_d              "\$AI_{out}\$" ///
        c.temp_exp#c.H_d  "\$AI_{rela.} \times H_{out}\$" ///
        c.temp_exp#c.AI_s "\$AI_{rela.} \times AI_{in}\$" ///
        c.temp_exp#c.AI_d "\$AI_{rela.} \times AI_{out}\$" ///
    ) ///
    ci(3) b(3) level(95) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    s(MeanRel Controls N r2, ///
        label("Mean of \$AI_{rela.}\$" "Controls" "Observations" "\$R^2\$") ///
        fmt(%s %s %9.0fc %9.3f)) ///
    nonotes ///
    substitute("\_" "_") ///
    prehead( ///
        " & Functional & Big & Potential & Not Use & Other \\" ///
        " & Tool & Tech & Risk/Threat & GenAI & Relations \\" ///
        "\cmidrule(lr){2-6}" ///
        " & (5) & (6) & (7) & (8) & (9) \\" ///
        "\midrule" ///
    ) ///
    postfoot( ///
        "\bottomrule\bottomrule" ///
        "\end{tabular}" ///
        "\begin{tablenotes}" ///
        "\scriptsize" ///
        "\item \textit{Notes:} 95\% confidence intervals based on standard errors clustered at the individual level are in brackets. ***\$p<0.001\$, **\$p<0.01\$, *\$p<0.05\$." ///
        "\end{tablenotes}" ///
        "\end{threeparttable}" ///
        "\end{table}" ///
    )



