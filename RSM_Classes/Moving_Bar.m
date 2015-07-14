classdef	Moving_Bar < handle
    % Moving_Bar: Presents simple hard-edged rectangle as a moving bar.
%
%        $Id: Moving_Bar VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
% NB: when using mglQuad my convention is to start in upper left as 0, 0
% then always work in clockwise manner for sub-quads
% within each quad or sub-quad vertices are also described in a clockwise
% manner.

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
        
        color
        backgrndcolor
       
        bar_width
        bar_height
        
        x_start
        x_end
        y_start
        y_end
   
        x_delta
        y_delta
        frames

        wait_trigger
        wait_key
        
        n_for_each_stim
        
        n_repeats
        frames_shown
        
        direction
        interval
	
	end			% properties block
	
	
	
	methods
		
        % Constructor method
        function[obj] = Moving_Bar( stimuli )
            global display
            
            %%%%%  check if all user-defined fields exist  %%%%%
            
            user_fields = {'bar_width','rgb', 'interval','direction','delta',...
                'wait_trigger', 'wait_key', 'n_for_each_stim'};
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
            
            obj.bar_width = stimuli.bar_width;
            
            obj.color = stimuli.rgb';
            obj.color = Color_Test( obj.color );
            
            obj.interval = stimuli.interval;
            
            obj.n_for_each_stim = stimuli.n_for_each_stim;

            
            obj.direction = stimuli.direction;
            L = 3000; % Length of the bar, the idea of making this number large is to ensure that it covers the whole display.
            if stimuli.direction >= 0 && stimuli.direction < 90
                r0 = [0, display.height]; % coordinates of one display corner.
                obj.x_start = [0; 0; -stimuli.bar_width; -stimuli.bar_width]; % bar was first set to be either vertical or horizontal (base on moving direction)
                obj.y_start = [L; -L; -L; L];
                [obj.x_start, obj.y_start] = rotateData(obj.x_start, obj.y_start, r0(1), r0(2), stimuli.direction*pi/180); % then the bar will be rotated around a corner of display by a certain degree (base on moving direction)
            elseif stimuli.direction >= 90 && stimuli.direction < 180
                r0 = [display.width, display.height];
                obj.x_start = [-L; -L; L; L];
                obj.y_start = [display.height+stimuli.bar_width; display.height; display.height; display.height+stimuli.bar_width];
                [obj.x_start, obj.y_start] = rotateData(obj.x_start, obj.y_start, r0(1), r0(2), (stimuli.direction-90)*pi/180);
            elseif stimuli.direction >= 180 && stimuli.direction < 270
                r0 = [display.width, 0];
                obj.x_start = [display.width+stimuli.bar_width; display.width+stimuli.bar_width; display.width; display.width];
                obj.y_start = [L; -L; -L; L];
                [obj.x_start, obj.y_start] = rotateData(obj.x_start, obj.y_start, r0(1), r0(2), (stimuli.direction-180)*pi/180);
            elseif stimuli.direction >= 270 && stimuli.direction < 360
                r0 = [0, 0];
                obj.x_start = [-L; -L; L; L];
                obj.y_start = [0; -stimuli.bar_width; -stimuli.bar_width; 0];
                [obj.x_start, obj.y_start] = rotateData(obj.x_start, obj.y_start, r0(1), r0(2), (stimuli.direction-270)*pi/180);
            else
                fprintf('\t RSM ERROR: invalid direction. Please define valid direction value and try again. \n');
                return
            end
            obj.x_start = obj.x_start';
            obj.y_start = obj.y_start';
            
            % make the bar moving either vertically or horizontally
            % based on which distance is shorter
            x_dis = (abs(tan(stimuli.direction*pi/180)*display.height)+display.width);
            y_dis = (abs(display.width/tan(stimuli.direction*pi/180))+display.height);
            [dis, I] = min([x_dis, y_dis]);
            
            switch I
                case 1
                    obj.x_delta = stimuli.delta/cos(stimuli.direction*pi/180);
                    obj.y_delta = 0;
                    obj.frames = (sqrt(display.width^2+display.height^2) + stimuli.bar_width)/stimuli.delta + stimuli.interval;
                case 2
                    obj.y_delta = stimuli.delta/sin(stimuli.direction*pi/180);
                    obj.x_delta = 0;
                    obj.frames = (sqrt(display.width^2+display.height^2) + stimuli.bar_width)/stimuli.delta + stimuli.interval;
            end

            % Note: color is rgb vector in [0-1] format, vertical vect for mglQuad  
            obj.backgrndcolor = stimuli.back_rgb';
            obj.backgrndcolor = Color_Test( obj.backgrndcolor );
            
            obj.wait_trigger = stimuli.wait_trigger;                            
            obj.wait_key = stimuli.wait_key;
 
          
            % The following setup values are not under direct user control
            % via the setup script

            obj.stim_name = 'Moving_Bar';

            obj.run_date_time = [];
            obj.run_time_total = [];
            
            obj.run_duration = [];      % By setting this to empty we indicate we switch to end condition being a fixed number of reps 
            obj.stim_update_freq = []; % By setting this to empty we remove artificial delay in main execution while loop
            
            obj.main_trigger = 0;        
            obj.tmain0 = [];
            
            obj.rep_trigger = 0;        
            obj.trep0 = [];
            
            obj.run_script = 'Run_Bar_Rep( exp_obj.stimulus );';
            
            obj.n_repeats = stimuli.n_repeats;
            obj.frames_shown = 0;

		end		% constructor 
		

        
        function Run_Bar_Rep( obj )
            
            x_new = obj.x_start;
            y_new = obj.y_start;
            
            % Draw the quad
            mglClearScreen( obj.backgrndcolor ); 

            new_color = obj.color + obj.backgrndcolor;
            [ new_color ] = Color_Test( new_color );

            mglQuad(x_new, y_new, new_color, 0);

            mglFlush();

            % OK: Time to tell DAQ we are starting
            Pulse_DigOut_Channel;
   
            for frame_num = 1:obj.frames,
                
                % Set up x
                % Then case is Left 2 right motion

                % update x_vertices
                x_new = x_new + obj.x_delta;
                y_new = y_new - obj.y_delta;
                
                x_vertices = x_new;
                
                y_vertices = y_new;
                

                % Draw the quad
                mglClearScreen( obj.backgrndcolor ); 
                
                new_color = obj.color + obj.backgrndcolor;
                [ new_color ] = Color_Test( new_color );
                        
                mglQuad(x_vertices, y_vertices, new_color, 0);
                                                                
                mglFlush();
            
    
            end % loop through frames
  
        end     % Run bar rep
		
        
	end			% methods block
    
    
end             % Moving Bar class