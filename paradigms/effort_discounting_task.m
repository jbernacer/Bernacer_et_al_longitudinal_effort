% Entering volunteer's info 
  Volunteer =input('Volunteer : ','s'); %Asks for volunteer's name
  Sesion_number=input('Sesion number: ','s');
  LogFileName=strcat(Volunteer,' - [',datestr(now,0),']','- EFFORT_PILOT_sesion_',Sesion_number,'.log'); %Indicates name for log file
  LogFileName = strrep(LogFileName,':','.'); %Substitutes ":" for "." if necessary
  results_name=strcat('pilot_effort_',Volunteer,'_sesion_', Sesion_number,'.res');


config_display(0);
config_data('pilot_effort.dat');
config_log(LogFileName);
config_results(results_name);
config_keyboard(100,5,'nonexclusive');
start_cogent;
random_order=randperm(countdatarows);

for w=1:countdatarows
    
    clearkeys;
    response=0;
    j=random_order(w);
    clearpict(1);
    positions=[-150, 150]';
    pos_image_effort_0=positions(randi(2));
    preparestring('5 €',1,pos_image_effort_0,50);
    preparestring('0 min',1,pos_image_effort_0,-50);
    if pos_image_effort_0==-150
        pos_image_B=150;
    else
        pos_image_B=-150;
    end
    b_money=getdata(j,1);
    b_walk=getdata(j,2);
    text_b_money=strcat(b_money, ' €');
    preparestring(text_b_money,1,pos_image_B,50);
    text_b_walk=strcat(b_walk, ' min');
    preparestring(text_b_walk,1,pos_image_B,-50);
    option_b_name=strcat(getdata(j,1),'-',getdata(j,2));
    logstring(option_b_name);
    drawpict(1);
    waitkeydown(inf,[97,98]); 
    [ key, t, n ] = getkeydown;
    readkeys;
    if isempty(key)==1
        response=NaN;
    else
    response=key(1);
    end
    logstring(pos_image_B);
    logkeys;
    addresults(b_money,b_walk,pos_image_B,response);
    
    
    
    
end

stop_cogent