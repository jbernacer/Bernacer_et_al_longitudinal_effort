function f = loglikelihood_exp_risk(y)
f = 0;
global partial_f
partial_f = 0;

global position
global choice
global money
global probability


for trial=1:length(position)
        
        if strcmp(position{trial,1},choice{trial,1})==1
            
            SV_chosen=money(trial,1)*exp(-y(1).*(100-probability(trial,1)));
            SV_unchosen=5;
            
            
        else
            SV_unchosen=money(trial,1)*exp(-y(1).*(100-probability(trial,1)));
            SV_chosen=5;
            
        end
        
    prob_chosen=1/(1+exp(-y(2)*(SV_chosen-SV_unchosen)));    
    partial_f(trial,1)=log(prob_chosen);
    
        
end %of trial for loop
f=-sum(partial_f);  

    