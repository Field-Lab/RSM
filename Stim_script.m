%% Initialization

% Tested on stimulus computer in Greg's lab. The only piece of code that
% does not work is the last one (Cone-Isolating Pulse; As setup by S-file)
% 
% Tested by Xiaoyang Yao
% 2015-04-02
matlabPathRSM = '/Users/xyao/matlab/RSM';
addpath(genpath(matlabPathRSM));
Start_RSM;
mglSetGammaTable( RSM_GLOBAL.monitor.red_table, RSM_GLOBAL.monitor.green_table, RSM_GLOBAL.monitor.blue_table );
mglMoveWindow(0, 1080)

%% Stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Focus Squares
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Focus squares. </strong>\n');
%
%-----------------------------------------------------------------------------
clear_pending_stim


stimulus = [];                                  % This clears the stimulus variable if it has been previously initialized.
stimulus.type = 'FS';                           % "type" field contains 2letter id code for directing RSM desired stimulus setup
stimulus.stim_width = 800;                      % "stim_width" sets width of focus square pattern in pixels. 
stimulus.stim_height = 600;                     % "stim_width" sets height of focus square pattern in pixels. 
stimulus.back_rgb = [0.5, 0.5, 0.5];            % "back_rgb" gives the color of the monitor 'background' (the focus square pattern sits in front of 
                                                % this background color. The range is normalized from 0 to 1. 
run_stimulus(display, stimulus);
clear stimulus;


%% Solid full-screen color
%------------------------------------------------------------------------------
%
fprintf('?\n\n<strong> Solid full-screen color. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus.type = 'SC';
stimulus.back_rgb = [0.5, 0.5, 0.5];              
stimulus.rgb = [1, 0, 0];                           % This sets the color of the solid full screen square. Range is 0-1.
stimulus.rgb = stimulus.rgb - stimulus.back_rgb;   
stimulus.wait_trigger = 0;                          % "wait_trigger" is a logic flag. If set to 1 RSM will wait for a trigger event from the input line.
                                                    % This mode supercedes the wait_key mode. Thus, if 'wait_trigger = 1 and wait_key = 1' it is the 
                                                    % equivalent of 'wait_trigger = 1 and wait_key = 0'. 
stimulus.wait_key = 0;                              % "wait_key" is also a logic flag. wait_key = 1 prompts the user for hitting an input key to start the stimulus.
stimulus.x_start = 0;  stimulus.x_end = 800;        % These fields set the start and stop pixels that control stimulus size.
stimulus.y_start = 0;   stimulus.y_end = 600;

run_stimulus(display, stimulus);
clear stimulus;

%% Flashing full-screen color
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Flashing full-screen color. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'FC';  
stimulus.rgb = [1, 0, 0];
stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.frames = 60;                       % "frames" is the number of frame refreshes to wait for each half-cycle (i.e. the pulse is on for the number of frames set here
                                            % and then off for the same number of frames. This completes one repetition of the pulse.
stimulus.num_reps = 3;                      % "num_reps" gives the number of times the pulse on-off cycle is completed.
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;

run_stimulus(display, stimulus);
clear stimulus;

%% Moving Flashing Square
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Moving Flashing Square. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'MS';  
stimulus.rgb = [1, 1, 1];
stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.frames = 60;                       % "frames" is the number of frame refreshes to wait for each half-cycle (i.e. the pulse is on for the number of frames set here
                                            % and then off for the same number of frames. This completes one repetition of the pulse.

stimulus.x_start = 200;  stimulus.x_end = 600;  % These fields set the start and stop pixels for the overall stimulus field size.
stimulus.y_start = 100;   stimulus.y_end = 500;
stimulus.stixel_width = 40;      stimulus.stixel_height = 40;   % These fields given the size of each stixel in pixels    
stimulus.field_width = 10;       stimulus.field_height = 10;    % These fields control the number of stixels in each direction.    

stimulus.num_reps = 1; % "num_reps" gives the number of times the pulse on-off cycle is completed.
stimulus.repeats = 1; % repeats of the whole stimulus block
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;

run_stimulus(display, stimulus);
clear stimulus;

%% Full Field Pulses (g-w-g-b)
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Full Field Pulses. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'FP';  
stimulus.rgb_white = [1, 1, 1];         % This sets the color of bright step
stimulus.rgb_black = [0, 0, 0];         % This sets the color of dark step
stimulus.back_rgb = [0.5, 0.5, 0.5];    % This sets the color of gray step
stimulus.frames = 60;                   % Number of frames for each step
stimulus.num_reps = 5;                  % Number of 'g-w-g-b' cycles
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
run_stimulus(display, stimulus);
clear stimulus;




%% Moving bar
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Moving bar. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'MB';
stimulus.num_reps = 1;   % This gives the number of times the bar moves across the screen within each individual trial.

stimulus.back_rgb = {[0.5, 0.5, 0.5]};
stimulus.rgb = {[1, 1, 1]};
stimulus.rgb = cellfun(@minus, stimulus.rgb, stimulus.back_rgb, 'Un', 0);

stimulus.bar_width = [360]; % pixel
stimulus.direction = [0 45 90 135 180 225 270 315];
stimulus.delta = [2 4];    % speed of the moving bar, unit: pixel/frame    
stimulus.interval = 30;   % duration of gray screen after each trial, unit: frame
stimulus.x_start = 200; stimulus.x_end = 600;
stimulus.y_start = 100; stimulus.y_end = 500;
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.repeats = 4;    % This gives the number of cycles for each parameter combination
stimulus.wait_1st_trigger = 1; % switch q_RSM.m back and forth to enable this function
run_stimulus(display, stimulus);
clear stimulus;

%% Moving Grating
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Moving Grating. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim
stimulus = [];
stimulus.type = 'MG';
stimulus.subtype = 'square';     % 'square' or 'sine'
stimulus.back_rgb = {[0.25, 0.25, 0.25]};
stimulus.rgb = {[0.75, 0.75, 0.75]};

stimulus.rgb = cellfun(@minus, stimulus.rgb, stimulus.back_rgb, 'Un', 0);
stimulus.phase0 = 0;             % initial phase of the grating. Units are in radians.
stimulus.temporal_period = [4];  % sec
stimulus.spatial_period = [240]; % frame
stimulus.direction = [45];       % Convention 0 deg is 3 oclock
stimulus.frames = 600;           % number of frames for each stimulus trial.
stimulus.interval = 2;           % unit: second
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.repeats = 1; 

run_stimulus(display, stimulus);
clear stimulus;


%% Counterphase Grating
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Counterphase Grating. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'CG';  
stimulus.back_rgb = [0.0, 0.0, 0.0];
stimulus.rgb = [1.0, 1.0, 1.0];
stimulus.rgb = stimulus.rgb - stimulus.back_rgb;
stimulus.phase0 = 0; 
stimulus.temporal_period = 1;  
stimulus.spatial_period = 60;
stimulus.direction = [0 45];

stimulus.frames = 300;        
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.repeats = 1;
stimulus.interval = 2; %Sec
run_stimulus(display, stimulus);
clear stimulus;


%% Random Noise : Binary
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Random Noise : Binary. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'RN';

stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.rgb = [1.0, 1.0, 1.0];
stimulus.rgb = stimulus.rgb - stimulus.back_rgb;
stimulus.independent = 0;           % "independent = 1" denotes that each color's contribution is allowed to vary for a given stixel.
                                    % "independent = 0" denotes that each color's contribution is equal (i.e. stixel is grayscale).
stimulus.interval = 2;              % "interval" controls the number of frames that each random stimulus field is held before refresh.
stimulus.seed = 11111;              % The seed for the random number algorithm.
stimulus.x_start = 100;  stimulus.x_end = 700;  % These fields set the start and stop pixels for the overall stimulus field size.
stimulus.y_start = 0;   stimulus.y_end = 600;
stimulus.stixel_width = 15;      stimulus.stixel_height = 15;   % These fields given the size of each stixel in pixels    
stimulus.field_width = 40;       stimulus.field_height = 40;    % These fields control the number of stixels in each direction.    
stimulus.duration = 5;  % unit: second   
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.interval_sync = 0;  % If "interval_sync" = 0 then no sync pulse square is shown. If this is set to a number (1-4) then a sync pulse square is displayed.
                             % Sync pulse setup is discussed in the next example.
stimulus.stop_frame = [];    % This field can be empty ("[]") in which case the stimulus proceeds till the duration time is reached.
                             % If this field is set to a frame number then the algorthim stops at that frame. (Very useful for debugging).


run_stimulus(display, stimulus);
clear stimulus;

%% Random Noise : Binary. Demo 2- sync pulse
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Random Noise : Binary. Demo 2- sync pulse. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'RN';
stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.rgb = [1.0, 1.0, 1.0];
stimulus.rgb = stimulus.rgb - stimulus.back_rgb;
stimulus.independent = 1;
stimulus.interval = 2;
stimulus.seed = 11111;
stimulus.x_start = 100;  stimulus.x_end = 700;
stimulus.y_start = 0;   stimulus.y_end = 600;
stimulus.stixel_width = 15;      stimulus.stixel_height = 15;       
stimulus.field_width = 40;        stimulus.field_height = 40;        
stimulus.duration = 12;     
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.interval_sync = 0;
stimulus.stop_frame = [];
stimulus.interval_sync = 1;             % This sets the display of a sync pulse. 
                                        % The sync pulse square state changed between 'on' and 'off' when the stimulus array updates (every "interval" number of frames ).
                                        % 1 = Lower-left, 2 = Upper-left, 3 = Lower-Right, 4 = Upper-Right.
                                        
stimulus.interval_sync_xstart = 100;    % These fields define (in pixels) the location of the sync pulse on the screen.
stimulus.interval_sync_xend = 200;
stimulus.interval_sync_ystart = 100;
stimulus.interval_sync_yend = 200;


run_stimulus(display, stimulus);
clear stimulus;


%% Random Noise: Gaussian
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Random Noise: Gaussian. </strong>\n');
%
%------------------------------------------------------------------------------
% Note: Exept for two variables the Gaussian case is the same as the above examples of binary random noise. 
% First, the "independent" field is absent in the Gaussian case. This is because presently only gray-scale Gaussian stimuli are available. 
% Second, there is s new field "sigma" (described below). 

clear_pending_stim

stimulus = [];
stimulus.type = 'RG';

stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.rgb = [1.0, 1.0, 1.0];
stimulus.rgb = stimulus.rgb - stimulus.back_rgb;
stimulus.interval = 3;
stimulus.seed = 11111;

stimulus.x_start = 100;  stimulus.x_end = 700;
stimulus.y_start = 0;   stimulus.y_end = 600;
stimulus.stixel_width = 15;      stimulus.stixel_height = 15;       
stimulus.field_width = 40;        stimulus.field_height = 40;        
stimulus.duration = 5;     
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.interval_sync = 0;
stimulus.stop_frame = [];
stimulus.sigma = 0.16;     % This controls the 1-sigma width of the Gaussian gun command values in gun value units.


run_stimulus(display, stimulus);
clear stimulus;

%% Raw Movie, Demo 1- forward
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Raw Movie, Demo 1- forward. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'RM';                               % See above.
stimulus.fn = 'catcam_forest.rawMovie';             % The filename of the movie. Currently RSM assumes such movies are stored in RSM_Movies.
stimulus.back_rgb = [0.5, 0.5, 0.5];                % See above.
stimulus.x_cen_offset = 0;   stimulus.y_cen_offset = 100; % These fields control the centering of the movie stimulus in pixels. The size of the movie stimulus (in pixels) is given in the .rawMovie header information. 
                                                    % Positive x_cen_offset shifts the stimulus to 'screen-right'(ie the shift is
                                                    % toward the right side of the display monitor when seen face-on.
                                                    % Positive y_cen_offset shifts the stimulus downwards on the display monitor screen.
stimulus.interval = 1;                              % This is the same as in above examples: it gives the number of frames between stimulus changes. 
    % In the movie case there is something worthy of further comment: if
    % the interval = 1 and the display monitor refresh rate in Hz is higher than
    % the frame update rate of the recorded movie in Hz then the movie
    % appears speeded-up. 
stimulus.preload = 0;                               % This option is a hold-over feature but has potential future use for small movies. 
stimulus.wait_trigger = 0;                          % See above.
stimulus.wait_key = 1;                              % See above.
stimulus.interval_sync = 0;                         % See above.
stimulus.stop_frame = [];                           % See above.
stimulus.flip_flag = 1;                             % Movies can be presented with various flip options:
                                                    % 1 = normal; 2 = vertical flip (up-down reversal); 3 = horizontal flip (L-R reversal); 4 = vertical + horizontal flip
stimulus.reverse_flag = 0;                          % The default value of 0 allows the movie to be shown from frame 1 to last frame. 
                                                    % The reverse_flag =1 option is disussed below. 
stimulus.first_frame = 1;                           % This gives the frame number of the movie that is used as the lowest frame number of stimulus movie.
                                                    
stimulus.last_frame = [];                           % This gives the highest frame number of the stimulus movie. 
                                                    % If one wants to run to the end of a movie of unspecified length then "[]" is entered. 
                                                    % If set to '[]' then the final frame of the rawMovie (as stored in the raw file) is used as the highest frame number.  
 
run_stimulus(display, stimulus);
clear stimulus;

%% Raw Movie, Demo 2- reverse
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Raw Movie, Demo 2- reverse. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'RM';                               % See above.
stimulus.fn = 'catcam_forest.rawMovie';              % See above.
stimulus.back_rgb = [0.5, 0.5, 0.5];                 % See above.
stimulus.x_cen_offset = 0;   stimulus.y_cen_offset = 0; % See above.
stimulus.interval = 1;                              % See above.
stimulus.preload = 0;                               % See above.
stimulus.wait_trigger = 0;                          % See above.
stimulus.wait_key = 1;                              % See above.
stimulus.interval_sync = 0;                         % See above.
stimulus.stop_frame = [];                           % See above.
stimulus.flip_flag = 1;                             % See above.
stimulus.reverse_flag = 1;                          % Here we are showing the movie in reverse. 
                                                    % In this situation the last frame field controls where we start presentation.
                                                    % Frames are then presented sequentially in reverse order until the first frame entry is reached.
stimulus.first_frame = 1;                           % See above.
stimulus.last_frame = [];                           % See above.

run_stimulus(display, stimulus);
clear stimulus;

%% Raw Movie, Demo 3- reverse & upside down
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Raw Movie, Demo 3- reverse & upside down; frames 2000 down to 1000. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'RM';                               % See above.
stimulus.fn = 'catcam_forest.rawMovie';             % See above.
stimulus.back_rgb = [0.5, 0.5, 0.5];                % See above.
stimulus.x_cen_offset = 0;   stimulus.y_cen_offset = 0; % See above.
stimulus.interval = 1;                              % See above.
stimulus.preload = 0;                               % See above.
stimulus.wait_trigger = 0;                          % See above.
stimulus.wait_key = 1;                              % See above.
stimulus.interval_sync = 0;                         % See above.
stimulus.stop_frame = [];                           % See above.
stimulus.flip_flag = 2;                             % In this example the movie is flipped upside-down.
stimulus.reverse_flag = 1;                          % We again reun in reverse order. 
stimulus.first_frame = 1000;                        % Since we are in reverse mode this gives the final frame of the presentation.
stimulus.last_frame = 2000;                         % This gives the beginning frame (since we are in reverse mode). 

run_stimulus(display, stimulus);
clear stimulus;

%% Cone-Isolating Pulse
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Cone-Isolating Pulse </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];                                      
stimulus.type = 'PL';                               % See above.
stimulus.map_file_name = '1234d01/map-0000.txt';    % The base path assumes that such files are held in the RSM_Map_Vault directory. The map_file_name gives the rest of the filename path within the RSM_Map_Vault. 
stimulus.lut_file_name = '1234d01/lut.mat';         % See above. 
stimulus.back_rgb = [0.5, 0.5, 0.5];                % See above.
stimulus.frames = 120;                              % "frames" is the number of frame refreshes to wait for each half-cycle (i.e. the pulse is on for the number of frames set here
                                                    % and then off for the same number of frames. This completes one repetition of the pulse.
stimulus.num_reps = 3;                              % See above.
stimulus.wait_trigger = 0;                          % See above.
stimulus.wait_key = 1;                              % See above.

run_stimulus(display, stimulus);
clear stimulus;

%% Cone-Isolating Pulse; As setup by S-file
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Cone-Isolating Pulse; As setup by S-file. </strong>\n');
%
%-----------------------------------------------------------------------------
clear_pending_stim

fprintf('Test takes a long time to complete.\n');

run_test = Tested_Input_Logical('Enter [1] to run demo, or [0] to skip.');

if (run_test)

stimulus = [];
stimulus.type = 'PL';
stimulus.control_flag = 2;
stimulus.sfile_name = 's03';
stimulus.mapfile = '/1234d01/map-0000.txt';

run_stimulus(display, stimulus);

end

Stop_RSM




