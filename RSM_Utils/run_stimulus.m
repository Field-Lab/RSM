function[ ] = run_stimulus( monitor_description, stim_in )
% This handles both stimulus and stimuli inputs. 
% 
% stim_in can be either a single stimulus structure.
%
% or it might be a cell array, each cell containing a stimulus structure

global RSM_GLOBAL

RSM_GLOBAL.monitor = monitor_description;

% decide: is a structure or a cell array
if ( isstruct( stim_in ) )
    
    if (isfield( stim_in, 'control_flag'))
        if (stim_in.control_flag == 2)
            % This case is used for Sfile constructed stimuli
            RSM_GLOBAL= qS_RSM(RSM_GLOBAL, stim_in.sfile_name, stim_in.mapfile);
            RSM_GLOBAL = run_RSM(RSM_GLOBAL);
        else
            % single case use old q_RSM and run_RSM utils.
            RSM_GLOBAL = q_RSM(RSM_GLOBAL, stim_in);
            RSM_GLOBAL = run_RSM(RSM_GLOBAL);
        end
    else 
        % single case use old q_RSM and run_RSM utils.
        RSM_GLOBAL = q_RSM(RSM_GLOBAL, stim_in);
        RSM_GLOBAL = run_RSM(RSM_GLOBAL);
    
    end
elseif ( iscell( stim_in ) )
    % iterate through cell array and use old q_RSM and run_RSM utils.
    num_cells = length(stim_CA);

    for cell_i = 1:num_cells, 
        
        stimulus = stim_in{cell_i};
        RSM_GLOBAL = q_RSM(RSM_GLOBAL, stimulus);
        RSM_GLOBAL = run_RSM(RSM_GLOBAL);

    end  % loop through cell array

else
    fprint('RSM ERROR: Unrecognized data type. Only "stimulus" structures or "stimuli" cell arrays are valid. \n');
    return

end  % test for  data type

