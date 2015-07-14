classdef	PulseCombo < handle

    properties
        
        % Required props for all stim classes
        color
        colors
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
        frames_for_flash
        frames_for_back
        
        run_script
        
        wait_key
        wait_trigger
        
        n_repeats
%         repeat_num
        
        
%         num_reps    % this controls how many reps we want to run
        
%         reps_run    % this records how many bar passes have already occured
        
            
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

        w
        h
        frames_shown

        
    end			% properties block
    
    
    methods
        
        % Constructor method
        function[obj] = PulseCombo( stimuli, exp_obj )
            
          switch stimuli.control_flag
              
              case 1
                  %-------------------------------------------------------------------------------------------------------------------
                  % Then we use the stimuli structure constructor mode for pulsing
                  % cone isolating stim
                  
                  
                  %%%%%  check if all user-defined fields exist  %%%%%
                  
                  user_fields = {'n_repeats','frames', 'map_file_name'};
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
                  if ~isfield(stimuli,'lut_file_name') && ~isfield(stimuli,'parsed_S')
                      fprintf(['\t RSM ERROR: specify either S file name or lut file name. \n']);
                      return
                  end
                  
                  
                  
                  %%%%%  These are copied from stimuli and exp_obj fields  %%%%%
                  
                  obj.backgrndcolor = stimuli.back_rgb';
                  obj.backgrndcolor = Color_Test( obj.backgrndcolor );
                  
                  % following fields might be specified in S file; then
                  % take S file values (for now)
                  
                  
                  if isfield(stimuli,'parsed_S') % it was an S-file
                      obj.frames_per_halfcycle = stimuli.parsed_S.spec.frames;
                      
                      % those are overriden by obj.x_cen_offset and
                      % obj.y_cen_offset below. adjust later if needed.
                      obj.x_start = stimuli.parsed_S.spec.x_start;
                      obj.x_end = stimuli.parsed_S.spec.x_end;
                      obj.y_start = stimuli.parsed_S.spec.y_start;
                      obj.y_end = stimuli.parsed_S.spec.y_end;
                      
                      lut = stimuli.parsed_S.rgbs{stimuli.index};
                      lut = lut + repmat(obj.backgrndcolor',size(lut,1),1); % background is added - from old style?
                      
                      % two more parameter: map name and path; and delay_frames are present
                      % in S-file. Adjust later.
                      
                  else
                      obj.frames_per_halfcycle = stimuli.frames;
                      
                      obj.x_start = [];
                      obj.x_end = [];
                      obj.y_start = [];
                      obj.y_end = [];
                      
                      load( stimuli.lut_file_name, 'lut' );
                  end
                  
                  lut_vect = reshape(lut', numel(lut),1)';
                  lut_vect = uint8( round( 255 * lut_vect ));
                  
                  obj.span_width = exp_obj.monitor.width;
                  obj.span_height = exp_obj.monitor.height;
 
                  obj.cen_width = exp_obj.monitor.cen_width;
                  obj.cen_height = exp_obj.monitor.cen_height;
          
                  obj.wait_trigger = stimuli.wait_trigger;
                  obj.wait_key = stimuli.wait_key;
                  
                  obj.n_repeats = stimuli.n_repeats;


                  %%%%% These are pre-calculated/derived once at construction %%%%%
                    
                  map = load( fullfile(exp_obj.map_path, stimuli.map_file_name) );
                  map = uint8( map );
                  map = map';  % NB: The transposing of the matrix was estabilished by comparison to the older style code that read in the
                  % map to build up the image mat within matlab.
 
                  backrgb = uint8( round( 255 * obj.backgrndcolor));
                  
                  image_mat = Make_Map(size(map,1), size(map,2), lut_vect, map, backrgb);
                  
                  %obj.frametex = mglCreateTexture( image_mat, [], 0, {'GL_TEXTURE_MAG_FILTER','GL_NEAREST'} );
                  obj.frametex = mglCreateTexture( image_mat );
                  
                  
                  %%%%%  These are simply initialized  %%%%%
                 
                  obj.stim_name = 'Pulse';
                  obj.run_script = 'Run_Pulse_Rep( exp_obj.stimulus );';
                  
                  obj.x_cen_offset = 0;
                  obj.y_cen_offset = 0;
                  
                  obj.run_date_time = [];
                  obj.run_time_total = [];
                  
                  obj.main_trigger = 0;
                  obj.tmain0 = [];
                  obj.rep_trigger = 0;
                  obj.trep0 = [];
                  obj.run_duration = [];

                  
                  obj.frames_shown = 0;
                  
              case 3
                  %-------------------------------------------------------------------------------------------------------------------
                  % full-field pulses: any sequence
                  
                                    
                  %%%%%  check if all user-defined fields exist  %%%%%
                  
                  user_fields = {'rgb', 'back_rgb','n_repeats', 'frames', 'x_start', 'x_end', 'y_start', 'y_end'};
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
                  
                  for i=1:length(stimuli.rgb)
                      obj.colors{i} = stimuli.rgb{i}';
                      obj.colors{i} = Color_Test( obj.colors{i} );
                  end
                  
                  obj.backgrndcolor = stimuli.back_rgb';
                  obj.backgrndcolor = Color_Test( obj.backgrndcolor );
                  
                  obj.x_start = min(stimuli.x_start, stimuli.x_end);
                  obj.x_end = max(stimuli.x_start, stimuli.x_end);       

                  obj.y_start = min(stimuli.y_start, stimuli.y_end);
                  obj.y_end = max(stimuli.y_start, stimuli.y_end); 
                  
                  obj.n_repeats = stimuli.n_repeats;

                  obj.frames_for_flash = stimuli.frames;
                  obj.frames_for_back = stimuli.back_frames;
                  
                  obj.wait_trigger = stimuli.wait_trigger;
                  obj.wait_key = stimuli.wait_key;
                  
                  obj.w = exp_obj.monitor.width;
                  obj.h = exp_obj.monitor.height;
                  
                  %%%%%  These are simply initialized  %%%%%
                  
                  obj.stim_name =  'Pulse';
                  obj.run_script = 'Run_Any_Pulses( exp_obj.stimulus );';
                  
                  obj.run_date_time = [];
                  obj.run_time_total = [];
                  
                  obj.main_trigger = 0;
                  obj.tmain0 = [];
                  obj.rep_trigger = 0;
                  obj.trep0 = [];

                  obj.run_duration = [];
                  obj.frames_shown = 0;

                  
          end  % % which stimulus type (switch case)
          
        end     % constructor methods
        
        
        function Run_Pulse_Rep( obj )
            
            
            % blit the texture 
            mglBltTexture( obj.frametex, [(obj.cen_width + obj.x_cen_offset), (obj.cen_height + obj.y_cen_offset), obj.span_width, obj.span_height] );   % should be centered
                
            mglFlush();
            Pulse_DigOut_Channel;
            
            RSM_Pause(obj.frames_per_halfcycle); 
             
            % clear the screen
            mglClearScreen( obj.backgrndcolor );   
            
            mglFlush();
            Pulse_DigOut_Channel;
            
            RSM_Pause(obj.frames_per_halfcycle);
  
        end     % run single flash on or off 
	
  
        function Run_Any_Pulses( obj )
            
            x_vertices = [obj.x_start; obj.x_end; obj.x_end; obj.x_start];
            y_vertices = [obj.y_end; obj.y_end; obj.y_start; obj.y_start];
            
            
            for i=1:length(obj.colors)
                
                Pulse_DigOut_Channel;
                mglQuad(x_vertices, y_vertices, obj.backgrndcolor, 0);
                
                mglFlush();
                % Now make sure the second buffer is loaded with the
                % background
                mglQuad(x_vertices, y_vertices, obj.backgrndcolor, 0);
                mglFlush();
                
                RSM_Pause(obj.frames_for_back-2);
                
                Pulse_DigOut_Channel;
                mglQuad(x_vertices, y_vertices, obj.colors{i}, 0);
                
                mglFlush();
                % Now make sure the second buffer is loaded with the
                % foreground
                mglQuad(x_vertices, y_vertices, obj.colors{i}, 0);
                mglFlush();
                
                RSM_Pause(obj.frames_for_flash-2);
                
            end
            
            % to end with background as well
            Pulse_DigOut_Channel;
            mglQuad(x_vertices, y_vertices, obj.backgrndcolor, 0);
            mglFlush();
            RSM_Pause(obj.frames_for_flash-2);
            
        end
		
	
        
    end         % methods block
    
    
end             % PaintByNumbers class def.