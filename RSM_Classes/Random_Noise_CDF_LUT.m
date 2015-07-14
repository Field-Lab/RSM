% Random_Noise: Present on-the-fly random noise stimuli.
%
%        $Id: Random_Noise VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)


classdef	Random_Noise_CDF_LUT < handle


	properties
        
        stim_name
        
        run_date_time
        run_time_total
        
        main_trigger
        tmain0
        
        rep_trigger
        trep0

        run_duration
        stim_update_freq                
        
        run_script
 
 
        x_cen_offset
        y_cen_offset
        
        field_width
        field_height
        stixel_width
        stixel_height
        span_width
        span_height

        blank_frame
        
        r_stream

        make_frame_script
        
        rng_init        
                
        timestamp_record
         
        frame_save 
        frame_record
       
        frames_shown
        
        rerun_lim
        rerun_num
        saved_tex
        
        digin_dummy
        
        countdown
        
        frametex
        
        wait_key
        wait_trigger

        LUT
        num_lut_levels
        cdf_vect
        sigma

        sync_pulse
        stop_frame
        
        n_repeats
        
        backgrndcolor
        
        cen_width
        cen_height
        
        stealth_flag
        
	end			% properties block
	
	
	
	methods
		
        function[obj] = Random_Noise_CDF_LUT( stimuli, exp_obj )             
 
            %%%%%  check if all user-defined fields exist  %%%%%
            
            user_fields = {'rgb','sigma','x_start', 'x_end','y_start','y_end',...
            'stixel_width','stixel_height','field_width','field_height','stop_frame',...
            'duration', 'seed', 'interval', 'wait_trigger', 'wait_key'};
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
            
            %%%%%  These are copied from stimuli and exp_obj fields  %%%%%
            
        
            % stimuli.sigma for Gaussian into units of grayscale (e.g. sigma 0.16 means that 3 sigmas just bumps into the gamut, which is ±0.5 ).
            obj.sigma = stimuli.sigma;
            
            rgb_vect = stimuli.rgb';% Note: color is rgb vector in [0-1] format
            rgb_vect = Color_Test( rgb_vect );
            [ obj ] = Set_LUT(obj, rgb_vect);
 
        
            % Offsets of the stimulus center pixel from the screen center
            % pixel.
            obj.x_cen_offset = Find_Cen_Offsets( stimuli.x_start, stimuli.x_end, exp_obj.monitor.width );
            obj.y_cen_offset = Find_Cen_Offsets( stimuli.y_start, stimuli.y_end, exp_obj.monitor.height );

            obj.stixel_width = stimuli.stixel_width;
            obj.stixel_height = stimuli.stixel_height;
            obj.field_width = stimuli.field_width;
            obj.field_height = stimuli.field_height;
            
            obj.span_width = obj.field_width * obj.stixel_width;
            obj.span_height = obj.field_height * obj.stixel_height;
            
            % Check for validity of stixel setup
            if obj.span_width ~= abs(stimuli.x_start-stimuli.x_end)
                fprintf('\t RSM ERROR: Stimulus width (x) in stixels and pixels does not match \n');
                return
            end
            
            if  obj.span_height ~= abs(stimuli.y_start-stimuli.y_end)
                fprintf('\t RSM ERROR: Stimulus height (y) in stixels and pixels does not match \n');
                return
            end
            

                       
        
            
            [ obj.sync_pulse ] = Sync_Setup_Util( stimuli, exp_obj );
            
            
            obj.stop_frame = stimuli.stop_frame;
            
            obj.run_duration = stimuli.duration;
            obj.stim_update_freq = stimuli.interval;
            obj.rng_init.state = Init_RNG_JavaStyle(stimuli.seed);
            obj.n_repeats = stimuli.n_repeats;
                          
            obj.backgrndcolor = stimuli.back_rgb';
            obj.backgrndcolor = Color_Test( obj.backgrndcolor );
            
            obj.frame_save = 0; % turning on frame save dramatically slows program. Turn on for debug only.         
            obj.wait_trigger = stimuli.wait_trigger;                            
            obj.wait_key = stimuli.wait_key;
                
            obj.stim_name = 'Random Noise Gaussian';
            obj.run_script = 'Run_OnTheFly(exp_obj.stimulus);'; %'Run_Random_Noise(exp_obj.stimulus);';
            obj.make_frame_script = '[lastdraw, img_frame] = Random_Texture_CDF(stim_obj.rng_init.state, stim_obj.field_width, stim_obj.field_height, stim_obj.LUT, stim_obj.cdf_vect, stim_obj.num_lut_levels);';

            obj.run_date_time = [];
            obj.run_time_total = [];
                
            obj.main_trigger = 0;
            obj.tmain0 = [];
 
            
            % For random noise start out with a gauranteed valid
            % rep_trigger (since we use rep_triggering only for update freq
            % control
            obj.rep_trigger = 1;
            obj.trep0 = [];
            
            num_frames_planned = (obj.run_duration * ceil(exp_obj.monitor.screen_refresh_freq)) +1;  % +1 and ceil provide a "buffer factor" to eliminate worrys about exceeding array size
            obj.timestamp_record = zeros(obj.n_repeats,num_frames_planned);
            obj.frame_record = [];
            
            blank = zeros(4, obj.field_width, obj.field_height, 'uint8');
            
            blank(4,:,:) = ones(1, obj.field_width, obj.field_height, 'uint8') * 255;
            obj.blank_frame = blank;
           
            obj.r_stream = [];
            obj.frames_shown = 0;
            obj.rerun_lim = 3;
            obj.rerun_num = 0;
            obj.saved_tex = [];
            obj.digin_dummy = [];
            obj.countdown = 1;
            obj.frametex = [];
            
            obj.cen_width = exp_obj.monitor.cen_width;
            obj.cen_height = exp_obj.monitor.cen_height;
            
            obj.stealth_flag = exp_obj.stealth_flag;
         
		end		% constructor 
        
        
       
        
        function[ obj ] = Set_LUT(obj, rgb_vect)
            
            obj.num_lut_levels = 1024;

            % Goal is to simulate 3 sigma worth of Gaussian range
            % within the number of lut levels (so first lut is -3 sigma)
            x = linspace(-3, 3, obj.num_lut_levels);

            % Note we scale sigma in grayscale units so that sig 0.16 in grayscale
            % units maps to 1 as far as matlab cdf is concerned (this means
            % that my x values will be appropriate).]

            working_sigma = obj.sigma / 0.16;

            % if user puts in 0.08 then that means a narrower gaussian
            % now, if we take out x span as fixed then we want each unit of
            % the x-axis to count for deviation further out on the gaussian, so the
            % sigma we send to the cdf is 0.5

            cdf_vect = cdf('norm',x, 0, working_sigma);

            obj.cdf_vect = single(cdf_vect);
            
            lut = ones(obj.num_lut_levels, 3);
            lut = lut / 2;
                                                % Max level of modulation
                                                % at 3 sigma is set by
                                                % rgb_vect 
            lut(:,1) = lut(:,1) + ((x /3) * rgb_vect(1))'; 
            lut(:,2) = lut(:,2) + ((x /3) * rgb_vect(2))';
            lut(:,3) = lut(:,3) + ((x /3) * rgb_vect(3))';

            lut = round(lut * 255);

            lv_i = 0;

            for i = 1:obj.num_lut_levels,
   
                for j = 1:3,
        
                    lv_i = lv_i + 1;
                    lut_vect(lv_i) = lut(i,j);
    
                end
            end

            obj.LUT = uint8(lut_vect); 
        end  % set lut
            
            
    end			% methods block
    
        
end             % Random Noise classdef