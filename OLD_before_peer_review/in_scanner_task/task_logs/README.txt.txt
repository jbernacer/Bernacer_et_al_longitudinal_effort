This folder contains the logs for the in-scanner task, that is, for each subject, session and time point (PRE and
POST), the order in which all events were presented, onset, task pair attributes, etc.

[PRE/POST]_fmri_task_log_sub##: Matlab file cell array with 3 structures, one per session. Each session contains
a matrix with 105 rows (one for each event) and 7 columns:
1) Event number
2) Onset time
3) Option presented on the left: Probability_Effort
4) Option presented on the right: Probability_Effort
5) Choice
6) Time of the decision
7) Response time (column 6 - column 2)

[PRE/POST]_sub_##_subject_value_session_#: Matlab file cell array with 13 columns:
1) to 7) As before
8) Subjective value (30 € * Effort discounting * Risk discounting) of chosen option
9) Effort discounting of chosen option
10) Risk discounting of chosen option
11) Subjective value of non-chosen option
12) Effort discounting of non-chosen option
13) Risk discounting of non-chosen option