clear all

*---------------------------------------------------------------*
* 0. 定义当前路径
*---------------------------------------------------------------*
cd "/Users/youshan/Library/CloudStorage/Dropbox/Revealed Consistency in Food Choices/Replication Code and Data/Results"



* 1. 数据导入（从当前路径读取）
import delimited "regress_data_wide_baseline.csv", clear

* 2. 处理组 dummy
gen GPT = (condition == 2)
gen DS  = (condition == 3)

* 3. 因变量（share）
replace ytask = ytask

* 4. 创建 round_type（3 类）
gen round_type = .
replace round_type = 1 if inlist(round, 2, 8, 10, 12, 13, 14, 16, 18, 20, 22)
replace round_type = 2 if inlist(round, 1, 3, 4, 6, 9, 11, 15, 17, 19, 21)
replace round_type = 3 if inlist(round, 5, 7)

*---------------------------------------------------------------*
* 回归（只跑一次，全样本），并对 GPT = DS 做 Wald 检验
*---------------------------------------------------------------*

est clear

* (1) 只控制 round FE（无个体 FE）
reghdfe ytask GPT DS, absorb(round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "No"
estadd local RoundFE "Yes"
est store m1

* (2) 同时控制个体 FE 和 round FE（全样本）
reghdfe ytask GPT DS, absorb(prolificid round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "Yes"
estadd local RoundFE "Yes"
est store m2

* (3) 子样本：r1 < r2（round_type==1）
reghdfe ytask GPT DS if round_type == 1, absorb(prolificid round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "Yes"
estadd local RoundFE "Yes"
est store m3

* (4) 子样本：r1 = r2（round_type==3）
reghdfe ytask GPT DS if round_type == 3, absorb(prolificid round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "Yes"
estadd local RoundFE "Yes"
est store m4

* (5) 子样本：r1 > r2（round_type==2）
reghdfe ytask GPT DS if round_type == 2, absorb(prolificid round) cluster(prolificid)
test GPT = DS
estadd scalar p_wald = r(p)
estadd local IndFE   "Yes"
estadd local RoundFE "Yes"
est store m5

*---------------------------------------------------------------*
* 输出表格（Wald 检验 p 值在表格底部一起汇报）
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

*---------------------------------------------------------------*
* 0. 定义当前路径
*---------------------------------------------------------------*
cd "/Users/youshan/Library/CloudStorage/Dropbox/Revealed Consistency in Food Choices/Replication Code and Data/Results"



import delimited "regress_data_wide_baseline.csv", clear

*-------------------------------------------------------------------------------
* 变量构造
*-------------------------------------------------------------------------------
* 处理组虚拟变量
gen GPT = (condition == 2)
gen DS  = (condition == 3)

* IOS 差异（AI vs Human）
gen diff_ios_gpt = ios_gpt - ios_human
gen diff_ios_ds  = ios_ds  - ios_human

* 交互项（显式生成，便于 esttab 标注）
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

* (3) Pooled: 连续 IOS 交互
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

* (6) Pooled: 连续 IOS 交互
reghdfe ytask DS iosds_x_ds iosh_x_ds if inlist(condition, 1, 3), ///
    absorb(prolificid round) cluster(prolificid)
estadd local indFE   "Yes"
estadd local roundFE "Yes"
est store m6

*===============================================================================
* 输出 LaTeX 表格
*===============================================================================
esttab m1 m2 m3 m4 m5 m6 ///
    using "Table 2.tex", replace ///
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
* Section 1: 交互项的经济学含义 (IOS 一个标准差变化对 ytask 的影响)
*===============================================================================

* 循环参数: 处理组 | IOS 变量 | 交互项 | Pooled 模型 | 样本条件
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

    *--- Step 1: 与回归样本一致, 个体层面去重后计算 IOS 标准差 ---
    preserve
        quietly keep if `sample_`t''
        quietly bysort prolificid: keep if _n == 1
        quietly summarize `iosvar_`t''
        local sd_`t' = r(sd)
        local n_`t'  = r(N)
    restore

    *--- Step 2: 提取交互项系数, 计算 1 SD 效应 (lincom 含 SE / CI) ---
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

*--- 汇总输出 ---
foreach t of local treats {
    di as text "{hline 66}"
    di as text "经济学含义: IOS_`t' × `t'  (Pooled 模型 `model_`t'')"
    di as text "{hline 66}"
    di as text "  去重后个体数                = " as result %9.0f  `n_`t''
    di as text "  IOS_`t' 标准差 (个体层面)   = " as result %9.4f `sd_`t''
    di as text "  交互项系数                  = " as result %9.4f `b_`t''
    di as text "  1 SD 变化对 ytask 的影响    = " as result %9.4f `eff_`t'' ///
       as text "  (se = " as result %6.4f `se_`t'' as text ")"
    di as text "  双侧 p 值                   = " as result %9.4f `p_`t''
    di as text "  95% CI                      = [" as result %8.4f `lo_`t'' ///
       as text ", " as result %8.4f `hi_`t'' as text "]"
}
di as text "{hline 66}"


*===============================================================================
* Section 2: 分组系数差异检验 (z-test, Distant vs. Close)
*===============================================================================

capture program drop coef_compare
program define coef_compare
    * 用法: coef_compare 模型A 模型B 系数名 "标签A" "标签B"
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
    di as text "`coef' 系数比较: `labA' (`mA') vs. `labB' (`mB')"
    di as text "{hline 66}"
    di as text "  `mA' (`labA'):  b = " as result %8.4f `bA' ///
       as text "   se = " as result %7.4f `seA'
    di as text "  `mB' (`labB'):  b = " as result %8.4f `bB' ///
       as text "   se = " as result %7.4f `seB'
    di as text "  系数差异 (bA - bB)  = " as result %8.4f `diff'
    di as text "  差异的标准误        = " as result %8.4f `sed'
    di as text "  z 统计量            = " as result %8.4f `z'
    di as text "  双侧 p 值           = " as result %8.4f `p'
    di as text "  95% CI              = [" as result %8.4f `lo' ///
       as text ", " as result %8.4f `hi' as text "]"
end

coef_compare m1 m2 GPT "Distant" "Close"
coef_compare m4 m5 DS  "Distant" "Close"
di as text "{hline 66}"










clear all

cd "/Users/youshan/Library/CloudStorage/Dropbox/Revealed Consistency in Food Choices/Replication Code and Data/Results"
*===============================================================================
* 0. 数据导入与处理组变量
*===============================================================================
import delimited ///
    "regress_data_wide_baseline.csv", ///
    clear

gen GPT = (condition == 2)
gen DS  = (condition == 3)
	
	
*===============================================================================
* 1. 回归 + 经济学含义 (1 SD of AI intensity)
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

    *--- (a) 回归样本内、个体层面的 AI intensity 标准差 -----------------------
    preserve
        keep if e(sample)
        bysort prolificid: keep if _n == 1     // 每人一条
        qui sum ai_intensity
        local sd_int = r(sd)
    restore

    *--- (b) 1 SD 变化对应的处理效应异质性 (lincom 自动给出 SE 和 CI) ---------
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

    *--- (c) 屏幕上打印一段可读的解释 -----------------------------------------
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

	

	
	
	
	
	
	
	
	
	
/********************************************************************
* 2. 个体 × condition × round 维度：ytask
*    （单次回归 + 系数两两 Wald 检验，双 Panel 输出）
********************************************************************/

*===========================================================
* 0. 路径设置：从当前工作目录读取
*===========================================================
local path "/Users/youshan/Library/CloudStorage/Dropbox/Revealed Consistency in Food Choices/Replication Code and Data/Results"
local filename "Extended Data Table 5.tex"
local caption  "Task Shares in the Minimal and Political Group Experiments"

*===========================================================
* 1. 定义小程序：回归 + Wald 检验 + 存储
*===========================================================
capture program drop run_reg
program define run_reg
    syntax name(name=mname) [if]

    reghdfe ytask H_d AI_s AI_d `if', absorb(prolificid round) cluster(prolificid)
    estadd local IndFE   "Yes"
    estadd local RoundFE "Yes"

    * ---- Wald 检验：系数两两比较 ----
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
* 2. 定义数据准备小程序（两个 study 共用）
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
* 3. 输出表格：Panel (a) Minimal / Panel (b) Political
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

cd "/Users/youshan/Library/CloudStorage/Dropbox/Revealed Consistency in Food Choices/Replication Code and Data/Results"
	

********************************************************************************
* 整合后的回归代码 - 合并 Minimal 与 Political 两个样本
* 输出表格式参考: Extended Data Table 7
********************************************************************************

*------------------------------*
* 1. 读取并合并两个数据集
*------------------------------*

* 读取 Political 样本
import delimited ///
    "regress_data_wide_political.csv", ///
    clear
gen sample = "political"

tempfile political_data
save `political_data'

* 读取 Minimal 样本
import delimited ///
    "regress_data_wide_minimal.csv", ///
    clear
gen sample = "minimal"

* 上下合并
append using `political_data'


* 处理组虚拟变量
gen H_d  = (condition==2)
gen AI_s = (condition==3)
gen AI_d = (condition==4)

*==========================================================*
* Step 3: 回归 (循环: Panel x Measure)
*
* 经济学意义: 交互项系数 x 处理组 closeness 的被试层面 SD
* 注意: 每个被试有 22 rounds 重复观测, 需先按被试去重再算 SD
*==========================================================*

* --- Panel 设定: 处理组 dummy 与对应 condition ---
local dummy_A "H_d"
local dummy_B "AI_s"
local dummy_C "AI_d"
local cond_A  2
local cond_B  3
local cond_C  4

* --- In-group (baseline) closeness 变量 (三种度量) ---
local in_ios  "ios_human_same"
local in_like "hs_like"
local in_care "hs_care"

* --- 处理组 closeness 变量 ---
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

        * 统一变量名, 便于 esttab 跨列对齐
        gen C_in    = `in_`m''
        gen C_treat = `tr_`p'_`m''

        reghdfe ytask ///
            c.C_treat##c.`D' ///
            c.C_in#c.`D' ///
            if condition==1 | condition==`cnd' ///
            , absorb(prolificid round) cluster(prolificid)

        *----------------------------------------------------------*
        * 经济学意义: 1 SD 的 C_treat 变化对处理效应的影响
        *----------------------------------------------------------*
        preserve
            keep if e(sample)                        // 只保留回归实际样本
            duplicates drop prolificid, force  // 每个被试仅保留一行
            * 如只想在处理组内计算 SD, 加: keep if `D'==1
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

        * 存入 estimates, 输出到表格
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
* Step 4: 输出 LaTeX 表格
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

cd "/Users/youshan/Library/CloudStorage/Dropbox/Revealed Consistency in Food Choices/Replication Code and Data/Results"
	

********************************************************************************
* 整合后的回归代码 - 合并 Minimal 与 Political 两个样本
* 输出表格式参考: Extended Data Table 8
********************************************************************************

*------------------------------*
* 1. 读取并合并两个数据集
*------------------------------*

* 读取 Political 样本
import delimited ///
    "regress_data_wide_political.csv", ///
    clear
gen sample = "political"

tempfile political_data
save `political_data'

* 读取 Minimal 样本
import delimited ///
    "regress_data_wide_minimal.csv", ///
    clear
gen sample = "minimal"

* 上下合并
append using `political_data'


encode prolificid, gen(newid)

* 处理组虚拟变量
gen H_d  = (condition == 2)   // Human, out-group
gen AI_s = (condition == 3)   // AI, in-group
gen AI_d = (condition == 4)   // AI, out-group

*------------------------------*
* 2. 循环运行六个回归
*    每列使用一种 AI usage intensity 度量
*------------------------------*

local intvars ai_days1 ai_days2 ai_hours1 ai_hours2 ///
              improvement_scores1 improvement_scores2

local i = 1
foreach v of local intvars {

    gen ai_int = `v'   // 统一变量名，保证各列系数名一致

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
* 3. 输出 LaTeX 表格
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

cd "/Users/youshan/Library/CloudStorage/Dropbox/Revealed Consistency in Food Choices/Replication Code and Data/Results"	
********************************************************************************
* 合并两个数据集
********************************************************************************

* 读取第一个数据集 (Minimal Sample)
import delimited ///
    "regress_data_wide_minimal.csv", ///
    clear

gen study = 1
tostring prolificid, replace force
replace prolificid = "min_" + prolificid

tempfile minimal_data
save `minimal_data'

* 读取第二个数据集 (Political Sample)
import delimited ///
    "regress_data_wide_political.csv", ///
    clear

gen study = 2
tostring prolificid, replace force
replace prolificid = "pol_" + prolificid

* 合并
append using `minimal_data'

* 生成数值型 id 用于固定效应
encode prolificid, gen(id_num)

********************************************************************************
* 数据准备与回归
********************************************************************************

eststo clear

* 处理组虚拟变量
gen H_d  = (condition==2)
gen AI_s = (condition==3)
gen AI_d = (condition==4)

* 变量顺序与参考表一致：
* Writing / Practical Guidance / Technical Help / Multimedia /
* Seeking Information / Self-Expression / Other-Unknown
local varlist "writing practicalguidance technicalhelp multimedia seekinginformation expressionandinteraction other_use"

local i = 1
foreach var of local varlist {
    gen temp_exp = `var'

    reghdfe ytask c.temp_exp##c.H_d c.temp_exp##c.AI_s c.temp_exp##c.AI_d, ///
        absorb(id_num round) cluster(id_num)

    * --- 计算并存储 AI_activity 的均值（估计样本内）---
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
* 输出 LaTeX 表格
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


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
cd "/Users/youshan/Library/CloudStorage/Dropbox/Revealed Consistency in Food Choices/Replication Code and Data/Results"		
	
	********************************************************************************
* Table: Task Shares and Perceived Relationship with AI
* Pooled Minimal + Political samples; two-panel layout (cols 1-4 / 5-9)
********************************************************************************

eststo clear

********************************************************************************
* Step 1: 读取并准备 Minimal Sample
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
* Step 2: 读取并准备 Political Sample
********************************************************************************
import delimited ///
    "regress_data_wide_political.csv", ///
    clear

gen study = 2
tostring prolificid, replace
replace prolificid = "pol_" + prolificid

********************************************************************************
* Step 3: 合并两个数据集
********************************************************************************
append using `minimal_data'

* 处理组虚拟变量
gen H_d  = (condition==2)
gen AI_s = (condition==3)
gen AI_d = (condition==4)

* 聚类用数值型 id
encode prolificid, gen(id_num)

********************************************************************************
* Step 4: 运行 9 个回归（顺序与表格列一致）
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
* Step 5: 输出 LaTeX 表格（上下两个面板）
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



