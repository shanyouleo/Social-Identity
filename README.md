# Replication Package: "Social Identity and Human-AI Task Allocation"

**Authors:** Yiting Chen, You Shan, and Shuangyu Yang

## Overview

This replication package contains the raw data and code required to reproduce all figures and tables in the manuscript "Social Identity and Human-AI Task Allocation". The paper reports three pre-registered online experiments conducted on Prolific, in which participants allocate tasks between a human worker and an alternative worker (another human, ChatGPT, or DeepSeek) under exogenously varied relative productivity: a baseline experiment with no induced group identity (N = 301), a minimal-group experiment in which identities are induced through the minimal-group paradigm (N = 297), and a political-group experiment in which identities are based on political affiliation (N = 299).

## Raw Data

The `Raw Data/` folder contains two Excel files per experiment. For the baseline experiment, `301-decision-0628.xlsx` records the round-by-round allocation decisions across the 22 budget-line rounds (prices, endowments, chosen allocations, understanding-test responses, and timestamps), and `301-questionnaire-0628.xlsx` contains the post-experiment survey. For the minimal-group experiment, the corresponding files are `record-2026-01-16 Minimal-Main-297人次.xlsx` (decisions) and `questionnaire-2026-01-16 Minimal-Main-297人次.xlsx` (survey). For the political-group experiment, they are `final-record-2026-01-14 Political-Main-299人次.xlsx` (decisions) and `final-questionnaire-2026-01-14 Political-Main-299人次.xlsx` (survey). The questionnaire files include Inclusion of Other in the Self (IOS) measures of perceived closeness, AI usage at and outside of work, and demographic characteristics. Participants are identified only by anonymized Prolific IDs; no personally identifying information is included.

## Code and Replication Workflow

Replication proceeds in two sequential steps. **Step 1 (Python).** Run each of the three Jupyter notebooks—`python_baseline_nhb.ipynb`, `python_minimal_nhb.ipynb`, and `python_political_nhb.ipynb`—from top to bottom, in any order. Each notebook (i) imports the corresponding decision and questionnaire files from `Raw Data/`; (ii) reshapes the 22 rounds of allocation decisions and computes the share of tasks allocated to each worker type, with pairwise statistical comparisons; (iii) computes monetary losses relative to the payoff-maximizing allocation; (iv) computes Afriat's Critical Cost Efficiency Index (CCEI) using the `revpref` package and benchmarks it against simulated random behavior; (v) analyzes other–other allocations between in-group and out-group recipients (minimal and political notebooks only); (vi) classifies participants by allocation patterns and relates the classification to IOS measures; and (vii) merges the decision-level panel with questionnaire variables and exports the intermediate regression datasets `regress_data_wide_{baseline|minimal|political}.csv` to `Results/`. All figures are saved directly to `Results/` at this step. **Step 2 (Stata).** Open `Regression.do`, update the `cd "..."` path at the top of each section to the location of this folder, confirm that the three `regress_data_wide_*.csv` files are available (copies are provided so this step can be run independently), and execute the do-file. It estimates linear models with individual and round fixed effects via `reghdfe`, clusters standard errors at the individual level, reports Wald tests of coefficient equality, and exports all regression tables in LaTeX format to `Results/`.

## Mapping of Exhibits to Programs

The baseline notebook (`python_baseline_nhb.ipynb`) produces Fig. 2(a), Fig. 2(b), Fig. 3, Extended Data Fig. 1(a)–(b), Extended Data Fig. 2(a), and Extended Data Fig. 3(a). The minimal-group notebook (`python_minimal_nhb.ipynb`) produces Fig. 4(a), Extended Data Fig. 2(b), 3(b), 4(a), 5(a), 6(a), 7(a), and Extended Data Table 6(a). The political-group notebook (`python_political_nhb.ipynb`) produces Fig. 4(b), Extended Data Fig. 2(c), 3(c), 4(b), 5(b), 6(b), 7(b), and Extended Data Table 6(b). The Stata do-file (`Regression.do`) produces Table 2 and Extended Data Tables 3, 4, 5, 7, 8, and 9. Extended Data Table 2 (sample demographics) is reported in the demographics sections of the three notebooks. All output files are written to `Results/` under names matching the exhibit labels in the manuscript.

## Computational Requirements

Step 1 requires Python 3.9+ with Jupyter and the packages `pandas`, `numpy`, `scipy`, `matplotlib`, `seaborn`, `pingouin`, and `revpref`. Step 2 requires Stata 16 or later with the community-contributed packages `reghdfe` and `estout` (install via `ssc install reghdfe` and `ssc install estout`). All analyses run on a standard desktop computer; the Monte Carlo CCEI simulations are the most time-consuming component, and each notebook completes within approximately 10–30 minutes.

## Contact

For questions regarding this replication package, please contact Yiting Chen (yitingchen26@gmail.com), You Shan (shanyou@ustc.edu.cn), or Shuangyu Yang (shuangyuyang929@gmail.com).
