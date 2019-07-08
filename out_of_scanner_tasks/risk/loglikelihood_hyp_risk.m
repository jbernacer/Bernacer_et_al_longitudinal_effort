function f = loglikelihood_hyp_risk(x)
f = 0;
global partial_f
partial_f = 0;

global position
global choice
global money
global probability

for trial=1:length(position)
        
        if strcmp(position{trial,1},choice{trial,1})==1
            
            SV_chosen=money(trial,1)/(1+(x(1)*(100-probability(trial,1))));
            SV_unchosen=5;
                        
        else
            SV_unchosen=money(trial,1)/(1+(x(1)*(100-probability(trial,1))));
            SV_chosen=5;
            %prob_chosen=exp(5/x(2))/(exp(money(trial,1)/(1+(x(1)*effort(trial,1)))*x(2))+exp(5/x(2)));
        end
        
    prob_chosen=1/(1+exp(-x(2)*(SV_chosen-SV_unchosen)));    
    partial_f(trial,1)=log(prob_chosen);
    
        
end %of trial for loop
f=-sum(partial_f);  

    