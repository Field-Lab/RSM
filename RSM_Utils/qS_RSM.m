function[ exp_obj ] = qS_RSM( varargin )
%( exp_obj, S_filename_withpath )
% q_RSM: This checks for some properties of stimuli. Mostly a switch to
% invoke the proper stimulus object constructor. Note that the returned
% objects are placed in the queue of pending stimuli to be run. 
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
% 
if (nargin < 2)
    fprintf('\t RSM ERROR: Not enough arguments for qS_RSM. \n');
    return
end

exp_obj = varargin{1};
S_filename_withoutpath = varargin{2};


% Check for valid exp_obj
if ( ~exist('exp_obj') )
    fprintf('\t RSM ERROR: No experimental session object is present. Please run "Start_RSM". \n');
    return
end

exp_obj.stealth_flag = 1; % All S files operate in stealthed mode 
fprintf('\t RSM entering stealth mode 1. \n');
fprintf('\t To reset, enter: "RSM_Global.stealth_flag = 0" after run completes.\n');

[num_pending, first_nonempty] = Num_Nonempty( exp_obj.pending_stimuli );

S_filename_withpath = fullfile(exp_obj.map_path, S_filename_withoutpath);
parsed_S = read_stim_lisp_output_hack(S_filename_withpath);


stimuli.parsed_S = parsed_S;

% Check for parse_S
if ( isempty(parsed_S) )
    fprintf('\t RSM ERROR: No valid parsed S file structure. Please try again. \n');
    return
end

    
switch parsed_S.spec.type,
        
    case 'REVERSING-SINUSOID',
        
        num_S_entries = length(parsed_S.sinusoids);
        counter = num_pending;

        for i = 1:num_S_entries,    
            counter = counter + 1;
            stimuli.index = i;
            exp_obj.pending_stimuli{counter} = Counterphase_Grating( stimuli, exp_obj );
        end
    
        mglSetParam('visualAngleSquarePixels',0,1);
        mglVisualAngleCoordinates(exp_obj.rig_geom.optical_path_length,[exp_obj.monitor.physical_width, exp_obj.monitor.physical_height]);
      
     
        
    case 'PULSE',   % cone isolating pulse stimuli
        
        if (nargin == 3)
            stimuli.map_file_name = varargin{3};
            stimuli.map_file_path = 'RSM/RSM_Map_Vault';
        elseif (nargin == 4)
            stimuli.map_file_name = varargin{3};
            stimuli.sfile_path = varargin{4};
        else
            fprintf('\t RSM ERROR: Invalid number of arguements for qS_RSM. Please try again. \n');
            return
        end
        
        num_S_entries = length(parsed_S.pulses);
        counter = num_pending;
        
        % Set up the map file
        map_filename = cat(2, stimuli.map_file_path, stimuli.map_file_name);
            
        map = load( map_filename );
            
        map = map';  % NB: The transposing of the matrix was estabilished by comparison to the older style code that read in the 
                        % map to build up the image mat within matlab.
                        
        % Condition inputs to Make_Map
        map = uint8( map );
             
        stimuli.map = map;            
        
        % Preallocating pending stim
        stimuli.index = 1;
        stimuli.control_flag = 2;
        dummy{1} = PulseCombo( stimuli, exp_obj );
        
        exp_obj.pending_stimuli = repmat(dummy,1,num_S_entries);
        
        fprintf('\t Constructing stimuli from S-file. \n');
            
        for i = 1:num_S_entries,    
            counter = counter + 1;
            stimuli.index = i;
            stimuli.control_flag = 2;
            exp_obj.pending_stimuli{counter} = PulseCombo( stimuli, exp_obj );
        end
        
        fprintf('\t Finished stimulus construction. \n');
        
    otherwise,
      fprintf('\t RSM ERROR: Stim class variable not recognized. Please assign different stim class variable and try again. \n');
      return
      
end % switch   

clear stimuli;





