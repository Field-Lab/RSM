function[ ] = Prerun_RNstim( prerun_obj )
% Prerun_RNstim: Run a short random noise stimui and a short movie. It does
% this with the stealth flag set. Thus, it is essentially hidden from the
% user. The motive is this: it seems to reduce the latency of the first
% exectution of a random noise or a raw movie stim during an experimental
% session. This reduction in latency is presumably because some kind of
% dynamically linked java libraries have already been loaded during this
% silent pre-run. 
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)


prerun_obj.stealth_flag = 1;

% First we do a random noise movie stimulus.
stimulus.type = 'RN';
stimulus.rgb = 0.48 * [1.0, 1.0, 1.0];
stimulus.back_rgb = [0.5, 0.5, 0.5];
stimulus.independent = 1;
stimulus.interval = 1;
stimulus.seed = 11111;
stimulus.mult = 1;

stimulus.x_start = 160;  stimulus.x_end = 480;
stimulus.y_start = 80;   stimulus.y_end = 400;

stimulus.stixel_width = 10;      stimulus.stixel_height = 10;       stimulus.field_width = 32;        stimulus.field_height = 32;        
stimulus.duration = 1;     
stimulus.wait_trigger = 0;
stimulus.wait_key = 0;
stimulus.interval_sync = 0;
stimulus.stop_frame = [];
stimulus.n_repeats = 1;

[ prerun_obj ] = q_RSM( prerun_obj, stimulus );
[prerun_obj] = run_RSM( prerun_obj );

% Conducting pre-run of RN stim 
fprintf('Silent prerun of RN complete.\n');

clear stimulus


% % Second we do a raw movie stimulus.
% stimulus.type = 'RM';
% stimulus.movie_path = prerun_obj.prerun_path;
% stimulus.fn = 'catcam_forest.rawMovie';
% stimulus.back_rgb = [0.5, 0.5, 0.5];
% stimulus.x_cen_offset = 0;   stimulus.y_cen_offset = 0;
% stimulus.interval = 1;   
% stimulus.preload = 0;
% stimulus.wait_trigger = 0;
% stimulus.wait_key = 0;
% stimulus.interval_sync = 0;
% stimulus.stop_frame = [];
% stimulus.n_repeats = 1;
% stimulus.flip_flag = 1;          
% stimulus.reverse_flag = 0;       
% stimulus.first_frame = 1;
% stimulus.last_frame = 120;        
% 
% [ prerun_obj ] = q_RSM( prerun_obj, stimulus );
% [prerun_obj] = run_RSM( prerun_obj );
% 
% fprintf('Silent prerun of RM complete.\n');
% 
% clear stimulus
 