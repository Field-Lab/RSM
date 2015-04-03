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
        repeat_num 
        
        backgrndcolor
        
        cen_width
        cen_height
        
        stealth_flag
        
	end			% properties block
	
	
	
	methods
		
        function[obj] = Random_Noise_CDF_LUT( stimuli, exp_obj )
            
            if (isfield(stimuli,'rgb'))
                rgb_vect = [stimuli.rgb(1); stimuli.rgb(2); stimuli.rgb(3)];% Note: color is rgb vector in [0-1] format  
                rgb_vect = Color_Test( rgb_vect );
            else
                fprintf('\t RSM ERROR: rgb not recognized. Please define rgb value and try again. \n');
                return
            end
        
            % stimuli.sigma for Gaussian into units of grayscale (e.g. sigma 0.16 means that 3 sigmas just bumps into the gamut, which is ±0.5 ).
     
            if (isfield(stimuli,'sigma'))
                obj.sigma = stimuli.sigma;        
            else
                fprintf('\t RSM ERROR: Gaussian gigma value not recognized. Please define sigma value and try again. \n');
                return
            end
 
            
            [ obj ] = Set_LUT(obj, rgb_vect);
            
            
            if (isfield(stimuli,'x_start'))
                if (isfield(stimuli,'x_end'))
                
                    % flip around if needed for proper ordering
                    if (stimuli.x_start > stimuli.x_end)
                        temp = stimuli.x_start;
                        stimuli.x_end = temp;
                        stimuli.x_start = stimuli.x_end;
                        clear temp
                    end
            
                else
                    fprintf('\t RSM ERROR: x-end not recognized. Please define x_end value and try again. \n');
                    return
                end  
            else
                fprintf('\t RSM ERROR: x-start recognized. Please define x_start value and try again. \n');
                return
            end  
        
        
        
            if (isfield(stimuli,'y_start'))
                if (isfield(stimuli,'y_end'))
                
                    % flip around if needed for proper ordering
                    if (stimuli.y_start > stimuli.y_end)
                        temp = stimuli.y_start;
                        stimuli.y_end = temp;
                        stimuli.y_start = stimuli.y_end;
                        clear temp
                    end
                    
                    % STUB FOR FUTURE DEVELOPMENT
            
                else
                    fprintf('\t RSM ERROR: y-end not recognized. Please define y_end value and try again. \n');
                    return
                end  
            else
                fprintf('\t RSM ERROR: y-start recognized. Please define y_start value and try again. \n');
                return
            end  
        
        
            [ obj.x_cen_offset ] = Find_Cen_Offsets( stimuli.x_start, stimuli.x_end, exp_obj.monitor.width );
        
            [ obj.y_cen_offset ] = Find_Cen_Offsets( stimuli.y_start, stimuli.y_end, exp_obj.monitor.height );


            if (isfield(stimuli,'stixel_width'))
                if (isfield(stimuli,'stixel_height'))
                   if (isfield(stimuli,'field_width'))    
                       if (isfield(stimuli,'field_height'))
                           
                           % Check for validity of stixel setup
                            if ((stimuli.stixel_width * stimuli.field_width) > exp_obj.monitor.width) 
                                fprintf('\t RSM ERROR: Stimulus width exceeds display width. Please redfine stixel_width and/or field_width and try again. \n');
                                return
                            end
                            
                            if ((stimuli.stixel_height * stimuli.field_height) > exp_obj.monitor.height) 
                                fprintf('\t RSM ERROR: Stimulus height exceeds display height. Please redfine stixel_height and/or field_height and try again. \n');
                                return
                            end
    
                            obj.stixel_width = stimuli.stixel_width;            
                            obj.stixel_height = stimuli.stixel_height;            
                            obj.field_width = stimuli.field_width;
                            obj.field_height = stimuli.field_height;
                       
                       else
                           fprintf('\t RSM ERROR: height in stixels ("field_height") not recognized. Please define field_height and try again. \n');
                           return
                       end
                   else
                       fprintf('\t RSM ERROR: width in stixels ("field_width") not recognized. Please define field_width and try again. \n');
                       return
                   end
                else
                   fprintf('\t RSM ERROR: stixel height in pixels ("stixel_height") not recognized. Please define stixel_height value and try again. \n');
                   return
                end 
            else
                fprintf('\t RSM ERROR: stixel width in pixels ("stixel_width") not recognized. Please define stixel_width value and try again. \n');
                return
            end
        
            
            [ obj.sync_pulse ] = Sync_Setup_Util( stimuli, exp_obj );

        
            if (isfield(stimuli,'stop_frame'))
                obj.stop_frame = stimuli.stop_frame;        
            else
                fprintf('\t RSM ERROR: stop_frame not recognized. Please define stop_frame value and try again. \n');
                return
            end
        
            obj.n_repeats = 1;

            if (isfield(stimuli,'duration'))
                if (isfield(stimuli,'interval'))
                    if (isfield(stimuli,'seed'))

                            obj.run_duration = stimuli.duration;
                            obj.stim_update_freq = stimuli.interval;
                            obj.rng_init.state = stimuli.seed;
                          
                    else
                           fprintf('\t RSM ERROR: rng seed value ("seed") not recognized. Please define seed and try again. \n');
                           return
                    end
                else
                    fprintf('\t RSM ERROR: stimulus update frequency ("interval") not recognized. Please define interval value and try again. \n');
                    return
                end 
            else
                fprintf('\t RSM ERROR: run duration value ("duration") not recognized. Please define duration value and try again. \n');
                return
            end
            
                    
              
            obj.backgrndcolor = [stimuli.back_rgb(1); stimuli.back_rgb(2); stimuli.back_rgb(3)];
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
  
           % These are pre-calculated once at construction
            obj.span_width = obj.field_width * obj.stixel_width;
            obj.span_height = obj.field_height * obj.stixel_height;
            
            blank = zeros(4, obj.field_width, obj.field_height, 'uint8');
            
            blank(4,:,:) = ones(1, obj.field_width, obj.field_height, 'uint8') * 255;
            obj.blank_frame = blank;
           
            obj.r_stream = [];
            obj.frames_shown = 0;
            obj.repeat_num = 0;
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