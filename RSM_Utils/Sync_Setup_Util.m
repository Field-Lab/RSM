function[ sync_pulse_S ] = Sync_Setup_Util( stimuli, exp_obj )            

if (isfield(stimuli,'interval_sync')) % Then we simply use the old default setup
            
                sync_pulse_setup.sync_pulse_flag = stimuli.interval_sync; %4; % 1 = Lower-left, 2 = Upper-left, 3 = Lower-Right, 4 = Upper-Right
                sync_pulse_setup.sync_pulse_width = 100;
                sync_pulse_setup.sync_pulse_height = 100;
                sync_pulse_setup.sync_pulse.color = [1; 1; 1];
                sync_pulse_setup.monitor_width = exp_obj.monitor.width;
                sync_pulse_setup.monitor_height = exp_obj.monitor.height;

                sync_pulse_S = Set_Sync_Vertices(sync_pulse_setup);
                
elseif (isfield(stimuli,'interval_sync_xstart') )
    
    if (isfield(stimuli,'interval_sync_xend'))
        
        if (isfield(stimuli,'interval_sync_ystart'))
            if (isfield(stimuli,'interval_sync_yend'))
                
                [ sync_pulse_S ] = Set_Sync_Vertices2( stimuli, exp_obj.monitor.width, exp_obj.monitor.height, [1; 1; 1] ); % Hardset of color for syncpulse
                
            else
                   fprintf('\t RSM ERROR: Sync pulse y-end not recognized. Please define sync pulse y-end value and try again. \n');
                   return
            end
        else
            fprintf('\t RSM ERROR: Sync pulse y-start not recognized. Please define sync pulse y-start value and try again. \n');
            return
        end % y-start test
            
    else
        fprintf('\t RSM ERROR: Sync pulse x-end not recognized. Please define sync pulse x-end value and try again. \n');
        return
    end % x-end test
           
                
else
    fprintf('\t RSM Warning: sync pulse not configured. Default to no sync pulse. \n');
    sync_pulse_S = [];
                
end
            
            
