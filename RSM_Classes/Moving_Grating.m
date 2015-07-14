classdef	Moving_Grating < handle
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)

    properties
        
        % Required props for all stim classes
        
        % could come from S file or user-given
        color
        phase_t0
        grating_sf_pix % pixels per cycle
        phase_velocity
        n_frames
        
        % background color
        backgrndcolor
        
        % more params
        grating_sf_dva      % cyc per DVA (one DVA is 1 cm on screen)
        grating_angle
        
        % monitor size - always full field
        physical_width
        physical_height
        
        % interval
        interval
        
        %subtype
        subtype
        
        % key, trigger, repeats
        wait_key
        wait_trigger
        n_for_each_stim
        n_repeats
        
        % initialized
        run_date_time
        run_time_total
        stim_update_freq
        main_trigger
        tmain0
        trep0
        frames_shown

    end	% properties block
    
    properties(Constant)
            stim_name = 'Moving_Grating';
            run_script = 'Run_PhaseLoop_Rep( exp_obj.stimulus );';
    end
	
	
	
	methods
		
        % Constructor method
        function[obj] = Moving_Grating( stimuli, exp_obj )
            
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
            
            %%%%%  check if all user-defined fields exist  %%%%%
            
            user_fields = {'back_rgb', 'subtype', 'interval', 'n_for_each_stim',...
                'n_repeats', 'wait_trigger', 'wait_key'};
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
            
            if isfield( stimuli, 'parsed_S')
                obj.color = [stimuli.parsed_S.sinusoids(stimuli.index).rgb{1}; stimuli.parsed_S.sinusoids(stimuli.index).rgb{2}; stimuli.parsed_S.sinusoids(stimuli.index).rgb{3}];          % Note: color is rgb vector in [0-1] format
                obj.phase_t0 = stimuli.parsed_S.sinusoids(stimuli.index).spatial_phase;
                obj.grating_sf_pix = stimuli.parsed_S.sinusoids(stimuli.index).spatial_period;
                direction = stimuli.parsed_S.spec.orientation;
                obj.phase_velocity = 360 / stimuli.parsed_S.sinusoids(stimuli.index).temporal_period;
                obj.n_frames = stimuli.parsed_S.spec.frames;
            else
                user_fields = {'rgb', 'phase0', 'temporal_period', ...
                    'spatial_period', 'direction', 'frames'};
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
                obj.color = stimuli.rgb';
                obj.phase_t0 = stimuli.phase0;
                obj.grating_sf_pix = stimuli.spatial_period;
                direction = stimuli.direction;
                obj.phase_velocity = 360/stimuli.temporal_period;
                obj.n_frames = stimuli.frames;
                
            end
            % agjust phase velocity
            if abs(direction-180)>=180
                direction = direction - sign(direction)*360;
            end
            % Convention 0 deg is 3 oclock
            if  (direction >= 0 && direction < 45) || (direction >= 315 && direction < 360) || (direction >= 135 && direction < 225)
                obj.moving_params = [1/cos(stimuli.direction/180*pi), 0, 1, 1];
            elseif (direction >= 45 && direction < 135) || (direction >= 225 && direction < 360)
                obj.moving_params = [0, 1/sin(stimuli.direction/180*pi), 1, 1];
                
            else
                fprintf('\t RSM ERROR: direction out of bounds \n');
                return
            end
            if  (direction >= 0 && direction < 90) || (direction >= 180 && direction < 270)
                polarity_sign = 1;
            elseif (direction >= 90 && direction < 180) || (direction >= 270 && direction < 360)
                polarity_sign = -1;
            end
            obj.phase_velocity = polarity_sign * obj.phase_velocity;
            
            % adjust colors
            obj.color = Color_Test( obj.color );
            obj.backgrndcolor = stimuli.back_rgb';
            obj.backgrndcolor = Color_Test( obj.backgrndcolor );
            
            % some params...
            obj.grating_sf_dva = Convert_SF2DVA( obj.grating_sf_pix, exp_obj );
            obj.grating_angle = direction;% in counterphase grating, it is direction - 90!
            
            % size
            obj.physical_width = exp_obj.monitor.physical_width;
            obj.physical_height = exp_obj.monitor.physical_height;
            
            % interval
            obj.interval = stimuli.interval;
            
            % subtype
            obj.subtype = stimuli.subtype;
            
            % key, trigger, repeats
            obj.wait_trigger = stimuli.wait_trigger;
            obj.wait_key = stimuli.wait_key;
            obj.n_for_each_stim = stimuli.n_for_each_stim;
            obj.n_repeats = stimuli.n_repeats;
            
            %%%%%  Simply initialized  %%%%%
            
            obj.run_date_time = [];
            obj.run_time_total = [];
            obj.stim_update_freq = []; % By setting this to empty we remove artificial delay in main execution while loop
            obj.main_trigger = 0;
            obj.tmain0 = [];
            obj.trep0 = [];
            obj.frames_shown = 0;
            
        end		% constructor
        
		

        function Run_PhaseLoop_Rep( obj )
            
            not_done = 1;
            delta_t = 0;
            local_t0 = mglGetSecs;
            te_last = 0;
            phi = obj.phase_t0;
            
                        
            texWidth = 2 * obj.grating_sf_dva + obj.physical_width + obj.physical_height;
            numCycles = ceil(obj.grating_sf_dva*texWidth/2)*2;
            texWidth = numCycles/obj.grating_sf_dva;
            texHeight = texWidth;
 
            % convert to pixels
            texWidthPixels = round(mglGetParam('xDeviceToPixels')*texWidth);
            texHeightPixels = round(mglGetParam('yDeviceToPixels')*texHeight);
            
            direction = obj.grating_angle;

            switch obj.subtype
                case 'square'
                    grating = 255*(sign(sin((0:numCycles*2*pi/(texWidthPixels-1):numCycles*2*pi) + obj.phase_t0))+1)/2;
                case 'sine'
                    grating = 255*(sin((0:numCycles*2*pi/(texWidthPixels-1):numCycles*2*pi) + obj.phase_t0)+1)/2;
                otherwise
                    fprintf('\t RSM ERROR: Invalid stimulus subtype. Please specify "sine" or "square" and try again. \n');
                    return
            end
            colored_grating = cat(3, ( (grating .* obj.color(1)) + round(255 .* obj.backgrndcolor(1)) ), ( (grating .* obj.color(2)) + round(255 .* obj.backgrndcolor(2)) ), ( (grating .* obj.color(3)) + round(255 .* obj.backgrndcolor(3)) ));
            tex1dsquare = mglCreateTexture(colored_grating);

            
            while( not_done )
                
                % update phase
                phi = phi + (obj.phase_velocity * delta_t);
                
                % test for pulse
                if ( phi >= (obj.phase_t0 + 360) )
                    phi = phi - 360;
                    Pulse_DigOut_Channel;
                end
                
                % Draw the grating
                mglClearScreen( obj.backgrndcolor ); 
                
                % The phase switch in the phase (phi) is because
                % mglMakeGrating adds the phase offset; whereas we want a
                % subtracted phase offset.
                
                pos = phi/360/obj.grating_sf_dva;
                mglBltTexture( tex1dsquare, [pos pos nan texHeight].*obj.moving_params, 0, 0, direction ); 
    
                mglFlush();
                obj.frames_shown = obj.frames_shown + 1;
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
                mglFlush();
                mglWaitSecs(obj.interval)
            end

        end     % run single repetition of bar across screen
	
        
	end			% methods block
    
    
end             % Moving Grating Class