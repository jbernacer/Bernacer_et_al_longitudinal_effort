% Entering volunteer's info 
  Volunteer =input('Volunteer : ','s'); %Asks for volunteer's name
  Sesion_number=input('Sesion number: ','s');
  LogFileName=strcat(Volunteer,' - [',datestr(now,0),']','- PROB_PILOT_sesion_',Sesion_number,'.log'); %Indicates name for log file
  LogFileName = strrep(LogFileName,':','.'); %Substitutes ":" for "." if necessary
  results_name=strcat('pilot_probability_',Volunteer,'_sesion_', Sesion_number,'.res');

config_display(0);
config_data('pilot_probability.dat');
config_log(LogFileName);
config_results(results_name);
config_keyboard(100,5,'nonexclusive');

start_cogent;
random_order=randperm(countdatarows);

for w=1:countdatarows
    
    clearkeys;
    j=random_order(w);
    clearpict(1);
    positions=[-150, 150]';
    pos_image_effort_0=positions(randi(2));
    preparestring('5 €',1,pos_image_effort_0,50);
    preparestring('SEGURO',1,pos_image_effort_0,-50);
    if pos_image_effort_0==-150
        pos_image_B=150;
    else
        pos_image_B=-150;
    end
    b_money=getdata(j,1);
    b_prob=getdata(j,2);
    text_b_money=strcat(b_money, ' €');
    preparestring(text_b_money,1,pos_image_B,50);
    if strcmp(b_prob,'90')==1
        text_b_prob_1='90%';
        text_b_prob_2='de ganar';
    elseif strcmp(b_prob,'75')==1
        text_b_prob_1='75%';
        text_b_prob_2='de ganar';
    elseif strcmp(b_prob,'50')==1
        text_b_prob_1='50%';
        text_b_prob_2='de ganar';
    elseif strcmp(b_prob,'33')==1
        text_b_prob_1='33%';
        text_b_prob_2='de ganar';
    elseif strcmp(b_prob,'10')==1
        text_b_prob_1='10%';
        text_b_prob_2='de ganar';
    elseif strcmp(b_prob,'5')==1
        text_b_prob_1='5%';
        text_b_prob_2='de ganar';
    end
        
    preparestring(text_b_prob_1,1,pos_image_B,-50);
    preparestring(text_b_prob_2,1,pos_image_B,-100);
    option_b_name=strcat(getdata(j,1),'-',getdata(j,2));
    logstring(option_b_name);
    drawpict(1);
    readkeys;
    waitkeydown(inf,[97,98]);  
    [ key, t, n ] = getkeydown;
    response=key(1);
    logstring(pos_image_B);
    logkeys;
    addresults(b_money,b_prob,pos_image_B,response);
    
    
    
    
end

stop_cogent