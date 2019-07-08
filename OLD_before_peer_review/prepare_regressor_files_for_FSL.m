%This script prepares the txt files for the explanatory
%variables in FSL. The output can be also used easily in Matlab.

%In FSL, information about regressors in the GLM are included (among other
%ways) as txt files with 3 columns: 1) onset of the event; 2) duration of
%the event; 3) weight of the regressor (1 for boxcar, a different number
%for parameterized regressors) --this should be mean-centered

%The input of this script is the task logs including subjective value and
%discounting factors, produced as the output from
%"subjective_value_hyperbolic.m".

%This script prepares all GLM regressor files as described in the paper
%(excluding the PPI analysis). The regressors or explanatory variables
%(EVs) are as follows:
%1) Task onset, boxcar
%2) Control events, boxcar
%3) No-Risk No-effort events [(30€,100%,0min) vs (30€,0%,0min)]
%4) No-Risk Maximum-effort events [(30€,100%,35min) vs (30€,0%,0min)]
%5) Difference in Subjective Value (SV): time locked to the task onset, modulated by SVchosen-SVunchosen
%6) Difference in effort discounting (ED): time locked to the task onset, modulated by EDchosen-EDunchosen
%7) Difference in risk discounting (PD): time locked to the task onset, modulated by PDchosen-PDunchosen

clear all
clc

subjects=1:19;

pre_or_post=input('Do you want to run PRE or POST? (Type PRE or POST): ','s');
duration=2; %Duration of all events is fixed to 2 seconds.

for sub=1:length(subjects)
    subject=num2str(subjects(sub));

filename_s1=strcat(pwd,'\fmri\task_logs\',pre_or_post,'_sub_',num2str(subject),'_subjective_value_session_1.mat');
filename_s2=strcat(pwd,'\fmri\task_logs\',pre_or_post,'_sub_',num2str(subject),'_subjective_value_session_2.mat');
filename_s3=strcat(pwd,'\fmri\task_logs\',pre_or_post,'_sub_',num2str(subject),'_subjective_value_session_3.mat');

% First, read the results_matrix_value for the particular session

for sesion=1:3

    if sesion==1
    load (filename_s1);
    results_matrix=results_matrix_s1;
    t0=results_matrix{1,2};
    for m=1:105 ; results_matrix{m,2}=(results_matrix{m,2}-t0)/1000 ; end %Set all onsets relative to the first one (in seconds)
    
    elseif sesion==2
    load (filename_s2);
    results_matrix=results_matrix_s2;
    t0=results_matrix{1,2};
    for m=1:105 ; results_matrix{m,2}=(results_matrix{m,2}-t0)/1000 ; end
    
    elseif sesion==3
    load (filename_s3);
    results_matrix=results_matrix_s3;
    t0=results_matrix{1,2};
    for m=1:105 ; results_matrix{m,2}=(results_matrix{m,2}-t0)/1000 ; end
    end

%Prepare output matrices:
task=zeros(60,3);
control=zeros(15,3);
NRNE=zeros(15,3);
NRME=zeros(15,3);
task_SV=zeros(60,3);
task_ED=zeros(60,3);
task_PD=zeros(60,3);
ts=1;
c=1;
nrne=1;
nrme=1;
ts_SV=1;
ts_ED=1;
ts_PD=1;

for trial=1:105
    
    if strcmp(results_matrix(trial,3),'motor_control')==1 || strcmp(results_matrix(trial,3),'motor_control_0')==1
        control(c,1)=results_matrix{trial,2};
        c=c+1;
        
    elseif strcmp(results_matrix(trial,3),'100_0')==1 || strcmp(results_matrix(trial,3),'0_0')==1
        NRNE(nrne,1)=results_matrix{trial,2};
        nrne=nrne+1;
        
    elseif strcmp(results_matrix(trial,3),'100_35')==1 || strcmp(results_matrix(trial,3),'0_35')==1
        NRME(nrme,1)=results_matrix{trial,2};
        nrme=nrme+1;        
        
    else
        task(ts,1)=results_matrix{trial,2};
        task_SV(ts_SV,1)=results_matrix{trial,2};
        task_ED(ts_ED,1)=results_matrix{trial,2};
        task_PD(ts_PD,1)=results_matrix{trial,2};
        %If no option is chosen:
        if strcmp(results_matrix{trial,5},'NO RESPONSE')==1
            task_SV(ts_SV,3)=0; 
            task_ED(ts_ED,3)=0;
            task_PD(ts_PD,3)=0;
        else
        
        task_SV(ts_SV,3)=results_matrix{trial,8}-results_matrix{trial,11};
        task_ED(ts_ED,3)=results_matrix{trial,9}-results_matrix{trial,12};
        task_PD(ts_PD,3)=results_matrix{trial,10}-results_matrix{trial,13};
        end   
        
        ts=ts+1;        
        ts_SV=ts_SV+1;
        ts_ED=ts_ED+1;
        ts_PD=ts_PD+1;
       
        
    end
end

%Adding durations:
task(:,2)=duration;
control(:,2)=duration;
NRNE(:,2)=duration;
NRME(:,2)=duration;
task_SV(:,2)=duration;
task_ED(:,2)=duration;
task_PD(:,2)=duration;

%Adding third column to boxcar regressors (=1):
task(:,3)=ones(60,1);
control(:,3)=ones(15,1);
NRNE(:,3)=ones(15,1);
NRME(:,3)=ones(15,1);

%Demeaning modulated regressors:
mean_value_SV=nanmean(task_SV(:,3));
demeaned_task_SV=task_SV;
pre_demeaned_task_SV=task_SV(:,3)-mean_value_SV;
max_value_SV=max(pre_demeaned_task_SV);
demeaned_task_SV(:,3)=pre_demeaned_task_SV./max_value_SV; %This puts all the values relative to 1

mean_value_ED=nanmean(task_ED(:,3));
demeaned_task_ED=task_ED;
pre_demeaned_task_ED=task_ED(:,3)-mean_value_ED;
max_value_ED=max(pre_demeaned_task_ED);
demeaned_task_ED(:,3)=pre_demeaned_task_ED./max_value_ED; %This puts all the values relative to 1

mean_value_PD=nanmean(task_PD(:,3));
demeaned_task_PD=task_PD;
pre_demeaned_task_PD=task_PD(:,3)-mean_value_PD;
max_value_PD=max(pre_demeaned_task_PD);
demeaned_task_PD(:,3)=pre_demeaned_task_PD./max_value_PD; %This puts all the values relative to 1

%Saving txt files
session=num2str(sesion);

filename_task=strcat(pwd,'\fmri\GLM_regressors\sub_',subject,'_task_boxcar_session_',session,'_',pre_or_post,'.txt');
filename_control=strcat(pwd,'\fmri\GLM_regressors\sub_',subject,'_control_session_',session,'_',pre_or_post,'.txt');
filename_NRNE=strcat(pwd,'\fmri\GLM_regressors\sub_',subject,'_NRNE_session_',session,'_',pre_or_post,'.txt');
filename_NRME=strcat(pwd,'\fmri\GLM_regressors\sub_',subject,'_NRME_session_',session,'_',pre_or_post,'.txt');
filename_SV=strcat(pwd,'\fmri\GLM_regressors\sub_',subject,'_task_SV_session_',session,'_',pre_or_post,'.txt');
filename_ED=strcat(pwd,'\fmri\GLM_regressors\sub_',subject,'_task_ED_session_',session,'_',pre_or_post,'.txt');
filename_PD=strcat(pwd,'\fmri\GLM_regressors\sub_',subject,'_task_PD_session_',session,'_',pre_or_post,'.txt');

dlmwrite(filename_task,task,'delimiter','\t');
dlmwrite(filename_control,control,'delimiter','\t');
dlmwrite(filename_NRNE,NRNE,'delimiter','\t');
dlmwrite(filename_NRME,NRME,'delimiter','\t');
dlmwrite(filename_SV,demeaned_task_SV,'delimiter','\t');
dlmwrite(filename_ED,demeaned_task_ED,'delimiter','\t');
dlmwrite(filename_PD,demeaned_task_PD,'delimiter','\t');


end %of sessions

end %of subjects




