% Experimental_Session: Class definition. 
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%    purpose: Role
%      usage: Used once in Start_RSM. 


classdef	Experimental_Session < handle

	properties
        debug_flag 
        
        dio_config 
        
        home_dir_name
        monitor_dir_name
        movie_path
        map_path
        
        host_name
        
        log_file_dir
        
        mex_rng_flag
        
        monitor
        
        num_stim_ran
        
        past_stimuli
        
        pending_stimuli
        
        rig_ID                  
        
        rig_geom               
                       
        RSM_ver
                    
        session_fn
        
        session_name
        
        stealth_flag
        
        stimulus
           
        prerun_path

        
	end % properties block
	
	
	methods
	
		function obj = Experimental_Session( varargin )     % Constructor method
            
            % *** Vargin input sanity check goes here. ***
            
            if ( ~isempty( varargin ) )
                % Then we assume a non-setup-script session
                % We will use command line setup mode
                
                if (nargin == 2)
                    % Then user has provided an exp setup stucture (first
                    % arguement) and session name (second arg).
                    exp_session = varargin{1};
                    exp_session.session_name = varargin{2};
                    exp_session.session_fn = varargin{2};
                    
                elseif (nargin == 1)
                    exp_session = varargin{1};
                    
                else
                    disp('Number of arguements is inappropriate.');
                    keyboard
               
                end  % test for number of arguements
                 
            else    
                % If we use the constructor with no arguement then we:
              
                % Prompt user for rig identifier
                %exp_session.rig_ID = input('Enter rig id string [A, B or C]: ', 's');
                
                % Invoke appropriate Setup session script
                exp_session = Setup_Rig;  
                
                % Set names based on user input
                [ exp_session.session_name, exp_session.session_fn ] = Set_NameAndFN;
                
            end
            
            % Now we have all setup information, tranfer to session object
            obj.host_name = exp_session.host_name;
            obj.rig_ID = exp_session.rig_ID;
   
            obj.monitor_dir_name = exp_session.monitor_dir_name;
            obj.log_file_dir = exp_session.log_file_dir;
            obj.movie_path = exp_session.movie_path;
            obj.prerun_path = exp_session.prerun_path;
            obj.map_path = exp_session.map_path;

            
            obj.dio_config.numframes_per_pulse = 100;   % Every 100th frame provide an output pulse
            obj.dio_config.trigger_sample_rate = 100;   % 100 Hz sample rate
            obj.dio_config.outpulse_duration = 0.001;   % 1ms duration

            obj.rig_geom.optical_path_length = 57;      % cm, useful distance for setting up grating stimuli
            obj.rig_geom.zoom_factor = [];

            
            obj.monitor = exp_session.monitor.obj;  % Note: this syntax is necessary due to the way we load up the monitor obj in setup_rig
            
            obj.stimulus = [];

            obj.pending_stimuli = [];

            obj.past_stimuli = [];
            
            obj.home_dir_name = exp_session.home_dir_name;
 
            obj.session_name = exp_session.session_name;

            obj.session_fn = exp_session.session_fn;
            
            obj.num_stim_ran = 0;
            
            obj.RSM_ver = [];
            
            strict_date_check = false;

            if (strict_date_check)
                % Now we also test whether the gamma calibration is out of date
                stale_calibration_limit = 30; % days

                % Find serial dates for calibration and present date
                if (~isempty( obj.monitor.gamma_test_date ) )                
                    d0 = datenum( obj.monitor.gamma_test_date );
                
                    dp = datenum( date );       % This is datenum of present date
            
                    % Now test calibration
                    if ( (dp - d0) > stale_calibration_limit )
                        fprintf('\n \n');
                        fprintf('RSM WARNING! Gamma calibration is older than %d days! \n', stale_calibration_limit);
                        [ testval ] = Tested_Input_Logical( 'Enter (1) to test monitor linearity or (0) to continue blindly:  ' );
                        if (testval)
                            Test_Monitor_Linearity(obj.monitor);
                        end
                    end  % check on gamma calibration date
                
                else
                    fprintf('\n \n');
                    fprintf('RSM WARNING! No monitor gamma calibration date. Using default gammma. \n');
                end % gamma date test

            end % test for strict date check
            
            obj.stealth_flag = 0;
            
            obj.debug_flag = 0;
         
            
		end		% constructor method
        
        	
	end % methods block
	
	
end		% experimental session class