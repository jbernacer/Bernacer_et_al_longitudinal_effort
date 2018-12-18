% Script corresponding to the EBUDEMA (effort-based uncertainty in decision-making) 
% task: this task consists of the presentation of 2 options, which vary in
% terms of probability to win and physical effort (minutes running) to obtain the reward.
clear all; clc;
% Started on August 19, 2013. 

% Current version: February 13, 2014 - JBM
% February 13, 2014- MMV ( Button box interface) 

% Path Directory: add your own path

% load data, figure files!

flag_MRI = 0; % 1 in the case of in-scanner

% Entering volunteer's info 
Volunteer = input('Volunteer : ','s'); % volunteer's name
LogFileName = strcat(Volunteer,' - [',datestr(now,0),']'); % Indicates name for log file
LogFileName = strrep(LogFileName,':','.'); % Sustituye 2 puntos en nombre por puntos
Sesion_number = input('Sesion number: ','s'); % sesion number (1, 2 or 3)  
  
selected_display = input('Choose display <Window=0, Full screen=1>: '); 
config_display(selected_display) %Open Cogent display 
  
% Choose type of data entry (keyboard or button box)
InputDataType = input('Seleccione entrada- <1> Teclado, <2> Botonera: ');
if isempty(InputDataType) % Default value is button box
      InputDataType = 2;
end
if InputDataType == 2
      disp('estoy en botonera')
      config_serial(1,19200,0,0,8);        
      A = [0 0 0 0 0 0 0 0];               
      dio = digitalio('parallel','lpt1');  
      addline(dio, 0:7, 'out');            
      addline(dio, 8, 'in',{'pin15'});
      addline(dio, 13, 'out',{'pin1'});
      addline(dio, 14, 'out',{'pin14'});
end

data_file = sprintf('%s_sesion_%s.dat',Volunteer,Sesion_number); % Selecting data file. It is really the same for all 3 sessions (although different for each subject)
Final_LogFile = sprintf('%s_Sesion_%s.log',LogFileName,Sesion_number); %Selecting log file
results_file = sprintf('RESULTS_%s_Sesion_%s.res',Volunteer,Sesion_number); % Selecting results file
config_log(Final_LogFile); % Prepare log file to be written
config_data(data_file);
config_results(results_file);
config_keyboard(100,5,'nonexclusive'); % Config keyboard (disable when port input)


response = []; rt = []; invalid_response = [];
start_cogent; % Command to start cogent

addresults('TRIAL NUMBER', 'OPTION LEFT', 'OPTION RIGHT', 'PAIR ONSET', 'KEY (49=L,50=R)', 'REACTION TIME');
preparestring('+',2); % Load fixation point in buffer 2
drawpict( 2 ); % Display fixation point, fixed to 5s the first time
wait( 5000 );

positions_A = [150, -150]'; % Position of option A: right or left
extension = '.jpg';

trial_task = 0;
random_order = randperm(countdatarows);

if flag_MRI == 1
    bit = waitparallelbit(9,inf); % waiting for scanner trigger
end

% STARTING
for i = 1 : countdatarows
    % tStartIt = time; 
    trial_task = trial_task + 1;
               
    timing_cross = random('unif',2000,6000); %Random timing for 2nd fix point
    j = random_order(i); %Get the ith value of the data file
    
    picture_B = getdata(j,2); 
    picture_A = getdata(j,1); 
    picture_B_jpg = strcat(picture_B,extension);
    picture_A_jpg = strcat(picture_A,extension);
    logstring(trial_task);
    logstring(picture_A);
    logstring(picture_B); %Include in the log the name of the option B
              
    if InputDataType == 2 
        clearserialbytes(1);
    else                    
        clearkeys;                          
    end 
              
    if i > 1 % baseline
        drawpict(2); % From trial 2 on, show fixation point
        wait(timing_cross); % And keep it for a random time (2-6s)
    end
    
    % Choose random position for option A:
    shuffle_A = randi(2); % funcion randi
    shuffle_A =  shuffle_A(1);
    random_pos_A = positions_A(shuffle_A);
    
    %Choose random position for option B:
    if shuffle_A == 1
        random_pos_B = -150;
        pos_A = 'right';
        pos_B = 'left';
    else
        random_pos_B = 150;
        pos_A = 'left';
        pos_B = 'right';
    end
    logstring(random_pos_B); %Record in log position of option B
    
    clearpict(1); % Clear picture A in buffer 1
    loadpict(picture_A_jpg, 1, random_pos_A); % Load pics in buffer 1
    loadpict(picture_B_jpg, 1, random_pos_B);
    drawpict(1); % Display picture
        
    % Record time at which picture is presented
    t0 = time;
    logstring( t0 );

    if InputDataType == 1 % For keyboard
        waitkeydown(6000,[97,98]);
        readkeys; % Read all key events since CLEARKEYS was called
        logkeys; % Write key events to log
        [key, t, n ] = getkeydown; %Key: key pressed; t=time; n=how many times
        if n == 0 % no key press
          response = 0;
          rt = 0;
          invalid_response = 'SIN RESPUESTA';
        elseif n == 1 % single key press
          response = key(1);
          rt = t(1) - t0;
          invalid_response = 0;
        else % multiple key press --> data not recorded in this case either
          response = 0;
          rt = 0;
          invalid_response='DEMASIADAS ELECCIONES'; % I think this is not going to happen
        end % if key pressed
        
    elseif InputDataType == 2
          waitserialbyte (1,6000,[49,50,54,55]);
          readserialbytes(1);             

          [key, t, n] = getserialbytes(1); 
          if isempty(n) % no key press
             response = NaN;
             rt = 0;
             invalid_response = 'SIN RESPUESTA'; 
          elseif n == 1 % Key pressed
             datos_key = key';                 
             key_puls = datos_key(1);
             rt = t(1) - t0;
             invalid_response = 0;
             if (key_puls == 54 | key_puls == 49)  
                 response = 1;
             elseif (key_puls == 55 | key_puls == 50)
                 response = 2;
             elseif (key_puls == 56 | key_puls == 51)
                 response = 3;
             elseif (key_puls == 57 | key_puls == 52)
                 response = 4;
             end
          else % multiple key press --> data not recorded in this case either
             response = 0;
             rt = 0;
             invalid_response = 'DEMASIADAS ELECCIONES'; %I think this is not going to happen
          end
    end % del if InputDataType
 
    if random_pos_A == -150
          option_left = picture_A;
          option_right = picture_B;
          addresults(trial_task,option_left,option_right,t0,response,rt);
    elseif random_pos_A == 150
          option_left = picture_B;
          option_right = picture_A;
          addresults(trial_task,option_left,option_right,t0,response,rt);
    end
end % del countdatarows
    
stop_cogent; % Finish presentation