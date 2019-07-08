function f = loglikelihood_Dexp(z)
f = 0;
global partial_f
partial_f = 0;

global position
global choice
global money
global probability


for trial=1:length(position)
        
        %prob_discounted=(exp(money(trial)./(1+(k.*effort(trial))).*beta))./(exp(money(trial)./(1+(k.*effort(trial))).*beta)+exp(5/beta));
        %prob_fixed=exp(5/beta)./(exp(money(trial)./(1+(k.*effort(trial))).*beta)+exp(5/beta));
        
        if strcmp(position{trial,1},choice{trial,1})==1
            
            SV_chosen=money(trial,1)*((exp(-z(1)*(100-probability(trial,1)))+exp(-z(2)*(100-probability(trial,1))))/2);
            SV_unchosen=5;
            
            
        else
            SV_unchosen=money(trial,1)*((exp(-z(1)*(100-probability(trial,1)))+exp(-z(2)*(100-probability(trial,1))))/2);
            SV_chosen=5;
            
        end
        
    prob_chosen=1/(1+exp(-z(3)*(SV_chosen-SV_unchosen)));    
    partial_f(trial,1)=log(prob_chosen);
    
        
end %of trial for loop
f=-sum(partial_f);  

    