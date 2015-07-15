% cd('/Users/alexandra/Desktop/matlab_stimulation/RSM/RSM_Utils/RNG_UTILS')
% mex random_map.c


%% Initialization

cd('/Users/alexandra/Desktop/matlab_stimulation')

Start_RSM;
mglSetGammaTable( RSM_GLOBAL.monitor.red_table, RSM_GLOBAL.monitor.green_table, RSM_GLOBAL.monitor.blue_table );

% mglMoveWindow(5, 1055);

%% Stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Focus Squares
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Focus squares. </strong>\n');
%
%-----------------------------------------------------------------------------
clear_pending_stim


stimulus = [];
stimulus.type = 'FS';
stimulus.stim_width = 800;
stimulus.stim_height = 600;
stimulus.back_rgb = [0.5, 0.5, 0.5];

run_stimulus(display, stimulus);
clear stimulus;


%% Rectangular Flashing Pulses: any sequence
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Rectangular Pulses: any sequence. </strong>\n');
%
%------------------------------------------------------------------------------

clear_pending_stim

stimulus = [];
stimulus.type = 'FPA';  
stimulus.rgb{1} = [1, 0, 1];
stimulus.rgb{2} = [0, 0, 0];
stimulus.rgb{3} = [0, 0, 1];
stimulus.back_rgb = [0.5, 0.5, 0.5];
 % duration of the color flash in frames
stimulus.frames = 30; % minimum 3
 % duration of the background flash in frames (comes before the whole thing
 % and after each color flash) - makes intervals between *repeats* even
 % longer(!) talk to ej. Way out for better timing - specify the whole
 % sequence? shouldn't be a big problem
stimulus.back_frames = 3; % min 3
stimulus.n_repeats = 2;
stimulus.x_start = 120;  stimulus.x_end = 620;
stimulus.y_start = 50;   stimulus.y_end = 650;

stimulus.wait_trigger = 0;
stimulus.wait_key = 1;
run_stimulus(display, stimulus);
clear stimulus;



%% Cone-Isolating Pulse (lut or S file)
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Cone-Isolating Pulse: lut </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'PL'; 
stimulus.control_flag = 1;
stimulus.map_file_name = '1234d01/map-0000.txt';
stimulus.lut_file_name = '1234d01/lut.mat';
% stimulus.map_file_name = '/map_data034/map_data034.txt';
% stimulus.sfile_name = 's36_test'; % provide either lut file name ot sfile name
stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.frames = 20;
stimulus.n_repeats = 3;
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

stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.rgb = [1, 1, 1];
stimulus.rgb = stimulus.rgb - stimulus.back_rgb;
stimulus.bar_width = [120];
stimulus.direction = [0 45 ]; %90 135 180 225 270 315];
stimulus.delta = [5];  % pixel edge length/frame    
stimulus.interval = 0; %frame
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.n_for_each_stim = 2; % how many times each stim (bar) will be shown in randomized sequence
stimulus.n_repeats = 1; % how many identical sequences will be shown

run_stimulus(display, stimulus);
clear stimulus;


%% Moving Grating
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Grating. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim
stimulus = [];
stimulus.type = 'MG'; % MG for moving grating, CG for counterphase grating
stimulus.subtype = 'sine'; % sine or square - only matters for MG (do we want it for CG?)

% these are always required
stimulus.back_rgb = [0.0, 0.0, 0.0];
stimulus.n_for_each_stim = 1; % how many random sequences will be created
stimulus.n_repeats = 1; % how many identical sequences will be shown
stimulus.interval = 1; % blank screen between gratings, seconds
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;

% either define here or in S file
% stimulus.sfile_name = ; % don't have one
stimulus.rgb = [1.0, 1.0, 1.0];
stimulus.phase0 = 0; 
stimulus.temporal_period = 1;  
stimulus.spatial_period = 60;
stimulus.direction = [45];
stimulus.frames = 90; % presentation of each grating, frames 


stimulus.rgb = stimulus.rgb - stimulus.back_rgb;


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
stimulus.independent = 0;
stimulus.interval = 1; % frame
stimulus.seed = 11111;
stimulus.x_start = 450;%  stimulus.x_end = 700;
stimulus.y_start = 300;%   stimulus.y_end = 600;
stimulus.stixel_width = 1;   stimulus.stixel_height = 1;
stimulus.field_width = 600;  stimulus.field_height = 600;        
stimulus.duration = 2;  % sec; duration of each repetition!
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.interval_sync = 0;
stimulus.stop_frame = [];
stimulus.n_repeats = 2;
stimulus.binary = 0;


run_stimulus(display, stimulus);
clear stimulus;

%% Random Noise : Binary on Voronoi
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Random Noise : Binary on Voronoi. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'RN';

stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.rgb = [1.0, 1.0, 1.0];
stimulus.rgb = stimulus.rgb - stimulus.back_rgb;
stimulus.independent = 0;
stimulus.interval = 1; % frame
stimulus.seed = 11111;
stimulus.x_start = 120;  stimulus.x_end = 720;
stimulus.y_start = 0;   stimulus.y_end = 600;
stimulus.stixel_width = 1;      stimulus.stixel_height = 1;       stimulus.field_width = 600;        stimulus.field_height = 600;        
stimulus.duration = 2;  % sec
stimulus.wait_trigger = 0;
stimulus.wait_key = 1;
stimulus.interval_sync = 0;
stimulus.stop_frame = [];
stimulus.n_repeats = 2;
stimulus.map_file_name = '2011-12-13-2_f04_vorcones/map-0000.txt';


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
stimulus.x_start = 120;  stimulus.x_end = 720;
stimulus.y_start = 50;   stimulus.y_end = 650;
stimulus.stixel_width = 15;      stimulus.stixel_height = 15;       stimulus.field_width = 40;        stimulus.field_height = 40;        
stimulus.duration = 3;     
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.interval_sync = 0;
stimulus.stop_frame = [];
stimulus.interval_sync = 1;
stimulus.interval_sync_xstart = 100;
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
clear_pending_stim

stimulus = [];
stimulus.type = 'RG';

stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.rgb = [1.0, 1.0, 1.0];
stimulus.rgb = stimulus.rgb - stimulus.back_rgb;
stimulus.interval = 30;
stimulus.seed = 11111;

stimulus.x_start = 120;  stimulus.x_end = 720;
stimulus.y_start = 50;   stimulus.y_end = 650;
stimulus.stixel_width = 30;      stimulus.stixel_height = 30;       stimulus.field_width = 20;        stimulus.field_height = 20;        
stimulus.duration = 2;     
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.interval_sync = 0;
stimulus.stop_frame = [];
stimulus.sigma = 0.16;

stimulus.n_repeats = 2;

run_stimulus(display, stimulus);
clear stimulus;

%% Raw Movie
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Raw Movie </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim

stimulus = [];
stimulus.type = 'RM';
stimulus.fn = 'test_5_A.rawMovie';
stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.x_cen_offset = 0;   stimulus.y_cen_offset = 0;
stimulus.interval = 1;   
stimulus.preload = 0;
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.interval_sync = 0;
stimulus.stop_frame = [];
stimulus.flip_flag = 1;          % 1 = normal; 2 = vertical flip; 3 = horizontal flip; 4 = vertical + horizontal flip
stimulus.reverse_flag = 0;   % set to 1 for backward (reverse), 0 for forward    
stimulus.first_frame = 1; 
stimulus.last_frame = [];  

stimulus.n_repeats = 1;

run_stimulus(display, stimulus);
clear stimulus;



%%
Stop_RSM








%% Backups



%% Moving Grating
%------------------------------------------------------------------------------
%
fprintf('\n\n<strong> Moving Grating. </strong>\n');
%
%------------------------------------------------------------------------------
clear_pending_stim
stimulus = [];
stimulus.type = 'MG';
stimulus.subtype = 'sine'; % sine or square

% these are always required
stimulus.back_rgb = [0.0, 0.0, 0.0];
stimulus.n_for_each_stim = 1; % how many random sequences will be created
stimulus.n_repeats = 1; % how many identical sequences will be shown
stimulus.interval = 1; % blank screen between gratings, seconds
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;

% either define here or in S file
% stimulus.sfile_name = ; % don't have one
stimulus.rgb = [1.0, 1.0, 1.0];
stimulus.phase0 = 0; 
stimulus.temporal_period = 1;  
stimulus.spatial_period = 60;
stimulus.direction = [0 45];
stimulus.frames = 90; % presentation of each grating, frames 


stimulus.rgb = stimulus.rgb - stimulus.back_rgb;


run_stimulus(display, stimulus);
clear stimulus;


%% Counterphase Grating

fprintf('\n\n<strong> Counterphase Grating. </strong>\n');

clear_pending_stim
stimulus = [];
stimulus.type = 'CG'; 

% these are always required
stimulus.back_rgb = [0.0, 0.0, 0.0];
stimulus.n_for_each_stim = 1; % how many random sequences will be created
stimulus.n_repeats = 1; % how many identical sequences will be shown
stimulus.interval = 1; % blank screen between gratings, seconds
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;

% either define here or in S file
% stimulus.sfile_name = ; % don't have one
stimulus.rgb = [1.0, 1.0, 1.0];
stimulus.phase0 = 0; 
stimulus.temporal_period = 1;  
stimulus.spatial_period = 60;
stimulus.direction = [0 45];
stimulus.frames = 90; % presentation of each grating, frames  

stimulus.rgb = stimulus.rgb - stimulus.back_rgb;
run_stimulus(display, stimulus);
clear stimulus;