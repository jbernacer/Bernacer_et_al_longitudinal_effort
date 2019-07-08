%This script takes the log file (.mat) of the behavioral task to estimate
%effort discounting. The input file is a cell array with the following
%information:
% all_sessions{1,1}=1st session, money of the alternative option
% all_sessions{2,1}=2nd session, money of the alternative option
% all_sessions{1,2}=1st session, effort (minutes running) of the alternative option
% all_sessions{2,2}=2nd session, effort (minutes running) of the alternative option
% all_sessions{1,3}=1st session, position on screen of the alternative option
% all_sessions{2,3}=2nd session, position on screen of the alternative option
% all_sessions{1,4}=1st session, choice
% all_sessions{2,4}=2nd session, choice

% The idea is to obtain 4 vectors with length=144 (number of trials in each
% task) indicating the money and effort involved in the "alternative
% option" (fixed option = 5€ with no effort), position of the alternative
% option and choice. Knowing the option chosen for the participant, we
% apply a psychometric function: the probability of choosing the option
% that was actually chosen equals 1/(1+exp(-x(2)*(SV_chosen-SV_unchosen))).
% SV is calculated from a hyperbolic, exponential, double exponential or
% parabolic function. These functions are called in different files, where
% the final log-likelihood is calculated. Back in this file, fmincon finds
% the values )of K and inverse temperature (hyperbolic), c and inverse
% temperature (exponential), beta delta and inverse temperature (double
% exponential) and k (parabolic)) that produces the log-likelihood closer to 0.

% The final part of the script plots the discounting curves and actual
% decisions for each volunteer.

clear all %Clean workspace
clc %Clean "screen"
addpath(pwd); %Include this folder in path

subjects=1:19;

%Send variables to global workspace to use in function files

global position
global choice
global money
global effort
global partial_f
position={};
choice={};

first_position=1;
for subject=1:length(subjects)
    
    volunteer=num2str(subject);
    %volunteer=num2str(15);
    verbose=strcat('Starting subject','  ',volunteer,' of','   ',num2str(max(subjects)));
    disp(verbose)
      
    %Loading input files:
    
        input_data_PRE=strcat('PRE_analyses\PRE_effort_discounting_sub',volunteer,'.mat');
        input_array_PRE=load(input_data_PRE);
        
        
    %Concatenating and organizing both sessions:
    last_position=first_position+143; %72 x 2 sessions =144
    money(first_position:last_position,:)=str2double([input_array_PRE.all_sessions{1,1}; input_array_PRE.all_sessions{2,1}]);
    effort(first_position:last_position,:)=str2double([input_array_PRE.all_sessions{1,2}; input_array_PRE.all_sessions{2,2}]);
    position(first_position:last_position,:)=[input_array_PRE.all_sessions{1,3}; input_array_PRE.all_sessions{2,3}];
    choice(first_position:last_position,:)=[input_array_PRE.all_sessions{1,4}; input_array_PRE.all_sessions{2,4}];
    
    first_position=last_position+1;
    
end
    %Starting maximization of each function (hyperbolic, exponential,
    %double exponential, parabolic). We are using fmincon, since
    %fminsearch offered negative constants in a few cases. fmincon allows a
    %similar maximization constrained to positive values.
    %The final value to be maximized (or minimized) is the log-likelihood.
    
    x0 = [0.2,1]; %Initial values. This is VERY important to obtain appropriate values with fmincon.
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); %Options
    [x,fval] = fmincon(@loglikelihood_hyp,x0,[],[],[],[],[0 0],[10 100],[],opts) %x=estimated constants; fval=best log-likelihood
    PRE_all_subs_hyp(1,1)=x(1); %Hyperbolic K
    PRE_all_subs_hyp(1,2)=x(2); %Beta (inverse temperature)
    PRE_all_subs_hyp(1,3)=fval; %LL
    PRE_LL_all_subs(1,1)=-fval; %LL
    PRE_LL_all_subs(1,2)=-2*PRE_LL_all_subs(1,1)+2*log(2736); %Bayesian Information Criterion (BIC)
    
    y0 = [0.1,1];
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); 
    [y,fval] = fmincon(@loglikelihood_exp,y0,[],[],[],[],[0 0],[10 100],[],opts)
    PRE_all_subs_exp(1,1)=y(1); %Exponential c
    PRE_all_subs_exp(1,2)=y(2); %Beta
    PRE_all_subs_exp(1,3)=fval;
    PRE_LL_all_subs(1,3)=-fval;
    PRE_LL_all_subs(1,4)=-2*PRE_LL_all_subs(1,3)+2*log(2736);
    
    z0 = [3,0.1,1];
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); 
    [z,fval] = fmincon(@loglikelihood_Dexp,z0,[],[],[],[],[0 0 0],[10 50 100],[],opts)
    PRE_all_subs_Dexp(1,1)=z(1); %Double exponential beta
    PRE_all_subs_Dexp(1,2)=z(2); %Double exponential delta
    PRE_all_subs_Dexp(1,3)=z(3); %Inverse temperature (beta)
    PRE_all_subs_Dexp(1,4)=fval;
    PRE_LL_all_subs(1,5)=-fval;
    PRE_LL_all_subs(1,6)=-2*PRE_LL_all_subs(1,5)+3*log(2736);
    
    w0 = [0.000001,1];
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); 
    [w,fval] = fmincon(@loglikelihood_par,w0,[],[],[],[],[0 0],[10 100],[],opts)
    PRE_all_subs_par(1,1)=w(1); %Parabolic K (NOTE THAT a IS FIXED TO 1, because otherwise curves are not realistic!)
    PRE_all_subs_par(1,2)=w(2); %Beta
    PRE_all_subs_par(1,3)=fval;
    PRE_LL_all_subs(1,7)=-fval;
    PRE_LL_all_subs(1,8)=-2*PRE_LL_all_subs(1,7)+2*log(2736);
    
    %What is the best curve?
    
    [I, J]=min(PRE_LL_all_subs(1,[2,4,6,8]));
    if J==1
        PRE_best_curve{1,1}='Hyperbolic';
    elseif J==2
        PRE_best_curve{1,1}='Exponential';
    elseif J==3
        PRE_best_curve{1,1}='Double exp.';
    elseif J==4
        PRE_best_curve{1,1}='Parabolic';
    end
    
    
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PLOTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
% Here, we are going to plot the best fitting of the hyperbolic, exponential, 
% double exponential and parabolic curves, Besides, we will plot actual
% behavior, that is, the actual decisions of each participant in the
% out-of-scanner task. The x axis will show effort (minutes running). The Y
% axis is the fraction of the fixed option, that is, 5 divided by each of
% the amounts presented: 5.25, 9, 14, 20, 30 and 50. The marker indicates
% how many times (out of 4: each effort/money combination was presented 4 times)
% the alternative (effortful) option was chosen. Thus, the curve should go
% below those values where the alternative option was chosen 0 or 1 time,
% above those values where the alternative option was chosen 3 or 4 times,
% and as close as possible to the "indifference points" (2 times).

    for trial=1:length(position)
        
        if strcmp(position{trial,1},choice{trial,1})==1
            alternative_chosen{trial,1}=1;
        else
            alternative_chosen{trial,1}=0;
        end
        
    end %of trial for loop
    
    %Sorting results to organize money and effort levels:
    
    results=[money effort cell2mat(alternative_chosen)];
    sorted_results=sortrows(results,[2 1],{'ascend' 'ascend'});
        
    %We will end up with an array containing 36 (4x3) cells. This
    %corresponds to: a) 6 effort levels; b) 6 money amounts (that makes the
    %36 cells); c) 4x19=76 presentations of each pair; d) 3 columns: money,
    %effort and choice (1=alternative, 0=fixed option, ie 5€ no effort):
   
    array_results=mat2cell(sorted_results,repmat(76,36,1),3);
    
    %Next, we will calculate the probability of choosing the alternative
    %(discounted) option for each money amount and effort level
    
    name_money=zeros(36,1);
    name_effort=zeros(36,1);
    prob_choice=zeros(36,1);
    
    for t=1:36
        
        name_money(t,1)=array_results{t,1}(1,1);
        name_effort(t,1)=array_results{t,1}(1,2);
        sum_choice(t,1)=sum(array_results{t}(:,3));
        
    end
    
    xx=(0:0.5:35)';
    final_k=x(1);
    final_c=y(1);
    final_beta=z(1);
    final_delta=z(2);
    final_apar=1;
    final_kpar=w(1);
    %effort_levels=[5 10 15 20 25 30];
    %fraction_fixed=[5/5.25 5/9 5/14 5/20 5/30 5/50];
    
    sv_predicted_plot(:,1)=(1./(1+(final_k.*xx(:,1))));
    sv_predicted_plot(:,2)=exp(-final_c.*xx(:,1));
    sv_predicted_plot(:,3)=(exp(-final_beta.*xx(:,1))+exp(-final_delta.*xx(:,1)))/2;
    sv_predicted_plot(:,4)=final_apar-(final_kpar.*(xx(:,1)).^2);

    %h=figure;
    ZZ(1:8,1)=76;
    ZZ(1,2:7)=76; %Unimportant. Just to have an extra edge in the color map
    ZZ(2,2:7)=sum_choice(6:6:36,1)'; %Across subjects, times chosen 50€ for each effort level
    ZZ(3,2:7)=sum_choice(5:6:36,1)'; %30€
    ZZ(4,2:7)=sum_choice(4:6:36,1)'; %20€
    ZZ(5,2:7)=sum_choice(3:6:36,1)'; %14€
    ZZ(6,2:7)=sum_choice(2:6:36,1)'; %9€
    ZZ(7,2:7)=sum_choice(1:6:36,1)'; %5.25€
    ZZ(8,2:7)=0; %Unimportant. Just to have an extra edge in the color map
    x_pcolor=[0 5 10 15 20 25 30;0 5 10 15 20 25 30;0 5 10 15 20 25 30;0 5 10 15 20 25 30;0 5 10 15 20 25 30;0 5 10 15 20 25 30;0 5 10 15 20 25 30;0 5 10 15 20 25 30];
    y_pcolor=[0 0 0 0 0 0 0 ; 5/50 5/50 5/50 5/50 5/50 5/50 5/50; 5/30 5/30 5/30 5/30 5/30 5/30 5/30; 5/20 5/20 5/20 5/20 5/20 5/20 5/20; 5/14 5/14 5/14 5/14 5/14 5/14 5/14 ; 5/9 5/9 5/9 5/9 5/9 5/9 5/9; 5/5.25 5/5.25 5/5.25 5/5.25 5/5.25 5/5.25 5/5.25; 1 1 1 1 1 1 1];
    h=pcolor(x_pcolor,y_pcolor,ZZ);
    hold on
    h.FaceColor = 'interp';
    h.MeshStyle='none';
    colorbar
    plot(xx,sv_predicted_plot(:,1),'-','Color','b','LineWidth',5); %Plot hyperbolic fitting
    plot(xx,sv_predicted_plot(:,2),'-','Color','r','LineWidth',5); %Plot exponential fitting
    plot(xx,sv_predicted_plot(:,3),'-','Color',[0 0.5 0],'LineWidth',5); %Plot double exponential fitting
    plot(xx,sv_predicted_plot(:,4),'-','Color',[0.5 0.5 0.5],'LineWidth',5); %Plot parabolic fitting
    ylim([0 1]);
    
%     for k=1:36
%         
%         txt=num2str(sum_choice(k));
%         scatter(name_effort(k),5/name_money(k),30,'k','.','filled'); %Plot observed values without marker!
%         text(name_effort(k),5/name_money(k),txt); %Add number as marker
%     end
    
    output_graph=strcat('PRE_effort_discounting_all_subjects_colormap.fig');
    
savefig(output_graph);
hold off
%close(h)  
            
PRE_average_BIC(:,1)=mean(PRE_LL_all_subs(:,2));
PRE_average_BIC(:,2)=mean(PRE_LL_all_subs(:,4));
PRE_average_BIC(:,3)=mean(PRE_LL_all_subs(:,6));
PRE_average_BIC(:,4)=mean(PRE_LL_all_subs(:,8));
PRE_sum_choice=sum_choice;

%%%%%LET'S START POST

money=[];
effort=[];
position={};
choice={};

first_position=1;
for subject=1:length(subjects)
    
    volunteer=num2str(subject);
    %volunteer=num2str(15);
    verbose=strcat('Starting subject','  ',volunteer,' of','   ',num2str(max(subjects)));
    disp(verbose)
      
    %Loading input files:
            
        input_data_POST=strcat('POST_analyses\POST_effort_discounting_sub',volunteer,'.mat');
        input_array_POST=load(input_data_POST);
        
    %Concatenating and organizing both sesions and time points:
    last_position=first_position+143; %72 x 2=144
    money(first_position:last_position,:)=str2double([input_array_POST.all_sessions{1,1}; input_array_POST.all_sessions{2,1}]);
    effort(first_position:last_position,:)=str2double([input_array_POST.all_sessions{1,2}; input_array_POST.all_sessions{2,2}]);
    position(first_position:last_position,:)=[input_array_POST.all_sessions{1,3}; input_array_POST.all_sessions{2,3}];
    choice(first_position:last_position,:)=[input_array_POST.all_sessions{1,4}; input_array_POST.all_sessions{2,4}];
    
    first_position=last_position+1;
    
end
    %Starting maximization of each function (hyperbolic, exponential,
    %double exponential, parabolic). We are using fmincon, since
    %fminsearch offered negative constants in a few cases. fmincon allows a
    %similar maximization constrained to positive values.
    %The final value to be maximized (or minimized) is the log-likelihood.
    
    x0 = [0.2,1]; %Initial values. This is VERY important to obtain appropriate values with fmincon.
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); %Options
    [x,fval] = fmincon(@loglikelihood_hyp,x0,[],[],[],[],[0 0],[10 100],[],opts) %x=estimated constants; fval=best log-likelihood
    POST_all_subs_hyp(1,1)=x(1); %Hyperbolic K
    POST_all_subs_hyp(1,2)=x(2); %Beta (inverse temperature)
    POST_all_subs_hyp(1,3)=fval; %LL
    POST_LL_all_subs(1,1)=-fval; %LL
    POST_LL_all_subs(1,2)=-2*POST_LL_all_subs(1,1)+2*log(2736); %Bayesian Information Criterion (BIC)
    
    y0 = [0.1,1];
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); 
    [y,fval] = fmincon(@loglikelihood_exp,y0,[],[],[],[],[0 0],[10 100],[],opts)
    POST_all_subs_exp(1,1)=y(1); %Exponential c
    POST_all_subs_exp(1,2)=y(2); %Beta
    POST_all_subs_exp(1,3)=fval;
    POST_LL_all_subs(1,3)=-fval;
    POST_LL_all_subs(1,4)=-2*POST_LL_all_subs(1,3)+2*log(2736);
    
    z0 = [3,0.1,1];
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); 
    [z,fval] = fmincon(@loglikelihood_Dexp,z0,[],[],[],[],[0 0 0],[10 50 100],[],opts)
    POST_all_subs_Dexp(1,1)=z(1); %Double exponential beta
    POST_all_subs_Dexp(1,2)=z(2); %Double exponential delta
    POST_all_subs_Dexp(1,3)=z(3); %Inverse temperature (beta)
    POST_all_subs_Dexp(1,4)=fval;
    POST_LL_all_subs(1,5)=-fval;
    POST_LL_all_subs(1,6)=-2*POST_LL_all_subs(1,5)+3*log(2736);
    
    w0 = [0.000001,1];
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); 
    [w,fval] = fmincon(@loglikelihood_par,w0,[],[],[],[],[0 0],[10 100],[],opts)
    POST_all_subs_par(1,1)=w(1); %Parabolic K (NOTE THAT a IS FIXED TO 1, because otherwise curves are not realistic!)
    POST_all_subs_par(1,2)=w(2); %Beta
    POST_all_subs_par(1,3)=fval;
    POST_LL_all_subs(1,7)=-fval;
    POST_LL_all_subs(1,8)=-2*POST_LL_all_subs(1,7)+2*log(2736);
    
    %What is the best curve?
    
    [I, J]=min(POST_LL_all_subs(1,[2,4,6,8]));
    if J==1
        POST_best_curve{1,1}='Hyperbolic';
    elseif J==2
        POST_best_curve{1,1}='Exponential';
    elseif J==3
        POST_best_curve{1,1}='Double exp.';
    elseif J==4
        POST_best_curve{1,1}='Parabolic';
    end

POST_average_BIC(:,1)=mean(PRE_LL_all_subs(:,2));
POST_average_BIC(:,2)=mean(PRE_LL_all_subs(:,4));
POST_average_BIC(:,3)=mean(PRE_LL_all_subs(:,6));
POST_average_BIC(:,4)=mean(PRE_LL_all_subs(:,8));

%Graph for POST:

   for trial=1:length(position)
        
        if strcmp(position{trial,1},choice{trial,1})==1
            alternative_chosen{trial,1}=1;
        else
            alternative_chosen{trial,1}=0;
        end
        
    end %of trial for loop
    
    %Sorting results to organize money and effort levels:
    
    results=[money effort cell2mat(alternative_chosen)];
    sorted_results=sortrows(results,[2 1],{'ascend' 'ascend'});
        
    %We will end up with an array containing 36 (4x3) cells. This
    %corresponds to: a) 6 effort levels; b) 6 money amounts (that makes the
    %36 cells); c) 4x19=76 presentations of each pair; d) 3 columns: money,
    %effort and choice (1=alternative, 0=fixed option, ie 5€ no effort):
   
    array_results=mat2cell(sorted_results,repmat(76,36,1),3);
    
    %Next, we will calculate the probability of choosing the alternative
    %(discounted) option for each money amount and effort level
    
    name_money=zeros(36,1);
    name_effort=zeros(36,1);
    prob_choice=zeros(36,1);
    
    for t=1:36
        
        name_money(t,1)=array_results{t,1}(1,1);
        name_effort(t,1)=array_results{t,1}(1,2);
        sum_choice(t,1)=sum(array_results{t}(:,3));
        
    end
    
    xx=(0:0.5:35)';
    final_k=x(1);
    final_c=y(1);
    final_beta=z(1);
    final_delta=z(2);
    final_apar=1;
    final_kpar=w(1);
    %effort_levels=[5 10 15 20 25 30];
    %fraction_fixed=[5/5.25 5/9 5/14 5/20 5/30 5/50];
    
    sv_predicted_plot(:,1)=(1./(1+(final_k.*xx(:,1))));
    sv_predicted_plot(:,2)=exp(-final_c.*xx(:,1));
    sv_predicted_plot(:,3)=(exp(-final_beta.*xx(:,1))+exp(-final_delta.*xx(:,1)))/2;
    sv_predicted_plot(:,4)=final_apar-(final_kpar.*(xx(:,1)).^2);
    
    %h=figure;
    ZZ(1:8,:)=76;
    ZZ(1,2:7)=76; %Unimportant. Just to have an extra edge in the color map
    ZZ(2,2:7)=sum_choice(6:6:36,1)'; %Across subjects, times chosen 50€ for each effort level
    ZZ(3,2:7)=sum_choice(5:6:36,1)'; %30€
    ZZ(4,2:7)=sum_choice(4:6:36,1)'; %20€
    ZZ(5,2:7)=sum_choice(3:6:36,1)'; %14€
    ZZ(6,2:7)=sum_choice(2:6:36,1)'; %9€
    ZZ(7,2:7)=sum_choice(1:6:36,1)'; %5.25€
    ZZ(8,2:7)=0; %Unimportant. Just to have an extra edge in the color map
    hh=pcolor(x_pcolor,y_pcolor,ZZ);
    hold on
    hh.FaceColor = 'interp';
    hh.MeshStyle='none';
    colorbar
        
    plot(xx,sv_predicted_plot(:,1),'-','Color','b','LineWidth',5); %Plot hyperbolic fitting
    plot(xx,sv_predicted_plot(:,2),'-','Color','r','LineWidth',5); %Plot exponential fitting
    plot(xx,sv_predicted_plot(:,3),'-','Color',[0 0.5 0],'LineWidth',5); %Plot double exponential fitting
    plot(xx,sv_predicted_plot(:,4),'-','Color',[0.5 0.5 0.5],'LineWidth',5); %Plot parabolic fitting
    ylim([0 1]);
    
%     for k=1:36
%         
%         txt=num2str(sum_choice(k));
%         scatter(name_effort(k),5/name_money(k),30,'k','.','filled'); %Plot observed values without marker!
%         text(name_effort(k),5/name_money(k),txt); %Add number as marker
%     end
    
    output_graph=strcat('POST_effort_discounting_all_subjects_colormap.fig');
    
savefig(output_graph);
hold off
%close(hh)  
POST_sum_choice=sum_choice;


%Saving outputs PRE:
PREPOST_hyp=[PRE_all_subs_hyp ; POST_all_subs_hyp];
PREPOST_exp=[PRE_all_subs_exp ; POST_all_subs_exp];
PREPOST_Dexp=[PRE_all_subs_Dexp ; POST_all_subs_Dexp];
PREPOST_par=[PRE_all_subs_par ; POST_all_subs_par];
PREPOST_BIC=[PRE_average_BIC ; POST_average_BIC];
PREPOST_sum_choice=[PRE_sum_choice ; POST_sum_choice];

save('PRE_vs_POST_effort_hyperbolic_all_subjects.mat','PREPOST_hyp');
save('PRE_vs_POST_effort_exponential_all_subjects.mat','PREPOST_exp');
save('PRE_vs_POST_effort_double_exp_all_subjects.mat','PREPOST_Dexp');
save('PRE_vs_POST_effort_parabolic_all_subjects.mat','PREPOST_par');
save('PRE_vs_POST_effort_BIC_all_subjects.mat','PREPOST_BIC');
save('PRE_vs_POST_effort_sum_alternative_chosen.mat','PREPOST_sum_choice');

%Comparative graphs PRE vs POST for each adjustment:
xx=(0:0.5:35)';
PRE_final_k=PRE_all_subs_hyp(1,1);
PRE_final_c=PRE_all_subs_exp(1,1);
PRE_final_beta=PRE_all_subs_Dexp(1,1);
PRE_final_delta=PRE_all_subs_Dexp(1,2);
PRE_final_apar=1;
PRE_final_kpar=PRE_all_subs_par(1,1);
POST_final_k=POST_all_subs_hyp(1,1);
POST_final_c=POST_all_subs_exp(1,1);
POST_final_beta=POST_all_subs_Dexp(1,1);
POST_final_delta=POST_all_subs_Dexp(1,2);
POST_final_apar=1;
POST_final_kpar=POST_all_subs_par(1,1);

PRE_sv_predicted_plot(:,1)=(1./(1+(PRE_final_k.*xx(:,1))));
PRE_sv_predicted_plot(:,2)=exp(-PRE_final_c.*xx(:,1));
PRE_sv_predicted_plot(:,3)=(exp(-PRE_final_beta.*xx(:,1))+exp(-PRE_final_delta.*xx(:,1)))/2;
PRE_sv_predicted_plot(:,4)=PRE_final_apar-(PRE_final_kpar.*(xx(:,1)).^2);
POST_sv_predicted_plot(:,1)=(1./(1+(POST_final_k.*xx(:,1))));
POST_sv_predicted_plot(:,2)=exp(-POST_final_c.*xx(:,1));
POST_sv_predicted_plot(:,3)=(exp(-POST_final_beta.*xx(:,1))+exp(-POST_final_delta.*xx(:,1)))/2;
POST_sv_predicted_plot(:,4)=POST_final_apar-(POST_final_kpar.*(xx(:,1)).^2);

hyperbolic=figure;
plot(xx,PRE_sv_predicted_plot(:,1),'--','Color','b','LineWidth',5); %Plot hyperbolic fitting PRE
hold on
plot(xx,POST_sv_predicted_plot(:,1),'-','Color','b','LineWidth',5);%Plot hyperbolic POST
ylim([0 1]);
output_graph=strcat('PRE_vs_POST_effort_discounting_hyperbolic.fig');
savefig(output_graph);
hold off
close(hyperbolic)
      
exponential=figure;
plot(xx,PRE_sv_predicted_plot(:,2),'--','Color','b','LineWidth',5); %Plot exponential fitting PRE
hold on
plot(xx,POST_sv_predicted_plot(:,2),'-','Color','b','LineWidth',5);%Plot exponential POST
ylim([0 1]);
output_graph=strcat('PRE_vs_POST_effort_discounting_exponential.fig');
savefig(output_graph);
hold off
close(exponential)
      
double_exp=figure;
plot(xx,PRE_sv_predicted_plot(:,3),'--','Color','b','LineWidth',5); %Plot double exp fitting PRE
hold on
plot(xx,POST_sv_predicted_plot(:,3),'-','Color','b','LineWidth',5);%Plot double exp POST
ylim([0 1]);
output_graph=strcat('PRE_vs_POST_effort_discounting_double_exp.fig');
savefig(output_graph);
hold off
close(double_exp)
      
parabolic=figure;
plot(xx,PRE_sv_predicted_plot(:,4),'--','Color','b','LineWidth',5); %Plot parabolic fitting PRE
hold on
plot(xx,POST_sv_predicted_plot(:,4),'-','Color','b','LineWidth',5);%Plot parabolic POST
ylim([0 1]);
output_graph=strcat('PRE_vs_POST_effort_discounting_parabolic.fig');
savefig(output_graph);
hold off
close(parabolic)