# Bernacer_et_al_longitudinal_effort
Data, analysis codes and relevant files of Bernacer et al 2019, about longitudinal changes in effort-based decision making after habit acquisition.

In the ROOT folder there are the following files:
1) Dataset.dta: Stata spreadsheet containing data for most analyses of the intervention sample (volunteers that finished the physical activity plan).
2) dataset_for_ANOVA_ctrl_intervention.dta: Stata spreadsheet in long format to compare effort discounting in the intervention and the "control" samples.
3) dataset_logistic_mixed_model.dta: Stata spreadsheet to analyze the effect of task attributes on individual decisions.
4) dataset_transformations_Khyp.dta: Stata spreadsheet to test which transformation of effort-related hyperbolic K yielded the best approximation to normality
5) License: MIT license
6) prepare_regressor_files_for_FSL.m: Matlab code which takes as input the log files from the in-scanner task and produces the FSL 3-column files to use as regressors.
7) README: this file.
8) subjective_value_hyperbolic.m: Matlab code that puts SV of each pair of options (of the in-scanner task) within the log files containing task presentation, individual decisions, etc.


In addition, there are the following folders. Each contains a README file with further information:

1) in_scanner_task: all relevant files pertaining the in-scanner effort- and risk-discounting task
2) out_of_scanner_tasks: all relevant files pertaining the two out-of-scanner tasks (effort and risk discounting).
3) paradigms: Matlab codes and supporting files to run the experimental paradigms (in-scanner and out-of-scanner tasks). They are coded in Cogent 2000.
4) stata_logs: txt files containing the commands and results of all statistical analyses contained in the manuscript.
