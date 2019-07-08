This folder includes individual results of the out-of-scanner task to assess risk-discounting.

Separate files for before (PRE) and after (POST) habit acquisition are included.

There are 19 subjects who finished the 3-month physical activity plan.

The task included a fixed option (5 € for sure) and an alternative option.
For each subject, it was run in two consecutive sessions with 72 trials each. Note that the order of the
trials is randomized in each session and subject.

In the root folder there are two Matlab codes:

risk_best_adjustment_and_group_fitting.m: this script shows which adjustment (hyperbolic, exponential, double exponential
or parabolic) was better for each subject. Besides, it takes the average of individual indifference points and
estimate the best fitting (among thouse discounting functions) for the whole sample. It should be estimated independently
for PRE and POST.

risk_discounting_estimation.m: this script is used to estimate risk discounting for each subject. Basically it has
three stages: data extraction, estimation of psychometric functions to calculate indifference points, and fitting
to the 4 functions mentioned above to determine which is best.

Briefly, the folders contained here include:
PRE_ and POST_log_results: individual log files of the risk discounting task. 
PRE_ and POST_analyses: all individual and group result files.
psychometric_functions: individual graphs of the psychometric functions used to estimate indifference points.

