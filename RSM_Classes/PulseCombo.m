classdef	PulseCombo < handle

    properties
        
                % Required props for all stim classes 
        color
        color_white
        color_black
        backgrndcolor

        main_trigger
        rep_trigger
        
        run_date_time
        run_time_total
        
        stim_name

        tmain0
        trep0

        run_duration
        stim_update_freq  
        frames_per_halfcycle 
        
        run_script
        
        wait_key
        wait_trigger
        
        n_repeats
        repeat_num
        
        
        num_reps    % this controls how many reps we want to run
        
        reps_run    % this records how many bar passes have already occured
        
            
        frametex
        
        x_cen_offset
        y_cen_offset
        
        span_width
        span_height
        
        cen_width
        cen_height
 
        map_filename
        lut_filename
        
        x_start
        x_end
        
        y_start
        y_end
        
        bar_width
        bar_height

        w
        h

        
    end			% properties block
    
    
    methods
        
        % Constructor method
        function[obj] = PulseCombo( stimuli, exp_obj )
            
          if ( stimuli.control_flag == 1 )
          %-------------------------------------------------------------------------------------------------------------------    
          % Then we use the stimuli structure constructor mode for pulsing
          % cone isolating stim
            
            if (isfield(stimuli,'x_cen_offset'))
                if (abs(stimuli.x_cen_offset) > (exp_obj.monitor.width / 2))
                    fprintf('\t RSM ERROR: X-position offset exceeds 1/2 display width. Please redfine and try again. \n');
                    return
                else
                    obj.x_cen_offset = stimuli.x_cen_offset;
                end      
            else
                obj.x_cen_offset = 0;
            end  
    
        
            if (isfield(stimuli,'y_cen_offset'))
                if (abs(stimuli.y_cen_offset) > (exp_obj.monitor.height / 2))
                    fprintf('\t RSM ERROR: Y-position offset exceeds 1/2 display height. Please redfine and try again. \n');
                    return
                else
                    obj.y_cen_offset = stimuli.y_cen_offset;
                end     
            else
                obj.y_cen_offset = 0;
            end  
        
            
            if (isfield(stimuli,'num_reps'))
                if (isfield(stimuli,'frames'))
                
                    obj.num_reps = stimuli.num_reps;
                    obj.frames_per_halfcycle = stimuli.frames;
                   
                else
                   fprintf('\t RSM ERROR: stimulus update frequency ("interval") not recognized. Please define interval value and try again. \n');
                   return
                end 
            else
                fprintf('\t RSM ERROR: num_rep not recognized. Please define num_reps value and try again. \n');
                return
            end  

                      
            if (isfield(stimuli,'map_file_name'))
                if (isfield(stimuli,'lut_file_name'))
                
                        map = load( fullfile(exp_obj.map_path, stimuli.map_file_name) );
                        load( stimuli.lut_file_name, 'lut' );

                else
                   fprintf('\t RSM ERROR: lut file name not recognized. Please define lut file name and try again. \n');
                   return
                end 
            else
                fprintf('\t RSM ERROR: map file name not recognized. Please define map file name and try again. \n');
                return
            end  

          
            %if (isfield(stimuli,'n_repeats'))
            %    obj.n_repeats = stimuli.n_repeats;    
            %else
            %    fprintf('\t RSM ERROR: n-repeats not recognized. Please define number of repeats value and try again. \n');
            %    return
            %end
            obj.n_repeats = 1;
            
            
            obj.span_width = exp_obj.monitor.width;
            obj.span_height = exp_obj.monitor.height;
            
            
            obj.cen_width = exp_obj.monitor.cen_width;
            obj.cen_height = exp_obj.monitor.cen_height;
            
          
            obj.backgrndcolor = [stimuli.back_rgb(1); stimuli.back_rgb(2); stimuli.back_rgb(3)];
            obj.backgrndcolor = Color_Test( obj.backgrndcolor );
          
            obj.wait_trigger = stimuli.wait_trigger;                            
            obj.wait_key = stimuli.wait_key;

            
            obj.stim_name = 'Pulse';

            obj.run_date_time = [];
            obj.run_time_total = [];
                
            obj.main_trigger = 0;       
            obj.tmain0 = [];
            
            obj.rep_trigger = 0;        
            obj.trep0 = [];
            
            obj.run_script = 'Run_Pulse_Rep( exp_obj.stimulus );';
            
            obj.reps_run = 0;
            
            obj.repeat_num = 0;
 
            
            % Convert LUT to linear vector form
            num_lut_levels = size(lut, 1);
            
            lv_i = 0;

            for i = 1:num_lut_levels,
   
                for j = 1:3,
        
                    lv_i = lv_i + 1;
                    lut_vect(lv_i) = lut(i,j);
    
                end
            end
            
            
            % Condition inputs to Make_Map
            map = uint8( map );

            lut_vect = uint8( round( 255 * lut_vect ));
            
            backrgb = uint8( round( 255 * obj.backgrndcolor));
    
            % width, height, lut in mxarray, map_in_mxarray, backrgb vect (3 element) 
            map = map';  % NB: The transposing of the matrix was estabilished by comparison to the older style code that read in the 
                        % map to build up the image mat within matlab.
                     
            image_mat = Make_Map(size(map,1), size(map,2), lut_vect, map, backrgb);
            
            %obj.frametex = mglCreateTexture( image_mat, [], 0, {'GL_TEXTURE_MAG_FILTER','GL_NEAREST'} );
            
            obj.frametex = mglCreateTexture( image_mat );
            
            obj.x_start = [];
            obj.x_end = [];
        
            obj.y_start = [];
            obj.y_end = [];
            
            obj.bar_width = [];
            obj.bar_height = [];
            
            obj.run_duration = [];


            
          elseif (  stimuli.control_flag == 2 )
          %-------------------------------------------------------------------------------------------------------------------    
          % Then we use the S_file constructor mode
            % Contents of parsed_S for Pulse stim
            % parsed = 
            %       spec: [1x1 struct]
            %       pulses: [1x3650 struct]
            %       numcones: 4
            %       rgbs: {1x3650 cell}
            %
            %   parsed.spec
            %           type: 'PULSE'
            %            frames: 15
            %           delay_frames: 0
            %           x_start: 100
            %           x_end: 700
            %           y_start: 0
            %           y_end: 600
            %           index_map: ':2012-09-13-2:1234d01:map-0000.txt'
            %
            %   parsed.pulses            
            %           1x3650 struct array with fields:
            %               rgbs
            %   parsed.pulses(1)
            %
            %               rgbs: {{1x3 cell}  {1x3 cell}  {1x3 cell}  {1x3 cell}}
            %
            %   parsed.pulses(1).rgbs{1}
            %
            %                [0.2400]    [0.2400]    [0.2400]
            %
            %   parsed.rgbs{1}
            %
            %        0.2400    0.2400    0.2400
            %             0         0         0
            %             0         0         0
            %       -0.4800   -0.4800   -0.4800
            %
            % each rgbs entry defines a lut appropriate for a single pulse
            % num cones matches the number of rows in the lut matrix for a pulse
              
            obj.x_cen_offset = 0;
        
            obj.y_cen_offset = 0;
            
            obj.num_reps = 1; 
           
            %period = stimuli.parsed_S.spec.frames / exp_obj.monitor.screen_refresh_freq;
            %obj.stim_update_freq = 1/period;
            obj.frames_per_halfcycle = stimuli.parsed_S.spec.frames;
            
            obj.map_filename = cat(2, stimuli.map_file_path, stimuli.map_file_name);
            
            obj.n_repeats = 1; 

            obj.span_width = exp_obj.monitor.width;
            obj.span_height = exp_obj.monitor.height;
            
            
            obj.cen_width = exp_obj.monitor.cen_width;
            obj.cen_height = exp_obj.monitor.cen_height;
            
            % Forced to use default background since Sfile doesn't carry
            % necessary info.
            obj.backgrndcolor = [exp_obj.monitor.backgrndcolor(1); exp_obj.monitor.backgrndcolor(2); exp_obj.monitor.backgrndcolor(3)];
            obj.backgrndcolor = Color_Test( obj.backgrndcolor );
          
            obj.wait_trigger = 0;                            
            obj.wait_key = 0;

            
            obj.stim_name = 'Pulse';

            obj.run_date_time = [];
            obj.run_time_total = [];
            
            obj.main_trigger = 0;       
            obj.tmain0 = [];
            
            obj.rep_trigger = 0;        
            obj.trep0 = [];
            
            obj.run_script = 'Run_Pulse_Rep( exp_obj.stimulus );';
            
            obj.reps_run = 0;
            
            obj.repeat_num = 0;
            
            lut = stimuli.parsed_S.rgbs{stimuli.index};
            
            % Convert LUT to linear vector form
            num_lut_levels = size(lut, 1);
            
            lv_i = 0;

            for i = 1:num_lut_levels,
   
                for j = 1:3,
        
                    lv_i = lv_i + 1;
                    lut_vect(lv_i) = (lut(i,j) + obj.backgrndcolor(j));
                    lut_vect(lv_i) = Color_Test( lut_vect(lv_i) );
                    
                end
            end
            
            lut_vect = uint8( round( 255 * lut_vect ));
            
            backrgb = uint8( round( 255 * obj.backgrndcolor));
    
            % width, height, lut in mxarray, map_in_mxarray, backrgb vect (3 element) 
                       
            image_mat = Make_Map(size(stimuli.map,1), size(stimuli.map,2), lut_vect, stimuli.map, backrgb);
            
            obj.frametex = mglCreateTexture( image_mat );
            
            obj.x_start = [];
            obj.x_end = [];
        
            obj.y_start = [];
            obj.y_end = [];
            
            obj.run_duration = [];


          elseif (  stimuli.control_flag == 3 )
          %-------------------------------------------------------------------------------------------------------------------    
           
            if (isfield(stimuli,'rgb'))
                obj.color = [stimuli.rgb(1); stimuli.rgb(2); stimuli.rgb(3)];   
                obj.color = Color_Test( obj.color );
            else
                fprintf('\t RSM ERROR: rgb not recognized. Please define rgb value and try again. \n');
                return
            end
        
            if (isfield(stimuli,'back_rgb'))
                obj.backgrndcolor = [stimuli.back_rgb(1); stimuli.back_rgb(2); stimuli.back_rgb(3)];     
                obj.backgrndcolor = Color_Test( obj.backgrndcolor );
            else
                fprintf('\t RSM ERROR: background rgb not recognized. Please define backgrndcolor value and try again. \n');
                return
            end
        
        
            if (isfield(stimuli,'num_reps'))
                if (isfield(stimuli,'frames'))
                
                    obj.num_reps = stimuli.num_reps;
                    obj.frames_per_halfcycle = stimuli.frames;
                   
                else
                   fprintf('\t RSM ERROR: Frames per half-cycle not recognized. Please define value and try again. \n');
                   return
                end 
            else
                fprintf('\t RSM ERROR: num_rep not recognized. Please define num_reps value and try again. \n');
                return
            end  

            
		    obj.wait_trigger = stimuli.wait_trigger;
            obj.wait_key = stimuli.wait_key;
           
            % The following setup values are not under direct user control
            % via the setup script
            obj.stim_name =  'Pulse'; % formerly 'Flashing_Color';

            obj.run_date_time = [];
            obj.run_time_total = [];
            
            obj.main_trigger = 0;       
            obj.tmain0 = [];
            
            obj.rep_trigger = 0;
            obj.trep0 = [];
            
            obj.reps_run = 0;
            
            obj.run_script = 'Run_Flashing_Color( exp_obj.stimulus );';
            
            obj.w = exp_obj.monitor.width;
            obj.h = exp_obj.monitor.height;
            obj.repeat_num = 0;

            obj.run_duration = [];
            
            
        elseif (  stimuli.control_flag == 5 )
          %-------------------------------------------------------------------------------------------------------------------    
           
            if (isfield(stimuli,'rgb_black'))
                obj.color_black = [stimuli.rgb_black(1); stimuli.rgb_black(2); stimuli.rgb_black(3)];   
                obj.color_black = Color_Test( obj.color_black );
            else
                fprintf('\t RSM ERROR: rgb black not recognized. Please define rgb black value and try again. \n');
                return
            end
            
            if (isfield(stimuli,'rgb_white'))
                obj.color_white = [stimuli.rgb_white(1); stimuli.rgb_white(2); stimuli.rgb_white(3)];   
                obj.color_white = Color_Test( obj.color_white );
            else
                fprintf('\t RSM ERROR: rgb white not recognized. Please define rgb white value and try again. \n');
                return
            end
        
            if (isfield(stimuli,'back_rgb'))
                obj.backgrndcolor = [stimuli.back_rgb(1); stimuli.back_rgb(2); stimuli.back_rgb(3)];     
                obj.backgrndcolor = Color_Test( obj.backgrndcolor );
            else
                fprintf('\t RSM ERROR: background rgb not recognized. Please define backgrndcolor value and try again. \n');
                return
            end
        
        
            if (isfield(stimuli,'num_reps'))
                if (isfield(stimuli,'frames'))
                
                    obj.num_reps = stimuli.num_reps;
                    obj.frames_per_halfcycle = stimuli.frames;
                   
                else
                   fprintf('\t RSM ERROR: Frames per half-cycle not recognized. Please define value and try again. \n');
                   return
                end 
            else
                fprintf('\t RSM ERROR: num_rep not recognized. Please define num_reps value and try again. \n');
                return
            end  

            
		    obj.wait_trigger = stimuli.wait_trigger;
            obj.wait_key = stimuli.wait_key;
           
            % The following setup values are not under direct user control
            % via the setup script
            obj.stim_name =  'Pulse'; % formerly 'Flashing_Color';

            obj.run_date_time = [];
            obj.run_time_total = [];
            
            obj.main_trigger = 0;       
            obj.tmain0 = [];
            
            obj.rep_trigger = 0;
            obj.trep0 = [];
            
            obj.reps_run = 0;
            
            obj.run_script = 'Run_Pulses( exp_obj.stimulus );';
            
            obj.w = exp_obj.monitor.width;
            obj.h = exp_obj.monitor.height;
            obj.repeat_num = 0;

            obj.run_duration = [];
    

            
          else
          %-------------------------------------------------------------------------------------------------------------------  
          % This is the case to handle simple solid color
            if (isfield(stimuli,'x_start'))
                if (isfield(stimuli,'x_end'))
                
                    % flip around if needed for proper ordering
                    if (stimuli.x_start > stimuli.x_end)
                        temp = stimuli.x_start;
                        stimuli.x_end = temp;
                        stimuli.x_start = stimuli.x_end;
                        clear temp
                    end
            
                    obj.x_start = stimuli.x_start;
                    obj.x_end = stimuli.x_end;
 
                
                    obj.bar_width = stimuli.x_end - stimuli.x_start;   
                    
                else
                    fprintf('\t RSM ERROR: x-end not recognized. Please define x_end value and try again. \n');
                    return
                end  
            else
                fprintf('\t RSM ERROR: x-start not recognized. Please define x_start value and try again. \n');
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
            
                    obj.y_start = stimuli.y_start;
                    obj.y_end = stimuli.y_end;
                
                    obj.bar_height = stimuli.y_end - stimuli.y_start;
            
                else
                    fprintf('\t RSM ERROR: y-end not recognized. Please define y_end value and try again. \n');
                    return
                end  
            else
                fprintf('\t RSM ERROR: y-start recognized. Please define y_start value and try again. \n');
                return
            end  

          
            if (isfield(stimuli,'rgb'))
                obj.color = [stimuli.rgb(1); stimuli.rgb(2); stimuli.rgb(3)];   
                obj.color = Color_Test( obj.color );
            else
                fprintf('\t RSM ERROR: rgb not recognized. Please define rgb value and try again. \n');
                return
            end
        
            if (isfield(stimuli,'back_rgb'))
                obj.backgrndcolor = [stimuli.back_rgb(1); stimuli.back_rgb(2); stimuli.back_rgb(3)]; 
                obj.backgrndcolor = Color_Test( obj.backgrndcolor );
            else
                fprintf('\t RSM ERROR: background rgb not recognized. Please define backgrndcolor value and try again. \n');
                return
            end
        
            obj.stim_update_freq = [];
                       
            obj.num_reps = 1;
            obj.repeat_num = 0;
 
                        
		    obj.wait_trigger = stimuli.wait_trigger;
            obj.wait_key = stimuli.wait_key;
           
            % The following setup values are not under direct user control
            % via the setup script
            obj.stim_name = 'Pulse';

            obj.run_date_time = [];
            obj.run_time_total = [];
            
            obj.main_trigger = 0;       
            obj.tmain0 = [];
            
            obj.rep_trigger = 0;
            obj.trep0 = [];
            
            obj.reps_run = 0;
            obj.n_repeats = 1; 
            
            obj.run_script = 'Run_SimplePulse_Rep( exp_obj.stimulus );';
            
            obj.run_duration = [];
   
          end  % % stimuli vs Sfile if-then
            
        end     % constructor methods   
        
        
        function Run_Pulse_Rep( obj )
            
            
            % blit the texture 
            mglBltTexture( obj.frametex, [(obj.cen_width + obj.x_cen_offset), (obj.cen_height + obj.y_cen_offset), obj.span_width, obj.span_height] );   % should be centered
                
            mglFlush();
            Pulse_DigOut_Channel;
            
            RSM_pulsepause_nframes(obj, 0); 
             
            % clear the screen
            mglClearScreen( obj.backgrndcolor );   
            
            mglFlush();
            Pulse_DigOut_Channel;
            
            RSM_pulsepause_nframes(obj, 1);
  
        end     % run single flash on or off 
	

        
        function Run_SimplePulse_Rep( obj )
                
            x_vertices = [obj.x_start; obj.x_end; obj.x_end; obj.x_start];
                
            y_vertices = [obj.y_end; obj.y_end; obj.y_start; obj.y_start];
                
            % OK: Time to tell DAQ we are starting
            Pulse_DigOut_Channel; 
            
            % Draw the quad
            mglClearScreen( obj.backgrndcolor ); 
                        
            mglQuad(x_vertices, y_vertices, (obj.color + obj.backgrndcolor), 0);
                                                                
            mglFlush();
            
            fprintf('\n');
            disp('Hit any key to clear screen and return to session stim selection menu: ');
            pause
            fprintf('\n');


        end     % simple pulse rep
        
        
        function[ ] = RSM_pulsepause_nframes(obj , backgrnd_flag)

            if (~backgrnd_flag)
    
                for i = 1:obj.frames_per_halfcycle,
        
                    % blit the texture 
                    mglBltTexture( obj.frametex, [(obj.cen_width + obj.x_cen_offset), (obj.cen_height + obj.y_cen_offset), obj.span_width, obj.span_height] );   % should be centered
                
                    mglFlush();
                end % loop through number of frames

            else 
    
                for i = 1:obj.frames_per_halfcycle,

                    % clear the screen
                    mglClearScreen( obj.backgrndcolor );   
            
                    mglFlush();
            
                end % loop through number of frames

            end % background if-then
            
        end     % end pulsepause



        function Run_Flashing_Color( obj )
            
                        
            x_vertices = [0; obj.w; obj.w; 0];
            y_vertices = [0; 0; obj.h; obj.h];
        
            % First phase: turn on colored flash.
            mglQuad(x_vertices, y_vertices, obj.color, 0); 
                
            mglFlush();
            Pulse_DigOut_Channel;
            
            % Now make sure the second buffer is loaded with the
            % fore-ground
            mglQuad(x_vertices, y_vertices, obj.color, 0);  
            mglFlush();
            
            RSM_Pause(obj.frames_per_halfcycle-1); 
 
            
            % Now the second phase of the cycle, return to background
            mglQuad(x_vertices, y_vertices, obj.backgrndcolor, 0); 
            
            mglFlush();
            Pulse_DigOut_Channel;
            
            % Now make sure the second buffer is loaded with the
            % background
            mglQuad(x_vertices, y_vertices, obj.backgrndcolor, 0);  
            mglFlush();

            RSM_Pause(obj.frames_per_halfcycle-1);
  
        end     % run single flash on or off 
        
        function Run_Pulses( obj )
            
                        
            x_vertices = [0; obj.w; obj.w; 0];
            y_vertices = [0; 0; obj.h; obj.h];
            % First phase: turn on background.
            Pulse_DigOut_Channel;
            mglQuad(x_vertices, y_vertices, obj.backgrndcolor, 0); 
                
            mglFlush();
            
            
            % Now make sure the second buffer is loaded with the
            % background
            mglQuad(x_vertices, y_vertices, obj.backgrndcolor, 0);  
            mglFlush();
            
            RSM_Pause(obj.frames_per_halfcycle-2); 
            

 
            
            % Now the second phase of the cycle, turn on white flash
            Pulse_DigOut_Channel;
            mglQuad(x_vertices, y_vertices, obj.color_white, 0); 
            
            mglFlush();
            
            
            % Now make sure the second buffer is loaded with the
            % fore-ground
            mglQuad(x_vertices, y_vertices, obj.color_white, 0);  
            mglFlush();

            RSM_Pause(obj.frames_per_halfcycle-2);
            
            % third phase: return to background.
            Pulse_DigOut_Channel;
            mglQuad(x_vertices, y_vertices, obj.backgrndcolor, 0); 
                
            mglFlush();
            
            
            % Now make sure the second buffer is loaded with the
            % background
            mglQuad(x_vertices, y_vertices, obj.backgrndcolor, 0);  
            mglFlush();
            
            RSM_Pause(obj.frames_per_halfcycle-2);
            
 
            
            % Now the fourth phase of the cycle, go to black
            Pulse_DigOut_Channel;
            mglQuad(x_vertices, y_vertices, obj.color_black, 0); 
            
            mglFlush();
            
            
            % Now make sure the second buffer is loaded with the
            % fore-ground
            mglQuad(x_vertices, y_vertices, obj.color_black, 0);  
            mglFlush();

            RSM_Pause(obj.frames_per_halfcycle-2);
            
        end     % run single flash on or off 
		
	
        
    end         % methods block
    
    
end             % PaintByNumbers class def.