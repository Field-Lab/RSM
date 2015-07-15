% Random_Noise: Present on-the-fly random noise stimuli.
%
%        $Id: Random_Noise VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)

classdef	Random_Noise_Binary_LUT < handle


	properties
        
        % user-defined
        
        % color
        LUT3bit_vect
        backgrndcolor
        
        % size
        field_width
        field_height
        x_start
        y_start
        span_width
        span_height
        
        % duration, interval, seed
        run_duration
        stim_update_freq
        rng_init
        
        % key, trigger, repeats
        wait_key
        wait_trigger
        n_repeats
        
        % map
        map
        make_frame_script
        
        % stealth mode, timestamps
        stealth_flag
        timestamp_record
        
        % debug
        stop_frame
        sync_pulse
        frame_record
        frame_save

        
        % initialized
        frametex
        run_date_time
        run_time_total
        main_trigger
        tmain0
        trep0
        r_stream
        frames_shown
        digin_dummy
        countdown
          
	end	% properties block
	
    properties(Constant)         
            stim_name = 'Random Noise';
            run_script = 'Run_OnTheFly(exp_obj.stimulus);';
    end
	
	
	methods
		
        function[obj] = Random_Noise_Binary_LUT( stimuli, exp_obj )
             
            %%%%%  check if all user-defined fields exist  %%%%%
            
            user_fields = {'rgb','x_start','y_start','stixel_width','stixel_height',...
                'field_width','field_height','stop_frame','duration', 'seed', 'interval',...
                'independent', 'wait_trigger', 'wait_key'};
            missed_fields=[];
            for i=1:length(user_fields)
                if ~isfield(stimuli,user_fields{i})
                    missed_fields = [missed_fields i];
                end
            end
            if ~isempty(missed_fields)
                for i = missed_fields
                    fprintf(['\t RSM ERROR: ',user_fields{i},' is missing. Please define and try again. \n']);
                end
                return
            end
            
            %%%%%  Taken from stimuli and exp_obj fields  %%%%%
            
            % colors
            rgb_vect = stimuli.rgb';
            rgb_vect = Color_Test(rgb_vect);
            obj = Set_LUT(obj, rgb_vect, stimuli);
            
            obj.backgrndcolor = stimuli.back_rgb';
            obj.backgrndcolor = Color_Test( obj.backgrndcolor );

            % size
            obj.field_width = stimuli.field_width;
            obj.field_height = stimuli.field_height;
            obj.x_start = stimuli.x_start;
            obj.y_start = stimuli.y_start;
            obj.span_width = obj.field_width * stimuli.stixel_width;
            obj.span_height = obj.field_height * stimuli.stixel_height;
            % here we can check if the field will go beyond screen edges -
            % doesn't break the script but some pixels will be NOT shown

            % duration, interval, seed
            obj.run_duration = stimuli.duration;
            obj.stim_update_freq = stimuli.interval;
            obj.rng_init.state = Init_RNG_JavaStyle(stimuli.seed);
            
            % key, trigger, repeats
            obj.wait_trigger = stimuli.wait_trigger;
            obj.wait_key = stimuli.wait_key;
            obj.n_repeats = stimuli.n_repeats;
            
            % fork for map-based (voronoi) WN
            if isfield(stimuli,'map_file_name')
                user_map = load( fullfile(exp_obj.map_path, stimuli.map_file_name) );            
                obj.map.values = uint16( user_map' );
                obj.map.max = max(user_map(:)); 
                obj.map.backrgb = uint8( round( 255 * obj.backgrndcolor));
                obj.make_frame_script = '[lastdraw, img_frame] = random_map(stim_obj.rng_init.state, stim_obj.field_width, stim_obj.field_height, stim_obj.LUT3bit_vect, stim_obj.map.values, stim_obj.map.backrgb,stim_obj.map.max);';
            else
                obj.map = []; 
                obj.make_frame_script = '[lastdraw, img_frame] = Random_Texture_Binary_LUT(stim_obj.rng_init.state, stim_obj.field_width, stim_obj.field_height, stim_obj.LUT3bit_vect);';
            end
            
            % stealth mode (replace with save/not_save user param?)
            obj.stealth_flag = exp_obj.stealth_flag;
            
            % timestamp record
            num_frames_planned = (obj.run_duration * ceil(exp_obj.monitor.screen_refresh_freq)) +1;  % +1 and ceil provide a "buffer factor" to eliminate worrys about exceeding array size
            obj.timestamp_record = zeros(1,num_frames_planned);
            
            % for debug
            obj.stop_frame = stimuli.stop_frame;
            obj.sync_pulse = Sync_Setup_Util( stimuli, exp_obj );
            obj.frame_record = [];
            obj.frame_save = 0; % turning on frame save dramatically slows program. Turn on for debug only.
            

            %%%%%  Simply initialized  %%%%%
            obj.frametex = [];
            obj.run_date_time = [];
            obj.run_time_total = [];
            obj.main_trigger = 0;
            obj.tmain0 = [];
            obj.trep0 = [];
            obj.r_stream = [];
            obj.frames_shown = 0;
            obj.digin_dummy = [];
            obj.countdown = 1;
            obj.rng_init.method = 'mt19937ar';

 
        end% constructor 
        
        
        function[ obj ] = Set_LUT(obj, rgb_vect, stimuli)
            
            % Binary
%             if stimuli.binary
                
                if (stimuli.independent) % RGB
                    
                    lut =     [ 1, 1, 1;...             //0
                        1, 1, -1;...
                        1, -1, 1;...
                        1, -1, -1;...
                        -1, 1, 1;...
                        -1, 1, -1;...
                        -1, -1, 1;...
                        -1, -1, -1];
                    
                else % BW
                    
                    lut =     [ 1, 1, 1;...             //0
                        1, 1, 1;...
                        1, 1, 1;...
                        1, 1, 1;...
                        -1, -1, -1;...
                        -1, -1, -1;...
                        -1, -1, -1;...
                        -1, -1, -1];
                        
                end
                
                for li=1:3
                    lut(:,li) = lut(:,li) * rgb_vect(li) + stimuli.back_rgb(li);
                end
                
%             else % Gaussian
%                 mu = 0.5;
%                 sigma = 0.16;
%                 x = linspace(0, 1, 256*4);
%                 rnds = icdf('norm',x, mu , sigma);
%                 rnds([1, end])=[];
%                 rnds(rnds<0) = [];
%                 rnds(rnds>1) = [];
%                 rnds = repmat(rnds',1,3); 
%                 lut = rnds;
%                 
%             end
            lut = round(255 * lut);    % NB: This cannot be converted to 0 to 1
                        % The reason is that these LUT values get directly
                        % read into the texture input as uint values
                        % Any replacement has to be with uint8 values. 

            lut_vect = reshape(lut', numel(lut),1)';
            obj.LUT3bit_vect = uint8(lut_vect); 
            
        end  % set lut utility
		

	end			% methods block
    
end             % Random Noise classdef