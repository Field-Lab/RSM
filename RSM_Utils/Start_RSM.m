% Start_RSM: Script to start up RSM session
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%    purpose: Script to start up RSM session.
%      usage: Called once (only!) at beginning of session.

clear RSM_GLOBAL;  % wipe out any old experimental session objects left sitting around in the workspace

clc;
 
exp_setup = Setup_Rig;  

exp_setup.session_name = cat(2, date, '_Rig', exp_setup.rig_ID);
exp_setup.session_name_fn = exp_setup.session_name;
exp_setup.session_diary_fn = cat(2, exp_setup.session_name,'_matDiary');


global RSM_GLOBAL

RSM_GLOBAL = Experimental_Session(exp_setup);

prerun_obj = Experimental_Session(exp_setup);

clear exp_setup;

RSM_GLOBAL.RSM_ver = 1.0;

% Before we begin in earnest we change directories to the home directory
% cd( RSM_GLOBAL.home_dir_name ); % ATH commented out


% Next we open the stim window in which stimulus will display
fprintf('RSM Configuring display for %4.3f [Hz] \n', RSM_GLOBAL.monitor.screen_refresh_freq);

mglOpen( RSM_GLOBAL.monitor.mon_num, RSM_GLOBAL.monitor.width, RSM_GLOBAL.monitor.height, RSM_GLOBAL.monitor.screen_refresh_freq );    
             
mglScreenCoordinates;      % set screen coord system to pixels with 0,0 in up-left corner

mglSetGammaTable( RSM_GLOBAL.monitor.red_table, RSM_GLOBAL.monitor.green_table, RSM_GLOBAL.monitor.blue_table );

mglClearScreen( RSM_GLOBAL.monitor.backgrndcolor );
            
mglFlush;



% Finally lets initialize the DIO (we will simply use the default port
% values specified by Justin
mglDigIO('init');

% 6501 Output line starts high (~ +4.4 V), clear the line with a pulse
Pulse_DigOut_Channel;

% NB: THIS DOES NOT OUTPUT A PULSE. It merely causes the line voltage to
% drop low. 

Prerun_RNstim( prerun_obj ); 

clear prerun_obj;

global display;
display = RSM_GLOBAL.monitor;
fprintf('"display" object set for monitor: %s.\n', RSM_GLOBAL.monitor.monitor_name);

fprintf('RSM initialization complete.\n');
fprintf('Cut and paste desired params. Enter: "RSM" to present stimuli; "Stop_RSM" to quit. \n\n');
    
% MAIN EXPERIMENTAL SESSION IS CONDUCTED FROM MAIN MATLAB COMMAND LINE
% WE ARE DONE WITH INIT

