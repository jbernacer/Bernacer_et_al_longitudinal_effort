%This script takes the log file (.mat) of the behavioral task to estimate
%risk discounting. The input file is a cell array with the following
%information:
% all_sessions{1,1}=1st session, money of the alternative option
% all_sessions{2,1}=2nd session, money of the alternative option
% all_sessions{1,2}=1st session, probability of winning the alternative option
% all_sessions{2,2}=2nd session, probability of winning the alternative option
% all_sessions{1,3}=1st session, position on screen of the alternative option
% all_sessions{2,3}=2nd session, position on screen of the alternative option
% all_sessions{1,4}=1st session, choice
% all_sessions{2,4}=2nd session, choice

%There are three stages in this estimation: 1) data preparation; 2) estimation the psychometric
%curves to predict the probability of choosing the alternative (discounted)
%option, for each risk level. By doing so, we can estimate the "indifference points"
%for each risk level. 3) A hyperbolic, exponential, double exponential or parabolic curve
%is used to fit the data.

%Main outputs:
%1) risk_indifference_points.mat: N-by-6 (N=subjects) matrix. Each column is the indifference point
%    for each risk level (90%, 75%, 50%, 33%, 10%, 5% probabilities of winning)
%2) risk_psychometric_data.mat: N-by-M (N=subjects, M=risk levels) cell, with a 1-by-4 matrix in
%    each cell. This matrix shows K, G, r0 constants, and adjustment (R-squared)
%3) risk_discounting_constants.mat: N-by-7 (N=subjects) matrix, recording the
%    following columns: 1) subject; 2) hyperbolic K; 3) exponential c; 4) double exponential beta;
%    5) double exponential delta; 6) parabolic k; 7) parabolic a;
%4) risk_discounting_adjustment.mat: N-by-5 (N=subjects) matrix,
%    recording the subject code (1), and the adjustment (adjusted R-squared) for the hyperbolic (2),
%    exponential (3), double exponential (4) and parabolic (5) fittings.

%THIS SCRIPT CAN BE USED FOR PRE (BEFORE HABIT) OR POST (AFTER HABIT) DATA.
%RISK DISCOUNTING DATA FOR THE "CONTROL" GROUP WAS RESTRICTED TO 11 SUBJECTS.
%FOR SUBJECT 15, DATA WAS NOT COLLECTED BEFORE HABIT.

clc
clear all
tic
addpath(pwd);

habit_or_control=input('Analyze intervention (1) or control (2) group?    ','s');
pre_or_post=input('Analyze pre (1) or post (2) data?   ','s');

if str2double(habit_or_control)==1
    subjects=1:19;
elseif str2double(habit_or_control)==2
    subjects=1:13;
end

%Preallocating variables:
indifference_points=zeros(length(subjects),6);
risk_discounting_adjustment=zeros(length(subjects),5);
risk_discounting_constants=zeros(length(subjects),7);
psychometric_constants_and_adjustment=cell(length(subjects),6);
y_predicted_best=zeros(60,6);
all_risks_y_observed=zeros(6,6);
alternative_chosen=cell(144,1);


for subject=1:length(subjects)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SECTION 1: PREPARING DATA TO ESTIMATE THE PSYCHOMETRIC FUNCTION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    volunteer=num2str(subject);
    verbose=strcat('Starting subject','  ',volunteer,' of','   ',num2str(max(subjects)));
    disp(verbose)
    %Next if statements to bypass missing data
    if subject==15 && str2double(pre_or_post)==1 && str2double(habit_or_control)==1 || subject==1 && str2double(pre_or_post)==1 && str2double(habit_or_control)==2 || subject==3 && str2double(pre_or_post)==1 && str2double(habit_or_control)==2 || subject==4 && str2double(pre_or_post)==1 && str2double(habit_or_control)==2
        continue;
    end
            
    %Loading input files:
    if str2double(habit_or_control)==1 && str2double(pre_or_post)==1
        input_data=strcat('PRE_risk_discounting_sub',volunteer,'.mat');
        input_array=load(input_data);
    elseif str2double(habit_or_control)==1 && str2double(pre_or_post)==2
        input_data=strcat('POST_risk_discounting_sub',volunteer,'.mat');
        input_array=load(input_data);
    elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==1
        input_data=strcat('PRE_risk_discounting_control',volunteer,'.mat');
        input_array=load(input_data);
    elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==2
        input_data=strcat('POST_risk_discounting_control',volunteer,'.mat');
        input_array=load(input_data);
    end
    
    %Concatenating and organizing both sesions:
    
    money=str2double([input_array.all_sessions{1,1}; input_array.all_sessions{2,1}]);
    risk=str2double([input_array.all_sessions{1,2}; input_array.all_sessions{2,2}]);
    position=[input_array.all_sessions{1,3}; input_array.all_sessions{2,3}];
    choice=[input_array.all_sessions{1,4}; input_array.all_sessions{2,4}];
    
    %Recording whether the alternative option was chosen:
    
    for trial=1:144
        
        if strcmp(position{trial,1},choice{trial,1})==1
            alternative_chosen{trial,1}=1;
        else
            alternative_chosen{trial,1}=0;
        end
        
    end %of trial for loop
    
    %Sorting results to organize money and risk levels:
    
    results=[money risk cell2mat(alternative_chosen)];
    sorted_results=sortrows(results,[2 1],{'descend' 'ascend'});
        
    %We will end up with an array containing 36 (4x3) cells. This
    %corresponds to: a) 6 risk levels; b) 6 money amounts (that makes the
    %36 cells); c) 4 presentations of each pair; d) 3 columns: money,
    %risk and choice (1=alternative, 0=fixed option, ie 5€ no risk):
   
    array_results=mat2cell(sorted_results,repmat(4,36,1),3);
    
    %Next, we will calculate the probability of choosing the alternative
    %(discounted) option for each money amount and risk level
    
    name_money=zeros(36,1);
    name_risk=zeros(36,1);
    prob_choice=zeros(36,1);
    
    for t=1:36
        
        name_money(t,1)=array_results{t,1}(1,1);
        name_risk(t,1)=array_results{t,1}(1,2);
        prob_choice(t,1)=sum(array_results{t}(:,3))/4;
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SECTION 2: ESTIMATING THE PSYCHOMETRIC FUNCTIONS TO CALCULATE
    %INDIFFERENCE POINTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Here starts the estimation of the psychometric function for each
    %risk level. The goal is to plot the probability of choosing the alternative option
    %(y axis) for each amount of money (x axis). Then, data is fitted with
    %a psychometric function: y=K./(1+exp(-G.*(x(:,1)-r0)))
    %The constants K, G and r0 will be estimated in each case. We will try
    %all possible combinations of 50 values of K, 100 of G and 100 of r0.
    %The best fit will be chosen with R-squared
    %The indifference point will be the x value (money) that corresponds to
    %a 0.5 probability of choosing the alternative option
    
    %There are two problematic situations: when subjects consistently
    %choose the fixed (1) or the alternative (2) option for a particular risk level.
    %In this case, observed probabilities are a vector (6x1) of 0 or 1, respectively, and there is no
    %possible fitting to a psychometric curve. In this case, indifference
    %points are considered as Infinity (subject will not run the risk
    %even though Inf € are offered) or as 5 (there is no discounting, and
    %the subject will run the risk even for the same amount of money
    %(5€) than was offered in the fixed option)

    verbose=strcat('Starting the estimation of indifference points...');
    disp(verbose)
    risk_levels=[10; 25; 50; 67; 90; 95];%This is (100-probability of winning)
    money_amounts=[5.25; 9; 14; 20; 30; 50];
    results_matrix=zeros(6,7);
    dummy_e=0; %This is to extract probabilites from prob_choice
    
    %The output will be a matrix called 'indifference_points' with 19 rows (one for each subject) and 6
    %columns, being the indifference point for each risk level (10, 25, 50,
    %67, 90 and 95% chances of not winning the money)
        
    %Starting loop for each risk level:
    
    for e=1:length(risk_levels) %For each risk level
        
        risk=risk_levels(e);
        R2=cell(50,1,1);
        
        %y_observed are the actual probabilities of choosing the discounted option
        %for that risk level:
        y_observed=prob_choice(e+dummy_e:e+dummy_e+5,1);
        dummy_e=dummy_e+5;
        
        %We are first dealing with the problematic consistent choices:
        
        if sum(y_observed==zeros(6,1))==6
            indifference_points(subject,e)=Inf;
            best_K=NaN;
            best_G=NaN;
            best_r0=NaN;
            y_predicted_best(:,e)=zeros(60,1);
            all_risks_y_observed(:,e)=y_observed;
        elseif sum(y_observed==ones(6,1))==6
            indifference_points(subject,e)=5;
            best_K=NaN;
            best_G=NaN;
            best_r0=NaN;
            y_predicted_best(:,e)=ones(60,1);
            all_risks_y_observed(:,e)=y_observed;
        else
       
        for a=1:50 %Loop for K values
            K=(a/50)+0.5; %They will range from 0.52 to 1.5
    
            R2{a}=zeros(100,100); 
    
            for b=1:100 %Loop for G values
                G=b/10; %They will range from 0.1 to 10
        
                for c=1:100 %Loop for r0 values
                    r0=c-50; %They will range from -49 to 50
            
                    %The next formula calculates the predicted
                    %probabilities for that particular set of values
                    predicted_values(:,1)=K./(1+exp(-G.*(money_amounts(:,1)-r0)));
            
                    %For calculating R-squared, we need the total sum of
                    %squares and the residuals sum of squares:
                    SStot=sum((y_observed(:,1)-mean(y_observed)).^2); %This is the denominator of the R-squared formula
                    SSres=sum((predicted_values(:,1)-y_observed(:,1)).^2); %And this is the numerator
        
                    R2{a}(c,b)=1-(SSres/SStot); %Goodness of fit for this particular k and s pair of values
            
                end %of loop for r0 values
            end %of loop for G values
       
        end %of loop for K values and estimation
        
        
        %Next, we will find the maximum in R2 cell, which will be the best
        %set of constants:
        
        N = size(R2,1); %Our cell array contains 100 rows in each of its matrices
        find_max=0;

        for i=1:N
    
            [num , ~]=max(max(R2{i}));
            find_max=num;
            
            if i==1
                best_R2=num;
                [row, column]=find(R2{i}==num,1,'first');
                matrix=1;
            else
                if find_max>best_R2
                    best_R2=find_max;
                    [row, column]=find(R2{i}==num,1,'first');
                    matrix=i;
                
                end
            end
               
        end
    
        best_r0=row-50;
        best_G=column/10;
        best_K=(matrix/50)+0.5;
        R2_adj=1-(1-best_R2)*((6-1)/(6-2-1));
        
        indifference_points(subject,e)=((log((best_K/0.5)-1))/-best_G)+best_r0;
        %The next 'if' fixes impossible fitting of subject 14 'PRE'
        if indifference_points(subject,e)<0
            indifference_points(subject,e)=5;
        end
             
        end %To deal with consistent choices
        
        %This will record each set of constants and adjustment per risk
        %level and subject
        psychometric_constants_and_adjustment{subject,e}(1,1)=best_K;
        psychometric_constants_and_adjustment{subject,e}(1,2)=best_G;
        psychometric_constants_and_adjustment{subject,e}(1,3)=best_r0;
        psychometric_constants_and_adjustment{subject,e}(1,4)=R2_adj;
        x=(1:60)'; %This is to show smooth fittings
        y_predicted_best(:,e)=best_K./(1+exp(-best_G.*(x(:,1)-best_r0)));
        all_risks_y_observed(:,e)=y_observed;  
    
    end %of risk levels loop
    
    %Uncomment the next bit to show and save figures with actual behavior and
    %fit to the psychometric curve:
        
%     h = figure;
%     subplot(2,3,1)
%     plot(money_amounts,all_risks_y_observed(:,1),'o','MarkerFaceColor','b','MarkerSize',10)
%     hold on
%     plot(x,y_predicted_best(:,1),'Color','red','LineWidth',5)
%     ylim([0 1])
%     hline=refline(0,0.5);
%     hline.Color='k';
%     hline.LineStyle='--';
%     title('90% of winning')
%     
%     subplot(2,3,2)
%     plot(money_amounts,all_risks_y_observed(:,2),'o','MarkerFaceColor','b','MarkerSize',10)
%     hold on
%     plot(x,y_predicted_best(:,2),'Color','red','LineWidth',5)
%     ylim([0 1])
%     hline=refline(0,0.5);
%     hline.Color='k';
%     hline.LineStyle='--';
%     title('75% of winning')
%     
%     subplot(2,3,3)
%     plot(money_amounts,all_risks_y_observed(:,3),'o','MarkerFaceColor','b','MarkerSize',10)
%     hold on
%     plot(x,y_predicted_best(:,3),'Color','red','LineWidth',5)
%     ylim([0 1])
%     hline=refline(0,0.5);
%     hline.Color='k';
%     hline.LineStyle='--';
%     title('50% of winning')
%     
%     subplot(2,3,4)
%     plot(money_amounts,all_risks_y_observed(:,4),'o','MarkerFaceColor','b','MarkerSize',10)
%     hold on
%     plot(x,y_predicted_best(:,4),'Color','red','LineWidth',5)
%     ylim([0 1])
%     hline=refline(0,0.5);
%     hline.Color='k';
%     hline.LineStyle='--';
%     title('25% of winning')
%     
%     subplot(2,3,5)
%     plot(money_amounts,all_risks_y_observed(:,5),'o','MarkerFaceColor','b','MarkerSize',10)
%     hold on
%     plot(x,y_predicted_best(:,5),'Color','red','LineWidth',5)
%     ylim([0 1])
%     hline=refline(0,0.5);
%     hline.Color='k';
%     hline.LineStyle='--';
%     title('10% of winning')
%     
%     subplot(2,3,6)
%     plot(money_amounts,all_risks_y_observed(:,6),'o','MarkerFaceColor','b','MarkerSize',10)
%     hold on
%     plot(x,y_predicted_best(:,6),'Color','red','LineWidth',5)
%     ylim([0 1])
%     hline=refline(0,0.5);
%     hline.Color='k';
%     hline.LineStyle='--';
%     title('5% of winning')
%     if str2double(habit_or_control)==1 && str2double(pre_or_post)==1
%         output_graph=strcat('PRE_psychometric_sub',volunteer,'_risk.fig');
%     elseif str2double(habit_or_control)==1 && str2double(pre_or_post)==2
%         output_graph=strcat('POST_psychometric_sub',volunteer,'_risk.fig');
%     elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==1
%         output_graph=strcat('PRE_psychometric_control',volunteer,'_risk.fig');
%     elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==2
%         output_graph=strcat('POST_psychometric_control',volunteer,'_risk.fig');
%     end 
%     savefig(output_graph);
%     hold off
%     close(h)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SECTION 3: ESTIMATING DISCOUNTING FUNCTION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %The required input is the indifference points. The discounting factor
    %of each risk level is calculated as: X/ip, being X=5 (money of the
    %undiscounted option)and ip the indifference point. Then, different curves are fitted to
    %the 6 data points: hyperbolic, exponential, double exponential and
    %parabolic:
    
    %Hyperbolic: y(x)=1/(1+(k*x))
    %Exponential: y(x)=exp(-c*x)
    %Double exponential: y(x)=(exp(-beta*x)+exp(-delta*x))/2
    %Parabolic: y(x)=a-(k*x)^2
    
    
    %The possible combinations of 1000 different possible parameters will
    %be tested
    verbose=strcat('Starting the estimation of discounting curves...');
    disp(verbose)
    R2_exponential=zeros(1000,1);
    R2_double=zeros(1000,1000);
    R2_hyperbolic=zeros(1000,1);
    R2_parabolic=zeros(1000,1000);
    
    %Next, this is a vector with the indifference points, including the
    %"reference value" (ie, money of the non-discounted option = 5€)
    ip=[5 indifference_points(subject,:)]';
    risk_levels=[0; 10; 25; 50; 67; 90; 95];
    
    %Discounting factors are X/ip:

    DF(:,1)=5./ip;
    
    %And we start the estimation, trying hyperbolic, exponential, double
    %exponential and parabolic fittings:
    
    for t=1:1000 %We are going to carry out 1000 simulations with different values of the constants
        k=(t/500); %This is the constant for the hyperbolic
        c=(t/500); %This is for the exponential
        beta=(t/500); %This is one constant for the double exponential
        kpar=(t/50000); %This is one constant for the parabolic
        
        sv_predicted(:,1)=(1./(1+(k.*risk_levels(:,1)))); %Hyperbolic model, in the 1st column
        
    %Now we calculate the goodness of fit with R-squared
    SStot(1,1)=sum((DF(:,1)-mean(DF)).^2); %This is the denominator of the R-squared formula
    SSres(1,1)=sum((sv_predicted(:,1)-DF(:,1)).^2); %And this is the numerator
        
    R2_hyperbolic(t,1)=1-(SSres(1,1)/SStot(1,1)); %Goodness of fit for this particular k value
           
        for z=1:1000 %this is a second loop to estimate delta and constant
            delta=(z/5000);
            apar=z/1000;
            sv_predicted(:,3)=(exp(-beta.*risk_levels(:,1))+exp(-delta.*risk_levels(:,1)))/2; %Double exponential, in the 3rd column
                   
            %Now we calculate the goodness of fit with R-squared
            SStot(1,1)=sum((DF(:,1)-mean(DF)).^2); %This is the denominator of the R-squared formula
            SSres(1,3)=sum((sv_predicted(:,3)-DF(:,1)).^2); %And this is the numerator
        
            R2_double(t,z)=1-(SSres(1,3)/SStot(1,1)); %R-squared for double exponential
            
            sv_predicted(:,4)=apar-(kpar.*(risk_levels(:,1)).^2); %Parabolic model, in the 4th column
            SStot(1,1)=sum((DF(:,1)-mean(DF)).^2); %This is the denominator of the R-squared formula
            SSres(1,4)=sum((sv_predicted(:,4)-DF(:,1)).^2); %And this is the numerator
            
            R2_parabolic(t,z)=1-(SSres(1,4)/SStot(1,1)); %R-squared for parabolic           
        
        end %of the delta and apar constant loop
            
    sv_predicted(:,2)=exp(-c.*risk_levels(:,1)); %Exponential model, stored in the 2nd column of sv_predicted
    
    
    SStot(1,1)=sum((DF(:,1)-mean(DF)).^2); %%SStot is the same as before.
    SSres(1,2)=sum((sv_predicted(:,2)-DF(:,1)).^2);%Residuals for exponential
        
    R2_exponential(t,1)=1-(SSres(1,2)/SStot(1,1)); %R-squared for exponential
    
    
    end

xx=(0:100)'; %This is to show smooth fittings
%Extract maximum for hyperbolic

adj_R2_hyperbolic=1-((1-R2_hyperbolic).*((6-1)/(6-0-1)));
[num , ~]=max(adj_R2_hyperbolic(:));
best_R2_hyperbolic=num(1,1);
[I, ~]=find(adj_R2_hyperbolic==num);
final_k=I/500;
sv_predicted_plot(:,1)=(1./(1+(final_k.*xx(:,1))));
risk_discounting_adjustment(subject,1)=subject;
risk_discounting_adjustment(subject,2)=best_R2_hyperbolic;
risk_discounting_constants(subject,1)=subject;
risk_discounting_constants(subject,2)=final_k;

%Extract maximum for exponential

adj_R2_exponential=1-((1-R2_exponential).*((6-1)/(6-0-1)));
[num, idx]=max(adj_R2_exponential);
best_R2_exponential=num(1,1);
final_c=idx(1,1)/500;
sv_predicted_plot(:,2)=exp(-final_c.*xx(:,1));
risk_discounting_adjustment(subject,3)=best_R2_exponential;
risk_discounting_constants(subject,3)=final_c;

%Extract maximum for double exponential

adj_R2_double=1-((1-R2_double).*((6-1)/(6-1-1)));
[num , ~]=max(adj_R2_double(:));
best_R2_double=num(1,1);
[I, J]=find(adj_R2_double==num);
final_beta=I(1,1)/500;
final_delta=J(1,1)/5000;
sv_predicted_plot(:,3)=(exp(-final_beta.*xx(:,1))+exp(-final_delta.*xx(:,1)))/2;
risk_discounting_adjustment(subject,4)=best_R2_double;
risk_discounting_constants(subject,4)=final_beta;
risk_discounting_constants(subject,5)=final_delta;

%Extract maximum for parabolic

adj_R2_parabolic=1-((1-R2_parabolic).*((6-1)/(6-1-1)));
[num, idx]=max(adj_R2_parabolic(:));
best_R2_parabolic=num(1,1);
[I, J]=find(adj_R2_parabolic==num);
final_kpar=I(1,1)/50000;
final_apar=J(1,1)/1000;
sv_predicted_plot(:,4)=final_apar-(final_kpar.*(xx(:,1)).^2);
risk_discounting_adjustment(subject,5)=best_R2_parabolic;
risk_discounting_constants(subject,6)=final_kpar;
risk_discounting_constants(subject,7)=final_apar;

%Uncomment this section to obtain individual graphs (one plot per subject):

% h=figure;
% plot(xx,sv_predicted_plot(:,1),'-','Color','b','LineWidth',5); %Plot hyperbolic fitting
% hold on
% plot(xx,sv_predicted_plot(:,2),'-','Color','r','LineWidth',5); %Plot exponential fitting
% plot(xx,sv_predicted_plot(:,3),'-','Color',[0 0.5 0],'LineWidth',5); %Plot double exponential fitting
% plot(xx,sv_predicted_plot(:,4),'-','Color',[0.5 0.5 0.5],'LineWidth',5); %Plot parabolic fitting
% plot(risk_levels,DF,'o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10) %Plot observed values
% ylim([0 1]);
% text_hyperbolic=strcat('R2 hyperbolic= ',num2str(best_R2_hyperbolic));
% text_exponential=strcat('R2 exponential= ',num2str(best_R2_exponential));
% text_double=strcat('R2 double= ',num2str(best_R2_double));
% text_parabolic=strcat('R2 parabolic= ',num2str(best_R2_parabolic));
% text(45,0.9, text_hyperbolic,'Color','b','FontSize',10);
% text(45,0.85, text_exponential,'Color','r','FontSize',10);
% text(45,0.8, text_double,'Color',[0 0.5 0],'FontSize',10);
% text(45,0.75, text_parabolic,'Color',[0.5 0.5 0.5],'FontSize',10);
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

%Uncomment this section to obtain a single figure with all subjects:

if subject==1
    figure('pos',[50 50 1200 800])
end
subplot(5,4,subject)
p1=plot(xx,sv_predicted_plot(:,1),'-','Color','b','LineWidth',3); %Plot hyperbolic fitting
hold on
p2=plot(xx,sv_predicted_plot(:,2),'-','Color','r','LineWidth',3); %Plot exponential fitting
p3=plot(xx,sv_predicted_plot(:,3),'-','Color','g','LineWidth',3); %Plot double exponential fitting
p4=plot(xx,sv_predicted_plot(:,4),'-','Color',[0.5 0.5 0.5],'LineWidth',3); %Plot parabolic fitting
p5=plot(risk_levels,DF,'o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',5); %Plot observed values
p3.Color(4)=0.50; %This makes double exponential slightly transparent

ylim([0 1]);
title_text=strcat('Subject   ',volunteer);
title(title_text)
    if str2double(habit_or_control)==1 && str2double(pre_or_post)==1
        output_graph=strcat('PRE_risk_discounting_intervention_subjects.fig');
    elseif str2double(habit_or_control)==1 && str2double(pre_or_post)==2
        output_graph=strcat('POST_risk_discounting_intervention_subjects.fig');
    elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==1
        output_graph=strcat('PRE_risk_discounting_control_subjects.fig');
    elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==2
        output_graph=strcat('POST_risk_discounting_control_subjects.fig');
    end   
if subject==max(subjects)
    savefig(output_graph);
end

    
end %of subjects loop
risk_discounting_factors=5./indifference_points;
%Saving main output:
if str2double(habit_or_control)==1 && str2double(pre_or_post)==1
    save('PRE_risk_psychometric_data_intervention.mat','psychometric_constants_and_adjustment');
    save('PRE_risk_indifference_points_intervention.mat','indifference_points');
    save('PRE_risk_discounting_adjustment_intervention.mat','risk_discounting_adjustment');
    save('PRE_risk_discounting_constants_intervention.mat','risk_discounting_constants');
    save('PRE_risk_discounting_factors_intervention.mat','risk_discounting_factors');
elseif str2double(habit_or_control)==1 && str2double(pre_or_post)==2
    save('POST_risk_psychometric_data_intervention.mat','psychometric_constants_and_adjustment');
    save('POST_risk_indifference_points_intervention.mat','indifference_points');
    save('POST_risk_discounting_adjustment_intervention.mat','risk_discounting_adjustment');
    save('POST_risk_discounting_constants_intervention.mat','risk_discounting_constants');
    save('POST_risk_discounting_factors_intervention.mat','risk_discounting_factors');
elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==1
    save('PRE_risk_psychometric_data_control.mat','psychometric_constants_and_adjustment');
    save('PRE_risk_indifference_points_control.mat','indifference_points');
    save('PRE_risk_discounting_adjustment_control.mat','risk_discounting_adjustment');
    save('PRE_risk_discounting_constants_control.mat','risk_discounting_constants');
    save('PRE_risk_discounting_factors_control.mat','risk_discounting_factors');
elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==2
    save('POST_risk_psychometric_data_control.mat','psychometric_constants_and_adjustment');
    save('POST_risk_indifference_points_control.mat','indifference_points');
    save('POST_risk_discounting_adjustment_control.mat','risk_discounting_adjustment');
    save('POST_risk_discounting_constants_control.mat','risk_discounting_constants');
    save('POST_risk_discounting_factors_control.mat','risk_discounting_factors');
end   
toc