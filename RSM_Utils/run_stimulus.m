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
    
    % qS_RSM is redundant now for cone-specific S-files; there is still
    % reversing sine S-file parsing in there. Consult with EJ if there are
    % any other S-files needed to be implemented.
%     RSM_GLOBAL= qS_RSM(RSM_GLOBAL, stim_in.sfile_name, stim_in.map_file_name); 
     
    % single case use old q_RSM.
    RSM_GLOBAL = q_RSM(RSM_GLOBAL, stim_in);
    RSM_GLOBAL = Stim_Engine_test(RSM_GLOBAL);
%     RSM_GLOBAL = run_RSM(RSM_GLOBAL);
    
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

