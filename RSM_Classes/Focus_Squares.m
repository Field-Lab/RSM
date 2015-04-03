% Focus_Squares: Presents simple quad-pattern for aid in stimulus focusing
%
%        $Id: Focus_Squares VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%
%      usage: Examples
%     inputs: Constructor accepts stimuli definition structure.
%    outputs: Constructor returns Flashing_Color stimulus object. 
%      calls:
%       	mglScreenCoordinates
%       	mglClearScreen
%       	mglQuad
%       	mglFlush
%




classdef	Focus_Squares < handle
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
        
        wait_trigger
        wait_key
        
        w
        h
        cw
        ch

        sw
        sh

        backgrndcolor
        repeat_num

        
  
	
	end			% properties block
	
	
	
	methods
		
        % Constructor method
        function[obj] = Focus_Squares( stimuli, exp_obj )
            
            obj.stim_name = 'Focus Squares';

            obj.run_date_time = [];
            obj.run_time_total = [];
            
            obj.main_trigger = 1;       % For the focus stim no triggering is required
            obj.tmain0 = [];
            
            obj.rep_trigger = 1;
            obj.trep0 = [];
            
            obj.run_duration = 0;
            obj.stim_update_freq = [];
            
            obj.run_script = 'Run_Focus_Squares( exp_obj.stimulus );';
            
            obj.wait_trigger = 0;
            obj.wait_key = 0;
  
            obj.w = exp_obj.monitor.width;
            obj.h = exp_obj.monitor.height;
            
            obj.cw = exp_obj.monitor.cen_width;
            obj.ch = exp_obj.monitor.cen_height;

            if (isfield(stimuli,'stim_width'))
                if (isfield(stimuli,'stim_height'))

                    obj.sh = stimuli.stim_height;
            
                else
                    fprintf('\t RSM warning: using default full screen height. \n');
                    obj.sh = h;
                end  

                obj.sw = stimuli.stim_width;

            else
                fprintf('\t RSM warning: using default full screen width. \n');
                obj.sw = w;
            end  
   
            
            obj.backgrndcolor = exp_obj.monitor.backgrndcolor;
            obj.repeat_num = 0;
		end		% constructor 
		

        function Run_Focus_Squares( obj )

            %    0-w =  monitor width
            %   x = stim width
            %   b = w - x;
            %   start = b/2
            %   stop = w - (b/2)
            temp_w = obj.w - obj.sw;
            start_x = floor( temp_w / 2 );
            stop_x = obj.w - floor( temp_w / 2 ); 

            temp_h = obj.h - obj.sh;
            start_y = floor( temp_h / 2 );
            stop_y = obj.h - floor( temp_h / 2 ); 

            
           
            x_vertices = [start_x, obj.cw, obj.cw, start_x; obj.cw, stop_x, stop_x, obj.cw; obj.cw, stop_x, stop_x, obj.cw; start_x, obj.cw, obj.cw, start_x];
            y_vertices = [start_y, start_y, obj.ch, obj.ch; start_y, start_y, obj.ch, obj.ch; obj.ch, obj.ch, stop_y, stop_y; obj.ch, obj.ch, stop_y, stop_y];
            colors = [1, 0, 1, 0; 1, 0, 1, 0; 1, 0, 1, 0];
          
            mglScreenCoordinates
           
            mglClearScreen( obj.backgrndcolor );
            
            mglQuad(x_vertices, y_vertices, colors, 0);  % we have to make sure anti-aliasing is off
            
            mglFlush();
            
            fprintf('\n');
            disp('Hit any key to clear screen and return to session stim selection menu: ');
            pause
            fprintf('\n');

        end     % presentation of focus squares
		
        
	end			% methods block
    
    
end             % Focus Square class