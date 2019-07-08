This folder includes individual results of the out-of-scanner task to assess effort-discounting.

Separate files for before (PRE) and after (POST) habit acquisition are included.

There are 19 subjects who finished the 3-month physical activity plan, and 13 "control" subjects
who were assessed approximately 3 months after the first evaluation.

The task included a fixed option (5 € in exchange for 0 minutes running) and an alternative option.
For each subject, it was run in two consecutive sessions with 72 trials each. Note that the order of the
trials is randomized in each session and subject.

In the root folder there are two Matlab codes:

best_adjustment_and_group_fitting.m: this script shows which adjustment (hyperbolic, exponential, double exponential
or parabolic) was better for each subject. Besides, it takes the average of individual indifference points and
estimate the best fitting (among thouse discounting functions) for the whole sample. It should be estimated independently
for the intervention and control sample, and for PRE and POST

effort_discounting_estimation.m: this script is used to estimate effort discounting for each subject. Basically it has
three stages: data extraction, estimation of psychometric functions to calculate indifference points, and fitting
to the 4 functions mentioned above to determine which is best.

Briefly, the folders contained here include:
PRE_ and POST_log_results: individual log files of the effort discounting task. 
PRE_ and POST_analyses: all individual and group result files.
psychometric_functions: individual graphs of the psychometric functions used to estimate indifference points.

