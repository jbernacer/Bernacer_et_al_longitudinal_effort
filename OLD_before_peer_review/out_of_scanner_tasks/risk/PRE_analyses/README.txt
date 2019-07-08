This folder contains all analyses pertaining the risk-discounting task after the physical activity plan.

NOTE: subject 15 was not assessed with the risk-discounting task before the plan.

Many different individual and group files are included.
Sub=intervention sample

[PRE/POST]_effort_discounting_sub#.mat: Matlab files with a cell array including the following information:

all_sessions{1,1}=1st session, money of the alternative option
all_sessions{2,1}=2nd session, money of the alternative option
all_sessions{1,2}=1st session, probability (% of winning) of the alternative option
all_sessions{2,2}=2nd session, probability (% of winning) of the alternative option
all_sessions{1,3}=1st session, position on screen of the alternative option
all_sessions{2,3}=2nd session, position on screen of the alternative option
all_sessions{1,4}=1st session, choice
all_sessions{2,4}=2nd session, choice

[PRE/POST]_risk_discounting_sub#.fig: risk discounting graphs.

Group files:

[PRE/POST]_best_adjustment_risk_intervention.mat: simple matrix with 3 columns:
1) Subject number
2) Best adjustment (1=hyperbolic; 2=exponential; 3=double exponential; 4=parabolic)
3) Adjusted R2 value

[PRE/POST]_intervention_group_risk_discounting.fig: risk discounting graph for each time point

[PRE/POST]_intervention_group_risk_discounting_adjustment.mat: adjusted R2 values for each function.
There is only 1 row and 4 columns (1, hyperbolic; 2, exponential; 3, double exponential; 4, parabolic)

[PRE/POST]_intervention_group_risk_discounting_constants.mat: constants that define each function.
One single row with the following columns: 1) hyperbolic K; 2) exponential c; 3) double exponential beta;
4) double exponential delta; 5) parabolic a; 6) parabolic h.

[PRE/POST]_risk_discounting_factors_intervention.mat: matrix with discounting factors for each subject (rows)
and probability level (columns: 90, 75, 50, 33, 10 and 5% of winning).

[PRE/POST]_risk_indifference_points_intervention.mat: nearly the same, since discounting factors = 5/indifference points.

[PRE/POST]_risk_psychometric_data_intervention.mat: cell array containing all relevant data to estimate
psychometric functions. The array contains one row per subject (19), and 6 columns, one for each effort level.
Each data point is composed of 4 numbers: 1) k constant of the psychometric function; 2) G constant; 3) r0 constant; 4) adjustment (R2)
