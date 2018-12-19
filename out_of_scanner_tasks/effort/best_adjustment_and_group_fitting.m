%This simple script calculates the best fitting (hyperbolic, exponential,
%double exponential or parabolic) coming from
%"effort_discounting_estimation.m".

%In addition, it performs the group fitting

clc
clear all
addpath(pwd);
habit_or_control=input('Analyze intervention (1) or control (2) group?    ','s');
pre_or_post=input('Analyze pre (1) or post (2) data?   ','s');

%Loading input files:
    if str2double(habit_or_control)==1 && str2double(pre_or_post)==1
        input_adjustments=strcat('PRE_effort_discounting_adjustment_intervention.mat');
        input_DF=strcat('PRE_effort_discounting_factors_intervention.mat');
        subjects=1:19;
    elseif str2double(habit_or_control)==1 && str2double(pre_or_post)==2
        input_adjustments=strcat('POST_effort_discounting_adjustment_intervention.mat');
        input_DF=strcat('POST_effort_discounting_factors_intervention.mat');
        subjects=1:19;
    elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==1
        input_adjustments=strcat('PRE_effort_discounting_adjustment_control.mat');
        input_DF=strcat('PRE_effort_discounting_factors_control.mat');
        subjects=1:13;
    elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==2
        input_adjustments=strcat('POST_effort_discounting_adjustment_control.mat');
        input_DF=strcat('POST_effort_discounting_factors_control.mat');
        subjects=1:13;
    end
    
load(input_adjustments);
load(input_DF);

%Calculating and recording best adjustment:
best_adjustment=zeros(length(subjects),3);
DF=zeros(6,1);
DF_SEM=zeros(6,1);

for subject=1:length(subjects)
    [I, J]=max(effort_discounting_adjustment(subject,2:5));
    best_adjustment(subject,1)=subject;
    best_adjustment(subject,2)=J;
    best_adjustment(subject,3)=I;
end

%Now, we load the discounting factors (observed data) and fit the best
%hyperbolic, exponential, double exponential or parabolic curve

R2_exponential=zeros(1000,1);
R2_double=zeros(1000,1000);
R2_hyperbolic=zeros(1000,1);
R2_parabolic=zeros(1000,1000);

effort_levels=[0; 5; 10; 15; 20; 25; 30];
for zz=1:6
    DF(zz,1)=mean(effort_discounting_factors(:,zz));
    DF_SEM(zz,1)=nansem(effort_discounting_factors(:,zz));
end

DF=[1; DF];
DF_SEM=[0; DF_SEM];

%And we start the estimation, trying hyperbolic, exponential, double
%exponential and parabolic fittings:
    
for t=1:1000 %We are going to carry out 1000 simulations with different values of the constants
    k=(t/500); %This is the constant for the hyperbolic
    c=(t/500); %This is for the exponential
    beta=(t/500); %This is one constant for the double exponential
    kpar=(t/50000); %This is one constant for the parabolic
        
    sv_predicted(:,1)=(1./(1+(k.*effort_levels(:,1)))); %Hyperbolic model, in the 1st column
        
    %Now we calculate the goodness of fit with R-squared
    SStot(1,1)=sum((DF(:,1)-mean(DF)).^2); %This is the denominator of the R-squared formula
    SSres(1,1)=sum((sv_predicted(:,1)-DF(:,1)).^2); %And this is the numerator
        
    R2_hyperbolic(t,1)=1-(SSres(1,1)/SStot(1,1)); %Goodness of fit for this particular k value
           
        for z=1:1000 %this is a second loop to estimate delta and constant
            delta=(z/5000);
            apar=z/1000;
            sv_predicted(:,3)=(exp(-beta.*effort_levels(:,1))+exp(-delta.*effort_levels(:,1)))/2; %Double exponential, in the 3rd column
                   
            %Now we calculate the goodness of fit with R-squared
            SStot(1,1)=sum((DF(:,1)-mean(DF)).^2); %This is the denominator of the R-squared formula
            SSres(1,3)=sum((sv_predicted(:,3)-DF(:,1)).^2); %And this is the numerator
        
            R2_double(t,z)=1-(SSres(1,3)/SStot(1,1)); %R-squared for double exponential
            
            sv_predicted(:,4)=apar-(kpar.*(effort_levels(:,1)).^2); %Parabolic model, in the 4th column
            SStot(1,1)=sum((DF(:,1)-mean(DF)).^2); %This is the denominator of the R-squared formula
            SSres(1,4)=sum((sv_predicted(:,4)-DF(:,1)).^2); %And this is the numerator
            
            R2_parabolic(t,z)=1-(SSres(1,4)/SStot(1,1)); %R-squared for parabolic           
        
        end %of the delta and apar constant loop
            
    sv_predicted(:,2)=exp(-c.*effort_levels(:,1)); %Exponential model, stored in the 2nd column of sv_predicted
    
    
    SStot(1,1)=sum((DF(:,1)-mean(DF)).^2); %%SStot is the same as before.
    SSres(1,2)=sum((sv_predicted(:,2)-DF(:,1)).^2);%Residuals for exponential
        
    R2_exponential(t,1)=1-(SSres(1,2)/SStot(1,1)); %R-squared for exponential
    
    
end

xx=(0:0.5:40)'; %This is to show smooth fittings
%Extract maximum for hyperbolic

adj_R2_hyperbolic=1-((1-R2_hyperbolic).*((6-1)/(6-0-1)));
[num , ~]=max(adj_R2_hyperbolic(:));
best_R2_hyperbolic=num(1,1);
[I, ~]=find(adj_R2_hyperbolic==num);
final_k=I/500;
sv_predicted_plot(:,1)=(1./(1+(final_k.*xx(:,1))));
group_effort_discounting_adjustment(1,1)=best_R2_hyperbolic;
group_effort_discounting_constants(1,1)=final_k;

%Extract maximum for exponential

adj_R2_exponential=1-((1-R2_exponential).*((6-1)/(6-0-1)));
[num, idx]=max(adj_R2_exponential);
best_R2_exponential=num(1,1);
final_c=idx(1,1)/500;
sv_predicted_plot(:,2)=exp(-final_c.*xx(:,1));
group_effort_discounting_adjustment(1,2)=best_R2_exponential;
group_effort_discounting_constants(1,2)=final_c;

%Extract maximum for double exponential

adj_R2_double=1-((1-R2_double).*((6-1)/(6-1-1)));
[num , ~]=max(adj_R2_double(:));
best_R2_double=num(1,1);
[I, J]=find(adj_R2_double==num);
final_beta=I(1,1)/500;
final_delta=J(1,1)/5000;
sv_predicted_plot(:,3)=(exp(-final_beta.*xx(:,1))+exp(-final_delta.*xx(:,1)))/2;
group_effort_discounting_adjustment(1,3)=best_R2_double;
group_effort_discounting_constants(1,3)=final_beta;
group_effort_discounting_constants(1,4)=final_delta;

%Extract maximum for parabolic

adj_R2_parabolic=1-((1-R2_parabolic).*((6-1)/(6-1-1)));
[num, idx]=max(adj_R2_parabolic(:));
best_R2_parabolic=num(1,1);
[I, J]=find(adj_R2_parabolic==num);
final_kpar=I(1,1)/50000;
final_apar=J(1,1)/1000;
sv_predicted_plot(:,4)=final_apar-(final_kpar.*(xx(:,1)).^2);
group_effort_discounting_adjustment(1,4)=best_R2_parabolic;
group_effort_discounting_constants(1,5)=final_kpar;
group_effort_discounting_constants(1,6)=final_apar;

%Plotting all fittings:

h=figure;
plot(xx,sv_predicted_plot(:,1),'-','Color','b','LineWidth',5); %Plot hyperbolic fitting
hold on
plot(xx,sv_predicted_plot(:,2),'-','Color','r','LineWidth',5); %Plot exponential fitting
plot(xx,sv_predicted_plot(:,3),'-','Color',[0 0.5 0],'LineWidth',5); %Plot double exponential fitting
plot(xx,sv_predicted_plot(:,4),'-','Color',[0.5 0.5 0.5],'LineWidth',5); %Plot parabolic fitting
%plot(effort_levels,DF,'o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10) %Plot observed values without error bars
errorbar(effort_levels,DF,DF_SEM,'s','MarkerSize',10,'MarkerEdgeColor','black','MarkerFaceColor','black','Color','black','LineWidth',3); %Plot observed values with error bars (SEM)
ylim([0 1]);
text_observed=strcat('Observed data (mean, SEM)');
text_hyperbolic=strcat('R2 hyperbolic= ',num2str(best_R2_hyperbolic));
text_exponential=strcat('R2 exponential= ',num2str(best_R2_exponential));
text_double=strcat('R2 double= ',num2str(best_R2_double));
text_parabolic=strcat('R2 parabolic= ',num2str(best_R2_parabolic));
text(15,0.95,text_observed,'Color','k','Fontsize',10);
text(15,0.9, text_hyperbolic,'Color','b','FontSize',10);
text(15,0.85, text_exponential,'Color','r','FontSize',10);
text(15,0.8, text_double,'Color',[0 0.5 0],'FontSize',10);
text(15,0.75, text_parabolic,'Color',[0.5 0.5 0.5],'FontSize',10);
    if str2double(habit_or_control)==1 && str2double(pre_or_post)==1
        output_graph=strcat('PRE_intervention_group_effort_discounting.fig');
    elseif str2double(habit_or_control)==1 && str2double(pre_or_post)==2
        output_graph=strcat('POST_intervention_group_effort_discounting.fig');
    elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==1
        output_graph=strcat('PRE_control_group_effort_discounting.fig');
    elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==2
        output_graph=strcat('POST_control_group_effort_discounting.fig');
    end    
savefig(output_graph);
hold off

%Saving main output:
if str2double(habit_or_control)==1 && str2double(pre_or_post)==1
    save('PRE_best_adjustment_effort_intervention.mat','best_adjustment');
    save('PRE_intervention_group_effort_discounting_constants.mat','group_effort_discounting_constants');
    save('PRE_intervention_group_effort_discounting_adjustment.mat','group_effort_discounting_adjustment');
    
elseif str2double(habit_or_control)==1 && str2double(pre_or_post)==2
    save('POST_best_adjustment_effort_intervention.mat','best_adjustment');
    save('POST_intervention_group_effort_discounting_constants.mat','group_effort_discounting_constants');
    save('POST_intervention_group_effort_discounting_adjustment.mat','group_effort_discounting_adjustment');
    
elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==1
    save('PRE_best_adjustment_effort_control.mat','best_adjustment');
    save('PRE_control_group_effort_discounting_constants.mat','group_effort_discounting_constants');
    save('PRE_control_group_effort_discounting_adjustment.mat','group_effort_discounting_adjustment');
    
elseif str2double(habit_or_control)==2 && str2double(pre_or_post)==2
    save('POST_best_adjustment_effort_control.mat','best_adjustment');
    save('POST_control_group_effort_discounting_constants.mat','group_effort_discounting_constants');
    save('POST_control_group_effort_discounting_adjustment.mat','group_effort_discounting_adjustment');
    
end   
    

