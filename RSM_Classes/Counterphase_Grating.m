classdef	Counterphase_Grating < handle
    % Focus_Squares: Presents simple quad-pattern for aid in stimulus focusing
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%
%      usage: Examples
%     inputs: Constructor accepts stimuli definition structure.
%    outputs: Constructor returns Flashing_Color stimulus object. 
%      calls:
%           mglGetSecs
%       	Pulse_DigOut_Channel
%           mglClearScreen
%           mglMakeGrating
%           mglCreateTexture
%           mglBltTexture
%       	mglFlush
%       	mglDeleteTexture
%


	properties
        
        % Required props for all stim classes        
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
        
        wait_key
        wait_trigger
        
        n_repeats
        repeat_num
    
        backgrndcolor
        
        num_reps    
        n_frames
        frames_shown
        reps_run    
        
        physical_width
        physical_height
        
        color
        
        phase_t0
        phase_velocity
        
        grating_sf_pix      % pixels per cycle 
        grating_sf_dva      % cyc per DVA (one DVA is 1 cm on screen)
        
        grating_angle
        
        interval
	
	end			% properties block
	
	
	
	methods
            
        function[obj] = Counterphase_Grating( stimuli, exp_obj )
            
          if ( ~isfield( stimuli, 'parsed_S') )
          %-------------------------------------------------------------------------------------------------------------------    
          % Then we use the stimuli structure constructor mode

            if (isfield(stimuli,'rgb'))
                       
                obj.color = [stimuli.rgb(1); stimuli.rgb(2); stimuli.rgb(3)];          % Note: color is rgb vector in [0-1] format  
                obj.color = Color_Test( obj.color );        
            else
                fprintf('\t RSM ERROR: red gun level ("rg") not recognized. Please define rg value and try again. \n');
                return
            end

            if (isfield(stimuli,'interval'))
                
                obj.interval = stimuli.interval;          %
            else
                fprintf('\t RSM ERROR: stimulus interval not recognized. Please define interval value and try again. \n');
                return
            end
        
            if (isfield(stimuli,'phase0'))
                if (isfield(stimuli,'temporal_period'))
                   if (isfield(stimuli,'spatial_period'))    
                       if (isfield(stimuli,'direction'))
                           
                           if (stimuli.direction >= 360)
                               stimuli.direction = stimuli.direction - 360;
                           end
                           
                           if (stimuli.direction < 0)
                               stimuli.direction = stimuli.direction + 360;
                           end
                           
                         
                            % Convention 0 deg is 3 oclock
                            if  (stimuli.direction >= 0) || (stimuli.direction < 90)
                               polarity_sign = 1;
                                
                            elseif (stimuli.direction >= 90) || (stimuli.direction < 180)
                                polarity_sign = -1;
                                
                            elseif (stimuli.direction >= 180) || (stimuli.direction < 270)
                                polarity_sign = 1;
                                
                            elseif (stimuli.direction >= 270) || (stimuli.direction < 360)
                                polarity_sign = -1;

                            end
                            
                            phase_velocity = polarity_sign * (360 / stimuli.temporal_period);
                           
                            obj.phase_t0 = stimuli.phase0;            
                            obj.phase_velocity = phase_velocity;            
                            obj.grating_sf_pix = stimuli.spatial_period;
                            obj.grating_sf_dva = Convert_SF2DVA( obj.grating_sf_pix, exp_obj );
                            obj.grating_angle = stimuli.direction -90;
                       
                       else
                           fprintf('\t RSM ERROR: height grating direction not recognized. Please define direction and try again. \n');
                           return
                       end
                   else
                       fprintf('\t RSM ERROR: spatial frequency not recognized. Please define spatial_period and try again. \n');
                       return
                   end
                else
                   fprintf('\t RSM ERROR: temporal_period not recognized. Please define temporal_period value and try again. \n');
                   return
                end 
            else
                fprintf('\t RSM ERROR: initial phase not recognized. Please define phase0 value and try again. \n');
                return
            end


            if (isfield(stimuli,'frames'))
                obj.n_frames = stimuli.frames;
            else
                fprintf('\t RSM ERROR: frames not recognized. Please define frames value and try again. \n');
                return
            end
           
            obj.n_repeats = 1;
        
            obj.backgrndcolor = [stimuli.back_rgb(1); stimuli.back_rgb(2); stimuli.back_rgb(3)];
        
             
            obj.num_reps = [];%stim.num_reps;
            obj.wait_trigger = stimuli.wait_trigger;                            
            obj.wait_key = stimuli.wait_key;

            
            obj.stim_name = 'Counterphase_Grating';

            obj.run_date_time = [];
            obj.run_time_total = [];
            
            obj.stim_update_freq = []; % By setting this to empty we remove artificial delay in main execution while loop
            
            obj.main_trigger = 0;       
            obj.tmain0 = [];
            
            obj.rep_trigger = 0;        
            obj.trep0 = [];
            
            obj.run_script = 'Run_CounterPhaseLoop_Rep( exp_obj.stimulus );';
            
            obj.reps_run = 0;
            
            obj.physical_width = exp_obj.monitor.physical_width;
            obj.physical_height = exp_obj.monitor.physical_height;
            
            obj.repeat_num = 0;
            
            obj.frames_shown = 0;
            
            
          else
          %-------------------------------------------------------------------------------------------------------------------    
          % Then we use the S_file constructor mode
            % Contents of parsed_S for moving grating stim
            % This constructor creates a moving grating stimulus based upon
            % the element of the sinusoid structure array specified by
            % stimuli.index. 
          
            %parsed = 

            %   spec: [1x1 struct]     
            %           type: 'REVERSING-SINUSOID'
            %           orientation: 0
            %           frames: 480
            %           x_start: 0
            %           x_end: 800
            %           y_start: 0
            %           y_end: 600

            %   sinusoids: [1x144 struct]
            %           rgb: {[0.4800]  [0.4800]  [0.4800]}
            %           spatial_period: 16
            %           temporal_period: 30
            %           spatial_phase: 6

          
          % The rest of the information is redundant with that found within
          % sinusoids. FOr example, the n-th elements of the following
          % arrays will contain the same information as the n-th element of
          % the sinusoids structure array.
            %   spatialperiods: [1x144 double]
            %   temporalperiods: [1x144 double]
            %   rgbs: {1x144 cell}
            %  spatialphases: [1x144 double]
            
            obj.color = [stimuli.parsed_S.sinusoids(stimuli.index).rgb{1}; stimuli.parsed_S.sinusoids(stimuli.index).rgb{2}; stimuli.parsed_S.sinusoids(stimuli.index).rgb{3}];          % Note: color is rgb vector in [0-1] format  
            obj.color = Color_Test( obj.color );
            
            obj.phase_t0 = stimuli.parsed_S.sinusoids(stimuli.index).spatial_phase;   
            
            obj.grating_sf_pix = stimuli.parsed_S.sinusoids(stimuli.index).spatial_period;
            
            obj.grating_sf_dva = Convert_SF2DVA( obj.grating_sf_pix, exp_obj );
            
            direction = stimuli.parsed_S.spec.orientation;
            
            if (direction >= 360)
                direction = direction - 360;
            end
                           
            if (direction < 0)
                direction = direction + 360;
            end
                           
            obj.grating_angle = direction -90;
                         
           % Convention 0 deg is 3 oclock
           if  (direction >= 0) || (direction < 90)
                polarity_sign = 1;
                                
           elseif (direction >= 90) || (direction < 180)
                polarity_sign = -1;
                                
           elseif (direction >= 180) || (direction < 270)
                polarity_sign = 1;
                                
           elseif (direction >= 270) || (direction < 360)
                polarity_sign = -1;

           end
                            
           obj.phase_velocity = polarity_sign * (360 / stimuli.parsed_S.sinusoids(stimuli.index).temporal_period);
                        
           
           obj.n_frames = stimuli.parsed_S.spec.frames;            
            
            obj.n_repeats = 1; % For construction via S file repeats is always set to 1.
            
            % The background color is set to the monitor default background
            % color
            obj.backgrndcolor = [exp_obj.monitor.backgrndcolor(1); exp_obj.monitor.backgrndcolor(2); exp_obj.monitor.backgrndcolor(3)];
            obj.backgrndcolor = Color_Test( obj.backgrndcolor );
            
            obj.num_reps = [];%stim.num_reps;
            obj.wait_trigger = 0;               % We always turn off triggering for S file construction.                
            obj.wait_key = 0;

            
            obj.stim_name = 'Counterphase_Grating';

            obj.run_date_time = [];
            obj.run_time_total = [];
            
            obj.stim_update_freq = []; % By setting this to empty we remove artificial delay in main execution while loop
            
            obj.main_trigger = 0;       
            obj.tmain0 = [];
            
            obj.rep_trigger = 0;        
            obj.trep0 = [];
            
            obj.run_script = 'Run_CounterPhaseLoop_Rep( exp_obj.stimulus );';
            
            obj.reps_run = 0;
            
            obj.physical_width = exp_obj.monitor.physical_width;
            obj.physical_height = exp_obj.monitor.physical_height;
            
            obj.repeat_num = 0;
        
            obj.frames_shown = 0;
        
          end   % stimuli vs Sfile if-then
     
		end		% constructor 
        
        
        

        function Run_CounterPhaseLoop_Rep( obj )
            
            not_done = 1;
            te = 0; 
            delta_t = 0;
            local_t0 = mglGetSecs;
            te_last = 0;
            phi = obj.phase_t0;
            phi2 = obj.phase_t0;
            
            while( not_done )
    
                % update phase
                phi = phi + (obj.phase_velocity * delta_t);
                
                phi2 = phi2 - (obj.phase_velocity * delta_t);
                
                % test for pulse
                if (obj.phase_velocity > 0) 
                    if ( phi >= (obj.phase_t0 + 360) )
                        phi = phi - 360;
                        Pulse_DigOut_Channel;
                    end
                else 
                    % Then phase_velocity is negative
                    if ( phi <= (obj.phase_t0 - 360) )
                        phi = phi + 360;
                        Pulse_DigOut_Channel;
                    end
                    
                end
                
                phi1 = phi;
                
                                
                % test for pulse
                if (obj.phase_velocity < 0) 
                    if ( phi2 >= (obj.phase_t0 + 360) )
                        phi2 = phi2 - 360;
                    end
                else 
                    % Then phase_velocity is negative
                    if ( phi2 <= (obj.phase_t0 - 360) )
                        phi2 = phi2 + 360;
                    end
                    
                end

 
   
                % Draw the grating
                mglClearScreen( obj.backgrndcolor ); 
                                
                % The phase switch in the phase (phi) is because
                % mglMakeGrating adds the phase offset; whereas EJ wants a
                % subtracted phase offset.

                grating1 = mglMakeGrating(obj.physical_width/4, obj.physical_height/4, 4 * obj.grating_sf_dva, obj.grating_angle, (-1*phi1));
                grating2 = mglMakeGrating(obj.physical_width/4, obj.physical_height/4, 4 * obj.grating_sf_dva, obj.grating_angle, (-1*phi2));

                grating1 = 255*(grating1+1)/2;
                grating2 = 255*(grating2+1)/2; 
                
                grating = (grating1 + grating2) / 2;
               
               colored_grating = cat(3, ( (grating .* obj.color(1)) + round(255 .* obj.backgrndcolor(1)) ), ( (grating .* obj.color(2)) + round(255 .* obj.backgrndcolor(2)) ), ( (grating .* obj.color(3)) + round(255 .* obj.backgrndcolor(3)) ));
                
                tex = mglCreateTexture(colored_grating, [], 0, {'GL_TEXTURE_MAG_FILTER','GL_LINEAR'});
    
                mglBltTexture( tex, [0,0, obj.physical_width, obj.physical_height ] ); 
    
                mglFlush();
                obj.frames_shown = obj.frames_shown + 1;
                
                mglDeleteTexture(tex);
            
                % now update the elapsed time before looping again
                te = mglGetSecs(local_t0);
                
                delta_t = te - te_last;
                te_last = te;
                
                % check for done
                if ( obj.frames_shown > obj.n_frames )
                    
                    not_done = 0;
                    
                end % test for end
            end % tight loop
            
            if obj.interval ~= 0
                mglClearScreen([.5 .5 .5])
                mglFlush
                mglWaitSecs(obj.interval)
            end
  
        end     % run single repetition of bar across screen
	
        
	end			% methods block
    
    
end             % Moving Grating Class