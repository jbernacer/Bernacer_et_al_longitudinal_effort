%This script puts the subjective value, effort discounting and risk
%discounting into the task_logs. These come from the hyperbolic
%adjustment.
%These task logs, one for each session (3), visit (2: pre and post habit) and subject (19)
%contain 105 rows (105 events per session) and the following columns:
%1) Trial number
%2) Trial onset time (in ms)
%3) Option on the left ('X_Y':X=probability of winning;Y=minutes
%running')
%4) Option on the right (idem)
%5) Choice
%6) Decision onset (ms)
%7) Response time (ms: column 6 minus column 2)

%The output is one matrix (per subject, per session, per time point (PRE or
%POST) including the seven columns mentioned above, as well as:
%8) Subjective value (30 € * Effort discounting * Risk discounting) of
%chosen option
%9) Effort discounting of chosen option
%10) Risk discounting of chosen option
%11) Subjective value of non-chosen option
%12) Effort discounting of non-chosen option
%13) Risk discounting of non-chosen option

clear all
clc

pre_or_post=input('Do you want to run PRE or POST? (Type PRE or POST)  ','s');
  
file_K_effort=strcat(pwd,'\behavioral\effort\',pre_or_post,'_effort_discounting_constants_intervention.mat');
file_K_risk=strcat(pwd,'\behavioral\risk\',pre_or_post,'_risk_discounting_constants_intervention.mat');
load(file_K_effort);
load(file_K_risk);
K_effort=effort_discounting_constants(:,2);
K_risk=risk_discounting_constants(:,2);

efforts=[10 15 20 25 30]; %Minutes running
probs=[70 60 50 40 30]; %Probability of winning
odds_against=100-probs;
E_DF=zeros(1,5);
P_DF=zeros(1,5);
subjects=1:19;


for sub=1:length(subjects)

    subject=sub;
    E_DF(sub,:)=(1./(1+(K_effort(sub).*efforts)));
    P_DF(sub,:)=(1./(1+(K_risk(sub).*odds_against)));
    
    filename=strcat(pwd,'\fmri\task_logs\',pre_or_post,'_fmri_task_log_sub',num2str(subject),'.mat');
    load(filename)
    session_1=all_sessions_fmri{1,1}.results_matrix;
    session_2=all_sessions_fmri{2,1}.results_matrix;
    session_3=all_sessions_fmri{3,1}.results_matrix;
    results_matrix=zeros(105,13);
    for session=1:3
        if session==1
            results_matrix=session_1;
        elseif session==2
            results_matrix=session_2;
        elseif session==3
            results_matrix=session_3;
        end
    
    sv=zeros(105,1);
    sv_no=zeros(105,1);
    final_sv=zeros(105,1);
    
    for trial=1:length(results_matrix)
        if strcmp(results_matrix(trial,5),'LEFT')==1 %If option on the left was chosen
            pair=regexp(results_matrix(trial,3),'_','split'); %Record probability and effort of left option as chosen
            pair_no=regexp(results_matrix(trial,4),'_','split'); %Record prob and effort of right option as non-chosen
        elseif strcmp(results_matrix(trial,5),'RIGHT')==1 %If option of the right was chosen
            pair=regexp(results_matrix(trial,4),'_','split'); %Record prob and effort of right option as chosen
            pair_no=regexp(results_matrix(trial,3),'_','split'); %Record prob and effort of left option as non-chosen
        else
            pair=regexp('NO_NO','_','split'); %If no response, do not record prob or effort level
            pair_no=regexp('NO_NO','_','split');
        end
        Probability=pair{1,1}(1,1); %Probability of chosen option
        Probability_no=pair_no{1,1}(1,1); %Probability of non-chosen option
        Effort=pair{1,1}(1,2); %Effort of chosen option
        Effort_no=pair_no{1,1}(1,2); %Effort of non-chosen option
        
        %This is to calculate effort discounting of the chosen option
        if strcmp(Effort,'10')==1
            sv(trial)=30*E_DF(sub,1);
            results_matrix{trial,9}=E_DF(sub,1); %Record effort discounting of chosen option on column 9
        elseif strcmp(Effort,'15')==1
            sv(trial)=30*E_DF(sub,2);
            results_matrix{trial,9}=E_DF(sub,2);
        elseif strcmp(Effort,'20')==1
            sv(trial)=30*E_DF(sub,3);
            results_matrix{trial,9}=E_DF(sub,3);
        elseif strcmp(Effort,'25')==1
            sv(trial)=30*E_DF(sub,4);
            results_matrix{trial,9}=E_DF(sub,4);
        elseif strcmp(Effort,'30')==1
            sv(trial)=30*E_DF(sub,5);
            results_matrix{trial,9}=E_DF(sub,5);
        end
        
        %This is to calculate effort discounting of non-chosen option
        if strcmp(Effort_no,'10')==1
            sv_no(trial)=30*E_DF(sub,1);
            results_matrix{trial,12}=E_DF(sub,1); %Record effort discounting of non-chosen option on column 12
        elseif strcmp(Effort_no,'15')==1
            sv_no(trial)=30*E_DF(sub,2);
            results_matrix{trial,12}=E_DF(sub,2);
        elseif strcmp(Effort_no,'20')==1
            sv_no(trial)=30*E_DF(sub,3);
            results_matrix{trial,12}=E_DF(sub,3);
        elseif strcmp(Effort_no,'25')==1
            sv_no(trial)=30*E_DF(sub,4);
            results_matrix{trial,12}=E_DF(sub,4);
        elseif strcmp(Effort_no,'30')==1
            sv_no(trial)=30*E_DF(sub,5);
            results_matrix{trial,12}=E_DF(sub,5);
        end
        
        %This is to calculate prob discounting and final SV for chosen
        %option
        if strcmp(Probability,'30')==1
            final_sv(trial)=sv(trial)*P_DF(sub,5);
            results_matrix{trial,8}=sv(trial)*P_DF(sub,5); %SV of chosen option is recorded in column 8
            results_matrix{trial,10}=P_DF(sub,5); %Risk discounting of chosen option is recorded in column 10
        elseif strcmp(Probability,'40')==1
            final_sv(trial)=sv(trial)*P_DF(sub,4);
            results_matrix{trial,8}=sv(trial)*P_DF(sub,4);
            results_matrix{trial,10}=P_DF(sub,4);
        elseif strcmp(Probability,'50')==1
            final_sv(trial)=sv(trial)*P_DF(sub,3);
            results_matrix{trial,8}=sv(trial)*P_DF(sub,3);
            results_matrix{trial,10}=P_DF(sub,3);
        elseif strcmp(Probability,'60')==1
            final_sv(trial)=sv(trial)*P_DF(sub,2);
            results_matrix{trial,8}=sv(trial)*P_DF(sub,2);
            results_matrix{trial,10}=P_DF(sub,2);
        elseif strcmp(Probability,'70')==1
            final_sv(trial)=sv(trial)*P_DF(sub,1);
            results_matrix{trial,8}=sv(trial)*P_DF(sub,1);
            results_matrix{trial,10}=P_DF(sub,1);
        
        end
                
        %This is to calculate prob discounting and final sv of non-chosen option
        if strcmp(Probability_no,'30')==1
            results_matrix{trial,11}=sv_no(trial)*P_DF(sub,5); %SV of non-chosen option is recorded in column 11
            results_matrix{trial,13}=P_DF(sub,5); %Risk discounting of non-chosen option is in column 13
        elseif strcmp(Probability_no,'40')==1
            results_matrix{trial,11}=sv_no(trial)*P_DF(sub,4);
            results_matrix{trial,13}=P_DF(sub,4);
        elseif strcmp(Probability_no,'50')==1
            results_matrix{trial,11}=sv_no(trial)*P_DF(sub,3);
            results_matrix{trial,13}=P_DF(sub,3);
        elseif strcmp(Probability_no,'60')==1
            results_matrix{trial,11}=sv_no(trial)*P_DF(sub,2);
            results_matrix{trial,13}=P_DF(sub,2);
        elseif strcmp(Probability_no,'70')==1
            results_matrix{trial,11}=sv_no(trial)*P_DF(sub,1);
            results_matrix{trial,13}=P_DF(sub,1);
        end
             
    end %of trials
    
    if session==1
            results_matrix_s1=results_matrix;
    elseif session==2
            results_matrix_s2=results_matrix;
    elseif session==3
            results_matrix_s3=results_matrix;
    end    
     
                
    end %of sessions     
   
    matrix_name_1=strcat(pwd,'\fmri\task_logs\',pre_or_post,'_sub_',num2str(subject),'_subjective_value_session_1.mat');
    save(matrix_name_1,'results_matrix_s1');
    matrix_name_2=strcat(pwd,'\fmri\task_logs\',pre_or_post,'_sub_',num2str(subject),'_subjective_value_session_2.mat');
    save(matrix_name_2,'results_matrix_s2');
    matrix_name_3=strcat(pwd,'\fmri\task_logs\',pre_or_post,'_sub_',num2str(subject),'_subjective_value_session_3.mat');
    save(matrix_name_3,'results_matrix_s3');
    
    
end %of subjects


        
        
        
        
        
    
    
    
    
    
    
    


    
