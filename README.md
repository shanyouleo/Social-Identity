# "Social Identity and Human-AI Task Allocation"

**Authors:** Yiting Chen, You Shan, and Shuangyu Yang

## Overview

This replication package contains the raw data and code required to reproduce all figures and tables in the manuscript "Social Identity and Human-AI Task Allocation". The paper reports three pre-registered online experiments conducted on Prolific.

## Raw Data

The `Raw Data/` folder contains two Excel files per experiment. For the baseline experiment, `decision Baseline.xlsx` records the round-by-round allocation decisions across the 22 budget-line rounds (prices, endowments, chosen allocations), and `questionnaire Baseline.xlsx` contains the post-experiment survey. For the minimal-group experiment, the corresponding files are `decision Minimal.xlsx` (decisions) and `questionnaire Minimal.xlsx` (survey). For the political-group experiment, they are `decision Political.xlsx` (decisions) and `questionnaire Political.xlsx` (survey). The survey files include Inclusion of Other in the Self (IOS) measures of perceived closeness, AI usage at and outside of work, and demographic characteristics, and so on. Participants are identified only by anonymized Prolific IDs; no personally identifying information is included.

## Code and Replication Workflow

Replication proceeds in two sequential steps. **Step 1 (Python).** Run each of the three Jupyter notebooks—`python_baseline.ipynb`, `python_minimal.ipynb`, and `python_political.ipynb`—from top to bottom, in any order. Each notebook (i) imports the corresponding decision and questionnaire files from `Raw Data/`; (ii) reshapes the 22 rounds of allocation decisions and computes the share of tasks allocated to each worker type, with pairwise statistical comparisons; (iii) computes monetary losses; (iv) computes Afriat's Critical Cost Efficiency Index (CCEI) using the `revpref` package; (v) analyzes other–other allocations (minimal and political notebooks only); (vi) classifies participants by allocation patterns; and (vii) merges the decision-level panel with questionnaire variables and exports the intermediate regression datasets `regress_data_wide_{baseline|minimal|political}.csv` to `Results/`. All figures are saved directly to `Results/` at this step. **Step 2 (Stata).** Open `Regression.do`, confirm that the three `regress_data_wide_*.csv` files are available, and execute the do-file. It exports all regression tables in LaTeX format to `Results/`.

## Mapping of Exhibits to Programs

The baseline notebook (`python_baseline.ipynb`) produces Fig.2(a), Fig.2(b), Fig.3, Fig.S1(a), Fig.S1(b), Fig.S2(a), and Fig.S3(a). The minimal-group notebook (`python_minimal.ipynb`) produces Fig.4(a), Fig.S2(b), Fig.S3(b), Fig.S4(a), Fig.S5(a), Fig.S6(a), Fig.S7(a), and Table S6(a). The political-group notebook (`python_political.ipynb`) produces Fig.4(b), Fig.S2(c), Fig.S3(c), Fig.S4(b), Fig.S5(b), Fig.S6(b), Fig.S7(b), and Table S6(b). The Stata do-file (`Regression.do`) produces Table 2 and Table S3, Table S4, Table S5, Table S7, Table S8, and Table S9. Table S2 (sample demographics) is reported in the demographics sections of the three notebooks. All output files are written to `Results/` under names matching the exhibit labels in the manuscript.

## Computational Requirements

Step 1 requires Python 3.9+ with Jupyter. Step 2 requires Stata 16 SE or later.

## Contact

For questions regarding this replication package, please contact Yiting Chen (yitingchen26@gmail.com), You Shan (shanyou@ustc.edu.cn), or Shuangyu Yang (shuangyuyang929@gmail.com).
