%This script takes the log file (.mat) of the behavioral task to estimate
%risk discounting. The input file is a cell array with the following
%information:
% all_sessions{1,1}=1st session, money of the alternative option
% all_sessions{2,1}=2nd session, money of the alternative option
% all_sessions{1,2}=1st session, probability of winning of the alternative option
% all_sessions{2,2}=2nd session, probability of winning of the alternative option
% all_sessions{1,3}=1st session, position on screen of the alternative option
% all_sessions{2,3}=2nd session, position on screen of the alternative option
% all_sessions{1,4}=1st session, choice
% all_sessions{2,4}=2nd session, choice

% The idea is to obtain 4 vectors with length=144 (number of trials in each
% task) indicating the money and probability involved in the "alternative
% option" (fixed option = 5€ with for sure, 100%), position of the alternative
% option and choice. Knowing the option chosen for the participant, we
% apply a psychometric function: the probability of choosing the option
% that was actually chosen = 1/(1+exp(-x(2)*(SV_chosen-SV_unchosen))).
% SV is calculated from a hyperbolic, exponential, double exponential or
% parabolic function. These functions are called in different files, where
% the final log-likelihood is calculated. Back in this file, fmincon finds
% the values of K and inverse temperature (hyperbolic), c and inverse
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
global probability
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
        if subject==15
            input_data_POST=strcat('POST_analyses\POST_risk_discounting_sub',volunteer,'.mat');
            input_array_POST=load(input_data_POST);
            input_array_PRE=load(input_data_POST);
        else
        input_data_PRE=strcat('PRE_analyses\PRE_risk_discounting_sub',volunteer,'.mat');
        input_array_PRE=load(input_data_PRE);
        input_data_POST=strcat('POST_analyses\POST_risk_discounting_sub',volunteer,'.mat');
        input_array_POST=load(input_data_POST);
        end
        
    %Concatenating and organizing both sesions and time points:
    last_position=first_position+287; %72 x 2 sessions x 2 time points=288
    money(first_position:last_position,:)=str2double([input_array_PRE.all_sessions{1,1}; input_array_PRE.all_sessions{2,1}; input_array_POST.all_sessions{1,1}; input_array_POST.all_sessions{2,1}]);
    probability(first_position:last_position,:)=str2double([input_array_PRE.all_sessions{1,2}; input_array_PRE.all_sessions{2,2}; input_array_POST.all_sessions{1,2}; input_array_POST.all_sessions{2,2}]);
    position(first_position:last_position,:)=[input_array_PRE.all_sessions{1,3}; input_array_PRE.all_sessions{2,3}; input_array_POST.all_sessions{1,3}; input_array_POST.all_sessions{2,3}];
    choice(first_position:last_position,:)=[input_array_PRE.all_sessions{1,4}; input_array_PRE.all_sessions{2,4}; input_array_POST.all_sessions{1,4}; input_array_POST.all_sessions{2,4}];
    
    first_position=last_position+1;
    
end
    
    %Starting maximization of each function (hyperbolic, exponential,
    %double exponential, parabolica). We are using fmincon, since
    %fminsearch offered negative constants in a few cases. fmincon allows a
    %similar maximization constrained to positive values.
    %The final value to be maximized (or minimized) is the log-likelihood.
    
    x0 = [0.2,1]; %Initial values. This is VERY important to obtain appropriate values with fmincon.
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); %Options
    [x,fval] = fmincon(@loglikelihood_hyp_risk,x0,[],[],[],[],[0 0],[10 100],[],opts) %x=estimated constants; fval=best log-likelihood
    all_subs_hyp(1,1)=x(1); %Hyperbolic K
    all_subs_hyp(1,2)=x(2); %Beta (inverse temperature)
    all_subs_hyp(1,3)=fval; %LL
    LL_all_subs(1,1)=-fval; %LL
    LL_all_subs(1,2)=-2*LL_all_subs(1,1)+2*log(144); %Bayesian Information Criterion (BIC)
    
    y0 = [0.1,1];
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); 
    [y,fval] = fmincon(@loglikelihood_exp_risk,y0,[],[],[],[],[0 0],[10 100],[],opts)
    all_subs_exp(1,1)=y(1); %Exponential c
    all_subs_exp(1,2)=y(2); %Beta
    all_subs_exp(1,3)=fval;
    LL_all_subs(1,3)=-fval;
    LL_all_subs(1,4)=-2*LL_all_subs(1,3)+2*log(144);
    
    z0 = [3,0.1,1];
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); 
    [z,fval] = fmincon(@loglikelihood_Dexp_risk,z0,[],[],[],[],[0 0 0],[10 50 100],[],opts)
    all_subs_Dexp(1,1)=z(1); %Double exponential beta
    all_subs_Dexp(1,2)=z(2); %Double exponential delta
    all_subs_Dexp(1,3)=z(3); %Inverse temperature (beta)
    all_subs_Dexp(1,4)=fval;
    LL_all_subs(1,5)=-fval;
    LL_all_subs(1,6)=-2*LL_all_subs(1,5)+3*log(144);
    
    w0 = [0.000001,1];
    opts = optimset('MaxFunEvals',50000, 'MaxIter',10000,'TolFun',1e-12,'TolX',1e-12); 
    [w,fval] = fmincon(@loglikelihood_par_risk,w0,[],[],[],[],[0 0],[10 100],[],opts)
    all_subs_par(1,1)=w(1); %Parabolic K (NOTE THAT a IS FIXED TO 1, because otherwise curves are not realistic!)
    all_subs_par(1,2)=w(2); %Beta
    all_subs_par(1,3)=fval;
    LL_all_subs(1,7)=-fval;
    LL_all_subs(1,8)=-2*LL_all_subs(1,7)+2*log(144);
    
    %What is the best curve for this 1?
    
    [I, J]=min(LL_all_subs(1,[2,4,6,8]));
    if J==1
        best_curve{1,1}='Hyperbolic';
    elseif J==2
        best_curve{1,1}='Exponential';
    elseif J==3
        best_curve{1,1}='Double exp.';
    elseif J==4
        best_curve{1,1}='Parabolic';
    end
    
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PLOTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
% % % Here, we are going to plot the best fitting of the hyperbolic, exponential, 
% % % double exponential and parabolic curves, Besides, we will plot actual
% % % behavior, that is, the actual decisions of each participant in the
% % % out-of-scanner task. The x axis will show odds against winning (100 minus probability). The Y
% % % axis is the fraction of the fixed option, that is, 5 divided by each of
% % % the amounts presented: 5.25, 9, 14, 20, 30 and 50. The marker indicates
% % % how many times (out of 4: each prob/money combination was presented 4 times)
% % % the alternative (risky) option was chosen. Thus, the curve should go
% % % below those values where the alternative option was chosen 0 or 1 time,
% % % above those values where the alternative option was chosen 3 or 4 times,
% % % and as close as possible to the "indifference points" (2 times).
% 
%     for trial=1:144
%         
%         if strcmp(position{trial,1},choice{trial,1})==1
%             alternative_chosen{trial,1}=1;
%         else
%             alternative_chosen{trial,1}=0;
%         end
%         
%     end %of trial for loop
%     
%     %Sorting results to organize money and risk levels:
%     
%     results=[money probability cell2mat(alternative_chosen)];
%     sorted_results=sortrows(results,[2 1],{'ascend' 'ascend'});
%         
%     %We will end up with an array containing 36 (4x3) cells. This
%     %corresponds to: a) 6 probability levels; b) 6 money amounts (that makes the
%     %36 cells); c) 4 presentations of each pair; d) 3 columns: money,
%     %probability and choice (1=alternative, 0=fixed option, ie 5€ no risk):
%    
%     array_results=mat2cell(sorted_results,repmat(4,36,1),3);
%     
%     %Next, we will calculate the probability of choosing the alternative
%     %(discounted) option for each money amount and probability level
%     
%     name_money=zeros(36,1);
%     name_probability=zeros(36,1);
%     prob_choice=zeros(36,1);
%     
%     for t=1:36
%         
%         name_money(t,1)=array_results{t,1}(1,1);
%         name_probability(t,1)=array_results{t,1}(1,2);
%         sum_choice(t,1)=sum(array_results{t}(:,3));
%         
%     end
%     
%     xx=(0:100)';
%     final_k=x(1);
%     final_c=y(1);
%     final_beta=z(1);
%     final_delta=z(2);
%     final_apar=1;
%     final_kpar=w(1);
%         
%     sv_predicted_plot(:,1)=(1./(1+(final_k.*xx(:,1))));
%     sv_predicted_plot(:,2)=exp(-final_c.*xx(:,1));
%     sv_predicted_plot(:,3)=(exp(-final_beta.*xx(:,1))+exp(-final_delta.*xx(:,1)))/2;
%     sv_predicted_plot(:,4)=final_apar-(final_kpar.*(xx(:,1)).^2);
% 
%     h=figure;
%     plot(xx,sv_predicted_plot(:,1),'-','Color','b','LineWidth',5); %Plot hyperbolic fitting
%     hold on
%     plot(xx,sv_predicted_plot(:,2),'-','Color','r','LineWidth',5); %Plot exponential fitting
%     plot(xx,sv_predicted_plot(:,3),'-','Color',[0 0.5 0],'LineWidth',5); %Plot double exponential fitting
%     plot(xx,sv_predicted_plot(:,4),'-','Color',[0.5 0.5 0.5],'LineWidth',5); %Plot parabolic fitting
%     ylim([0 1]);
%     
%     for k=1:36
%         
%        if sum_choice(k)==0 %If the risky option was chosen 0 out of 4 times...
%             %shape='.';
%             %color=[0 0.2 0];
%             txt='0';
%         elseif sum_choice(k)==1 %If the risky option was chosen 1 out of 4 times...
%             %shape='*';
%             %color=[0 0.4 0];
%             txt='1';
%         elseif sum_choice(k)==2 %If the risky option was chosen 2 out of 4 times...
%             %shape='+';
%             %color=[0 0.6 0];
%             txt='2';
%         elseif sum_choice(k)==3 %If the risky option was chosen 3 out of 4 times...
%             %shape='o';
%             %color=[0 0.8 0];
%             txt='3';
%         elseif sum_choice(k)==4 %If the risky option was chosen 4 out of 4 times...
%             %shape='p';
%             %color=[0 1 0];
%             txt='4';
%         end
%         
%         scatter((100-name_probability(k)),5/name_money(k),30,'k','.','filled'); %"Plot" observed values without marker!
%         text((100-name_probability(k)),5/name_money(k),txt); %Use number as marker
%     end
%     
%     if str2double(habit_or_control)==1 && str2double(pre_or_post)==1
%         output_graph=strcat('PRE_risk_discounting_sub',volunteer,'.fig');
%     elseif str2double(habit_or_control)==1 && str2double(pre_or_post)==2
%         output_graph=strcat('POST_risk_discounting_sub',volunteer,'.fig');
%     elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==1
%         output_graph=strcat('PRE_risk_discounting_control',volunteer,'.fig');
%     elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==2
%         output_graph=strcat('POST_risk_discounting_control',volunteer,'.fig');
%     end    
% savefig(output_graph);
% hold off
% close(h)  
            


average_BIC(:,1)=mean(LL_all_subs(:,2));
average_BIC(:,2)=mean(LL_all_subs(:,4));
average_BIC(:,3)=mean(LL_all_subs(:,6));
average_BIC(:,4)=mean(LL_all_subs(:,8));

% %Saving main outputs:
% if str2double(habit_or_control)==1 && str2double(pre_or_post)==1
%     save('PRE_risk_hyperbolic_intervention.mat','all_subs_hyp'); %K, inverse temperature, LL
%     save('PRE_risk_exponential_intervention.mat','all_subs_exp'); %c, inverse temperature, LL
%     save('PRE_risk_double_exp_intervention.mat','all_subs_Dexp'); %beta, delta, inverse temperature, LL
%     save('PRE_risk_parabolic_intervention.mat','all_subs_par'); %k, inverse temperature, LL
%     save('PRE_risk_average_BIC_intervention.mat','average_BIC'); %For hyperbolic, exponential, double exponential, parabolic
%     save('PRE_risk_individual_best_curve_intervention.mat','best_curve');
% elseif str2double(habit_or_control)==1 && str2double(pre_or_post)==2
%     save('POST_risk_hyperbolic_intervention.mat','all_subs_hyp'); %K, inverse temperature, LL
%     save('POST_risk_exponential_intervention.mat','all_subs_exp'); %c, inverse temperature, LL
%     save('POST_risk_double_exp_intervention.mat','all_subs_Dexp'); %beta, delta, inverse temperature, LL
%     save('POST_risk_parabolic_intervention.mat','all_subs_par'); %k, inverse temperature, LL
%     save('POST_risk_average_BIC_intervention.mat','average_BIC'); %For hyperbolic, exponential, double exponential, parabolic
%     save('POST_risk_individual_best_curve_intervention.mat','best_curve');
% elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==1
%     save('PRE_risk_hyperbolic_control.mat','all_subs_hyp'); %K, inverse temperature, LL
%     save('PRE_risk_exponential_control.mat','all_subs_exp'); %c, inverse temperature, LL
%     save('PRE_risk_double_exp_control.mat','all_subs_Dexp'); %beta, delta, inverse temperature, LL
%     save('PRE_risk_parabolic_control.mat','all_subs_par'); %k, inverse temperature, LL
%     save('PRE_risk_average_BIC_control.mat','average_BIC'); %For hyperbolic, exponential, double exponential, parabolic
%     save('PRE_risk_individual_best_curve_control.mat','best_curve');
% elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==2
%     save('POST_risk_hyperbolic_control.mat','all_subs_hyp'); %K, inverse temperature, LL
%     save('POST_risk_exponential_control.mat','all_subs_exp'); %c, inverse temperature, LL
%     save('POST_risk_double_exp_control.mat','all_subs_Dexp'); %beta, delta, inverse temperature, LL
%     save('POST_risk_parabolic_control.mat','all_subs_par'); %k, inverse temperature, LL
%     save('POST_risk_average_BIC_control.mat','average_BIC'); %For hyperbolic, exponential, double exponential, parabolic
%     save('POST_risk_individual_best_curve_control.mat','best_curve');
% end   
