function[ exp_obj ] = q_RSM( exp_obj, stimulus )
% q_RSM: This checks for some properties of stimulus. Mostly a switch to
% invoke the proper stimulus object constructor. Note that the returned
% objects are placed in the queue of pending stimulus to be run. 
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
% 
[num_pending, first_nonempty] = Num_Nonempty( exp_obj.pending_stimuli );


% Check for valid exp_obj
if ( ~exist('exp_obj') )
    fprintf('\t RSM ERROR: No experimental session object is present. Please run "Start_RSM". \n');
    return
end
    


% Check for valid stim class variable
if ( ~isfield(stimulus,'type') )
    fprintf('\t RSM ERROR: No valid stim class ("type") variable is present. Please assign stim class variable and try again. \n');
    return
end



if ( ~isfield(stimulus,'back_rgb') )
    fprintf('\t RSM WARNING: No valid background color variable is present. Setting background color to monitor default. \n');
    stimulus.back_rgb = exp_obj.monitor.backgrndcolor; 
end

   

if (~isfield(stimulus,'wait_trigger'))
        stimulus.wait_trigger = 0;
end
  


if (~isfield(stimulus,'wait_key'))
       stimulus.wait_key = 0;
end


if (isfield(stimulus,'trigger_interval'))

    exp_obj.dio_config.numframes_per_pulse = stimulus.trigger_interval;

end
    
    
    
switch stimulus.type

    case 'FS',   % focus squares
       exp_obj.pending_stimuli{num_pending + 1} = Focus_Squares(stimulus, exp_obj);
  
       
       
    case 'SC',  % solid color
        stimulus.control_flag = 4;
        exp_obj.pending_stimuli{num_pending + 1} = PulseCombo(stimulus, exp_obj);
      
        
    case 'FC',  % flashing color
        stimulus.control_flag = 3;
        exp_obj.pending_stimuli{num_pending + 1} = PulseCombo(stimulus, exp_obj);
        
    case 'FP',  % full-field pulses
        stimulus.control_flag = 5;
        exp_obj.pending_stimuli{num_pending + 1} = PulseCombo(stimulus, exp_obj);
        
        
    case 'MB',
        
        [stim, seq, trial_num_total] = rand_stim(stimulus);
        stim_out = stimulus;
        stim_out.trial_list = seq;
        stim_out.trials = stim;
        uisave('stim_out')

        
        for i = 1:trial_num_total
            exp_obj.pending_stimuli{num_pending + i} = Moving_Bar(stim(i));
        end
        
        duration = calc_mb_duration(exp_obj);
        fprintf('STIMULUS DURATION: %d Seconds\n', duration)
 

    case 'MG',
        [stim, seq, trial_num_total] = rand_stim(stimulus);
        stim_out = stimulus;
        stim_out.trial_list = seq;
        stim_out.trials = stim;
        uisave('stim_out')


        
        for i = 1:trial_num_total
            exp_obj.pending_stimuli{num_pending + i} = Moving_Grating(stim(i), exp_obj);
        end
        
        mglSetParam('visualAngleSquarePixels',0,1);
        mglVisualAngleCoordinates(exp_obj.rig_geom.optical_path_length,[exp_obj.monitor.physical_width, exp_obj.monitor.physical_height]);
       
        
    case 'CG',
        [stim, seq, trial_num_total] = rand_stim(stimulus);
        stim_out = stimulus;
        stim_out.trial_list = seq;
        stim_out.trials = stim;
        uisave('stim_out')
        
        for i = 1:trial_num_total
            exp_obj.pending_stimuli{num_pending + i} = Counterphase_Grating(stim(i), exp_obj);
        end
        
        mglSetParam('visualAngleSquarePixels',0,1);
        mglVisualAngleCoordinates(exp_obj.rig_geom.optical_path_length,[exp_obj.monitor.physical_width, exp_obj.monitor.physical_height]);
      
    
    case 'RN',  % random and noise
         exp_obj.pending_stimuli{num_pending + 1} = Random_Noise_Binary_LUT(stimulus, exp_obj);

    case 'RG',  % random and noise
         exp_obj.pending_stimuli{num_pending + 1} = Random_Noise_CDF_LUT(stimulus, exp_obj);


    case 'RM',   % raw movie
        exp_obj.pending_stimuli{num_pending + 1} = Raw_Movie( stimulus, exp_obj );

        
    case 'PL',   % pulse for cone isolation
        stimulus.control_flag = 1;
        exp_obj.pending_stimuli{num_pending + 1} = PulseCombo( stimulus, exp_obj );

        
    otherwise,
      fprintf('\t RSM ERROR: Stim class variable not recognized. Please assign different stim class variable and try again. \n');
      return
      
end % switch   

if (stimulus.wait_trigger)
    
    % Wait for main trigger signal from DAQ
    fprintf('WAITING FOR TRIGGER: %s \n', stimulus.type);
    Scan_4_Trigger( exp_obj );  % recall the timestamp occurs within Scan_4_Trigger
                
elseif (stimulus.wait_key)
        fprintf('WAITING FOR KEY: %s \n', stimulus.type);
        % wait around and check for trigger event
        pause; % wait for key press event

end  % wait for main trigger event






