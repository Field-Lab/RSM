% Run_OnTheFly: Used for presenting textures that can be updated every
% frame refresh. This routine is the core routine for presenting random
% noise and raw movies
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%    purpose: Role
%      usage: Examples
%
%

function Run_OnTheFly( stim_obj )
		
    % Made obsolete by changes to Run_OnTheFly
    %stim_obj.frames_shown = stim_obj.frames_shown + 1; 
    
    % This code handles whether it is time to get a fresh stimulus frame
    if (stim_obj.countdown == 1)  
        
        stim_obj.countdown = stim_obj.stim_update_freq;  % reset to the number of frames specified by "interval"
        
        eval( stim_obj.make_frame_script );

        stim_obj.frametex = mglCreateTexture( img_frame, [], 0, {'GL_TEXTURE_MAG_FILTER','GL_NEAREST'} );
       
    else
        stim_obj.countdown = stim_obj.countdown - 1;    % it wasn't time to get a new frame, so instead we just decrement the count down
    end

            
    % clear the screen
    mglClearScreen( stim_obj.backgrndcolor );   

     % blit the texture 
     mglBltTexture( stim_obj.frametex, [(stim_obj.cen_width + stim_obj.x_cen_offset), (stim_obj.cen_height + stim_obj.y_cen_offset), stim_obj.span_width, stim_obj.span_height] );   % should be centered

     % Display sync pulse square (if called for)
     if (~isempty(stim_obj.sync_pulse))
        if (stim_obj.countdown == stim_obj.stim_update_freq)
                    
            % New synch: Switch pulses
            if (stim_obj.sync_pulse.state == 1) 
                % Set "on" sync pulse
                mglQuad(stim_obj.sync_pulse.x_vertices, stim_obj.sync_pulse.y_vertices, stim_obj.sync_pulse.color, 0);  
                stim_obj.sync_pulse.state = 0;

            else
                % Set "off" sync pulse (ie sync pulse is set to background color)
                mglQuad(stim_obj.sync_pulse.x_vertices, stim_obj.sync_pulse.y_vertices, [stim_obj.backgrndcolor(1); stim_obj.backgrndcolor(2); stim_obj.backgrndcolor(3)], 0);
                stim_obj.sync_pulse.state = 1;
            end  % end for new-sync switch if-then
                    
        else
            % not a new-sync // leave things as they were
            if (stim_obj.sync_pulse.state == 1)
                % Leave "off" sync pulse (ie sync pulse is set to background color)
                mglQuad(stim_obj.sync_pulse.x_vertices, stim_obj.sync_pulse.y_vertices, [stim_obj.backgrndcolor(1); stim_obj.backgrndcolor(2); stim_obj.backgrndcolor(3)], 0);  
                        
            else
                % Leave on sync pulse
                mglQuad(stim_obj.sync_pulse.x_vertices, stim_obj.sync_pulse.y_vertices, stim_obj.sync_pulse.color, 0);
                       
            end  % end for not-new-sync switch if-then
                
         end  % check for new sync pulse 
    end % check for sync pulse
           
    % Check for stealth mode; if required wipe out all stimuli!
    if (stim_obj.stealth_flag == 1)
        mglClearScreen( stim_obj.backgrndcolor );
    end
      
    % flush the buffer
    mglFlush;
    
    % Now collect timestamp info 
    stim_obj.timestamp_record(stim_obj.repeat_num, (stim_obj.frames_shown+1)) = mglGetSecs;   % NB: The +1 is a kludge. The frames shown is only incremented after we return to Stim_Engine. So we need to artificially inflate here. 
           
    
    % Frame save is too slow for any high refresh rate. This is merely for
    % debug purposes
    if ( stim_obj.frame_save )
        stim_obj.frame_record =cat(4, stim_obj.frame_record, img_frame);
    end
            
    
    % Occasionally flush the DIO buffer. Why? To make sure the DIO buffer
    % doesn't overflow.
    % It is uncertain how much this is really needed.
    if (mod(stim_obj.frames_shown, 10000)==0)
        stim_obj.digin_dummy = mglDigIO('digin'); 
    end

            
    % Clear the texture from the graphics card
    % NB: This is crucial. 
    if (stim_obj.countdown == 1)
        mglDeleteTexture( stim_obj.frametex );               
    end
            