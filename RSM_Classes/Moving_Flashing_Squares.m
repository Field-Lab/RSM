classdef Moving_Flashing_Squares < handle
    
    properties
        stim_name
        
        run_date_time
        run_time_total
        tmain0
        trep0
        
        main_trigger
        rep_trigger
        
        run_script
        
        field_width
        field_height
        stixel_width
        stixel_height
        
        x_start
        x_end
        y_start
        y_end
        
        wait_key
        wait_trigger
        
        repeats
        num_reps
        
        repeat_num
        
        backgrndcolor
        color
        
        sub_region
       
        frames
        
        trial_num
        trial_num_total
        
        run_duration
        reps_run
        
        seq
        
    end       % properties block
    
    methods
        
        function[obj] = Moving_Flashing_Squares( stimuli, exp_obj )
            
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
                    
                    obj.y_start = stimuli.y_start;
                    obj.y_end = stimuli.y_end;
                    
                else
                    fprintf('\t RSM ERROR: y-end not recognized. Please define y_end value and try again. \n');
                    return
                end  
            else
                fprintf('\t RSM ERROR: y-start recognized. Please define y_start value and try again. \n');
                return
            end
            
            if (isfield(stimuli,'stixel_width'))
                if (isfield(stimuli,'stixel_height'))
                   if (isfield(stimuli,'field_width'))    
                       if (isfield(stimuli,'field_height'))
                           
                           % Check for validity of stixel setup
                            if ((stimuli.stixel_width * stimuli.field_width) ~= (stimuli.x_end - stimuli.x_start))
                                fprintf('\t RSM ERROR: Stimulus width inconsistant. Please redfine stixel_width/field_width and/or x_start/x_end and try again. \n');
                                return
                            end
                            
                            if ((stimuli.stixel_height * stimuli.field_height) ~= (stimuli.y_end - stimuli.y_start)) 
                                fprintf('\t RSM ERROR: Stimulus height inconsistant. Please redfine stixel_height/field_height and/or y_start/y_end and try again. \n');
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
            
            if (isfield(stimuli, 'frames'))
                if (isfield(stimuli, 'num_reps'))
                    if (isfield(stimuli, 'repeats'))
                        obj.repeats = stimuli.repeats;
                        obj.num_reps = stimuli.num_reps;
                        obj.frames = stimuli.frames;
                    else
                       fprintf('\t RSM ERROR: repeats not recognized. Please define repeats and try again. \n');
                       return
                    end 
                else
                   fprintf('\t RSM ERROR: num_reps not recognized. Please define num_reps and try again. \n');
                   return
                end
            else
               fprintf('\t RSM ERROR: frames not recognized. Please define frames and try again. \n');
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
            
            if (isfield(stimuli,'sub_region'))
                obj.sub_region = stimuli.sub_region;
            else
                obj.sub_region = 0;
            end
            
            obj.wait_trigger = stimuli.wait_trigger;                            
            obj.wait_key = stimuli.wait_key;
            
            obj.stim_name = 'Moving Flashing Squares';
            obj.run_script = 'Run_Moving_Flashing_Squares( exp_obj.stimulus );';
            
            if obj.sub_region == 1
                % check if field_width/field_height is even
                if mod(obj.field_width, 2) ~= 0 || mod(obj.field_height, 2) ~= 0
                    fprintf('\t RSM ERROR: field_width or field height is not even. Please define field_width/field_height value and try again. \n');
                    return
                else
                    obj.trial_num = obj.field_width * obj.field_height / 4;
                end
            elseif obj.sub_region == 0;
                obj.trial_num = obj.field_width * obj.field_height;
            else
                fprintf('\t RSM ERROR: sub_region must be 1 or 0. Please define sub_region value and try again. \n');
                return
            end

            obj.trial_num_total = obj.trial_num * obj.repeats;
            
            obj.reps_run = 1;
            
            sequence = [];
            for i = 1:obj.repeats
                sequence = [sequence; randperm(obj.trial_num)];
            end

%             sequence(1, :) = 1:obj.trial_num;
            sequence = reshape(sequence', 1, obj.trial_num_total);
            obj.seq = sequence;
            stim_out = stimuli;
            stim_out.trial_list = sequence;
            uisave('stim_out')
        end
        
        
        function Run_Moving_Flashing_Squares( obj )
            
            x_vertices_all = cell(obj.trial_num, 1);
            y_vertices_all = cell(obj.trial_num, 1);
            
            if obj.sub_region == 0
                for i = 1:obj.trial_num
                    xi = floor(mod(i-0.5, obj.field_width));
                    yi = floor((i-0.5)/obj.field_width);
                    x1 = obj.x_start + obj.stixel_width * xi;
                    x2 = obj.x_start + obj.stixel_width * (xi + 1);
                    y1 = obj.y_start + obj.stixel_height * yi;
                    y2 = obj.y_start + obj.stixel_height * (yi + 1);

                    x_vertices_all{i} = [x1; x2; x2; x1];
                    y_vertices_all{i} = [y1; y1; y2; y2];
                end
            else
                for i = 1:obj.trial_num
                    xi = floor(mod(i-0.5, obj.field_width/2));
                    yi = floor((i-0.5)/(obj.field_width/2));
                    x1 = obj.x_start + obj.stixel_width * xi;
                    x2 = obj.x_start + obj.stixel_width * (xi + 1);
                    y1 = obj.y_start + obj.stixel_height * yi;
                    y2 = obj.y_start + obj.stixel_height * (yi + 1);
                    
                    x_vertexi = [x1; x2; x2; x1];
                    y_vertexi = [y1; y1; y2; y2];
                    
                    half_width = (obj.x_end - obj.x_start)/2;
                    half_height = (obj.y_end - obj.y_start)/2;

                    x_vertices_all{i} = [x_vertexi x_vertexi+half_width x_vertexi+half_width x_vertexi];
                    y_vertices_all{i} = [y_vertexi y_vertexi y_vertexi+half_height y_vertexi+half_height];
                end
            end
            
            mglClearScreen( obj.backgrndcolor );
            mglFlush();
            
            for i = 1:obj.trial_num_total
                
                x_vertices = x_vertices_all{obj.seq(i)};
                y_vertices = y_vertices_all{obj.seq(i)};
                
                cl = repmat(obj.color, 1, size(x_vertices, 2));
                bgrd_cl = repmat(obj.backgrndcolor, 1, size(x_vertices, 2));
                
                for j = 1:obj.num_reps
                    % First phase: turn on colored flash.
                    mglQuad(x_vertices, y_vertices, cl, 0); 

                    mglFlush();
                    Pulse_DigOut_Channel;

                    % Now make sure the second buffer is loaded with the
                    % fore-ground
                    mglQuad(x_vertices, y_vertices, cl, 0);  
                    mglFlush();

                    RSM_Pause(obj.frames-1); 


                    % Now the second phase of the cycle, return to background
                    mglQuad(x_vertices, y_vertices, bgrd_cl, 0); 

                    mglFlush();
                    Pulse_DigOut_Channel;

                    % Now make sure the second buffer is loaded with the
                    % background
                    mglQuad(x_vertices, y_vertices, bgrd_cl, 0);  
                    mglFlush();

                    RSM_Pause(obj.frames-1);
                end
                
            end
            
        end  % run moving flash squares
        
    end  % method block
                
end   % class def