% Monitor_Obj: Class definition for monitor object. 
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


classdef	Monitor_Obj < handle


	properties
        monitor_name
        num_lut_bits
        gamma_model
        
        optometer_raw_data
 
        red_table
        green_table
        blue_table
        
        red_params
        green_params
        blue_params
        
        gamma_test_date
        
        width
        physical_width
        height
        physical_height
        screen_refresh_freq
        
        cen_width
        cen_height
          
        default_mondesc_path
        
        mon_num
        backgrndcolor
        

	end			% properties block
	
	
	
	methods
		
        % Constructor method
        function[obj] = Monitor_Obj( varargin )
            
            % Set our default monitor path
            obj.gamma_model = @BrainardModel;    % Based on eqt. 16 from Brainard, Pelli & Robson
            obj.mon_num = 2;
            obj.backgrndcolor = [0.5, 0.5, 0.5];

            fprintf(' \n \n ');
            fprintf('------------ Monitor Setup ------------- \n \n');
            obj.monitor_name = input('Enter human name of monitor: ');
            obj.width = Tested_Input_NumRange( 'Enter width of stimulus display screen [pixels]: ', 1, 3000 );
            obj.physical_width = Tested_Input_NumRange( 'Enter physical width of stimulus display screen [cm]: ', 1, 3000 );
            obj.height = Tested_Input_NumRange( 'Enter height of stimulus display screen [pixels]: ', 1, 3000 );
            obj.physical_height = Tested_Input_NumRange( 'Enter physical height of stimulus display screen [cm]: ', 1, 3000 );
            obj.screen_refresh_freq = Tested_Input_NumRange( 'Enter vertical refresh frequency of stimulus display screen [Hz]: ', 1, 240 );
            obj.num_lut_bits = Tested_Input_NumRange( 'Enter number of bits in LUT [bits]: ', 8, 10 );
            obj.optometer_raw_data = [];
                    
            fprintf('Setting default linear gamma tables: \n');
            obj.red_table = linspace(0, 1, 256);    % Default tables are simple-linear
            obj.green_table = linspace(0, 1, 256);
            obj.blue_table = linspace(0, 1, 256);
        
            obj.red_params = [1, 0, -1];      % [gamma, thresh, fitstat]
            obj.green_params = [1, 0, -1];
            obj.blue_params = [1, 0, -1];
        
            obj.gamma_test_date = [];

            % The following setup values are not under direct user control
            % via the setup script
            obj.cen_width = floor(obj.width / 2);
            obj.cen_height = floor(obj.height / 2);

		end		% constructor 
		

            
       function[obj] = Make_Gamma_Tables( obj )
            % This is intended to be called to collect data and create
            % profie

            % Are you truely prepared warning?
            % Retrieve MGL to get info on window
            fprintf('\n\n');
            fprintf('****************************************\n');
            fprintf('Make Gamma Correction LUTs from scratch.\n');
            fprintf('****************************************\n');

            fprintf('\n');
            not_done = Tested_Input_Logical('Enter (1) to collect data or (0) to abort: ');
            
            if (not_done)

                init_mgl_flag = mglWindow_Test( obj );
 
                % set up linear colormaps
                linear_lut.red = linspace(0, 1, 256);    % red gun table
                linear_lut.green = linspace(0, 1, 256);    % green gun table
                linear_lut.blue = linspace(0, 1, 256);   % blue gun table

       
                % Setup mgl window
                testbackgrndcolor = [0, 0, 0];  % Resest for gamma characterization daq

                mglSetGammaTable( linear_lut.red, linear_lut.green, linear_lut.blue );  % we always seize control of lut for monitor testing

                mglClearScreen( testbackgrndcolor );
            
                mglFlush;
            
                min_gun_val = 0;
                max_gun_val = 1;
                num_steps = 17;  % Enough?
                levels = linspace( min_gun_val, max_gun_val, num_steps) ;

                obj.optometer_raw_data = Photometer_DAQ_MultiUtil( obj, levels, 0 );  % Call in "de-novo" data collection mode, 17 points-gun 
            
            
                [ red_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'r', obj.gamma_model, obj.num_lut_bits );
                [ green_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'g', obj.gamma_model, obj.num_lut_bits );
                [ blue_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'b', obj.gamma_model, obj.num_lut_bits );
 

                % Repackage relevant channel outputs
                obj.red_table = red_channel_S.interp_lut;  % These interpolated LUTS seem better than gamma model for CTX monitor
                obj.green_table = green_channel_S.interp_lut;
                obj.blue_table = blue_channel_S.interp_lut;
            
                obj.red_params = [red_channel_S.fit_gamma , red_channel_S.fit_thresh , red_channel_S.fit_stat_final ];
                obj.green_params = [green_channel_S.fit_gamma , green_channel_S.fit_thresh , green_channel_S.fit_stat_final ];
                obj.blue_params = [blue_channel_S.fit_gamma , blue_channel_S.fit_thresh , blue_channel_S.fit_stat_final ];
            
                obj.gamma_test_date = date;

                if (init_mgl_flag)
                    mglClose;
                else
                    % Reset gamma table and background color
                    mglSetGammaTable( obj.red_table, obj.green_table, obj.blue_table );
                    mglClearScreen( obj.backgrndcolor );
                    mglFlush;

                end % mgl window cleanup if-then

            end  % if then test for data collect / skip 

        end     % create gamma table with fine sampling
        
        
        
      function[obj] = Remake_Gamma_Tables_Fit( obj )
              
                [ red_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'r', obj.gamma_model, obj.num_lut_bits );
                [ green_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'g', obj.gamma_model, obj.num_lut_bits );
                [ blue_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'b', obj.gamma_model, obj.num_lut_bits );
             
                obj.red_table = red_channel_S.fit_lut;  
                obj.green_table = green_channel_S.fit_lut;
                obj.blue_table = blue_channel_S.fit_lut;
                
                obj.red_params = [red_channel_S.fit_gamma , red_channel_S.fit_thresh , red_channel_S.fit_stat_final ];
                obj.green_params = [green_channel_S.fit_gamma , green_channel_S.fit_thresh , green_channel_S.fit_stat_final ];
                obj.blue_params = [blue_channel_S.fit_gamma , blue_channel_S.fit_thresh , blue_channel_S.fit_stat_final ];

        end     % create gamma table with fine sampling
      
        
        function[obj] = Remake_Gamma_Tables_Interp( obj )
              
                [ red_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'r', obj.gamma_model, obj.num_lut_bits );
                [ green_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'g', obj.gamma_model, obj.num_lut_bits );
                [ blue_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'b', obj.gamma_model, obj.num_lut_bits );
 
                % Repackage relevant channel outputs
                obj.red_table = red_channel_S.interp_lut;  % These interpolated LUTS seem better than gamma model for CTX monitor
                obj.green_table = green_channel_S.interp_lut;
                obj.blue_table = blue_channel_S.interp_lut;
              
                obj.red_params = [red_channel_S.fit_gamma , red_channel_S.fit_thresh , red_channel_S.fit_stat_final ];
                obj.green_params = [green_channel_S.fit_gamma , green_channel_S.fit_thresh , green_channel_S.fit_stat_final ];
                obj.blue_params = [blue_channel_S.fit_gamma , blue_channel_S.fit_thresh , blue_channel_S.fit_stat_final ];

        end     % create gamma table with fine sampling
      
        
        
	    function[obj] = Test_Monitor_Linearity( obj )
            fprintf('\n\n');
            fprintf('****************************************\n');
            fprintf('    Test linearity of corrected LUTs \n');
            fprintf('****************************************\n');

                         
            % Retrieve MGL to get info on window
            init_mgl_flag = mglWindow_Test( obj );
            
            % Setup new background window color for test
            testbackgrndcolor = [0, 0, 0];  % Resest for gamma characterization daq

            mglClearScreen( testbackgrndcolor );
            
            mglFlush;
            
            min_gun_val = 0;
            max_gun_val = 1;
            
    
            num_steps = 5;  % Enough?
            levels = linspace( min_gun_val, max_gun_val, num_steps) ;

            color_raw_data = Photometer_DAQ_MultiUtil( obj, levels, 0 );  
    
            
            num_steps = 9;  % Enough?
            levels = linspace( min_gun_val, max_gun_val, num_steps) ;
            
            grayscale_raw_data = Photometer_DAQ_MultiUtil( obj, levels, 1 );  % call in grayscale mode

            [ red_channel_S ] = Test_Linearity_Chan( color_raw_data, 'r', @LineModel, obj.num_lut_bits);
            [ green_channel_S ] = Test_Linearity_Chan( color_raw_data, 'g', @LineModel, obj.num_lut_bits);
            [ blue_channel_S ] = Test_Linearity_Chan( color_raw_data, 'b', @LineModel, obj.num_lut_bits);
            [ gray_channel_S ] = Test_Linearity_Chan( grayscale_raw_data, 'k', @LineModel, obj.num_lut_bits);
          
            Display_Linearity_Fits( red_channel_S, green_channel_S, blue_channel_S, gray_channel_S, @LineModel, obj.num_lut_bits);
            
            if (init_mgl_flag)
                mglClose;
            else
                % reset background levels
                mglClearScreen( obj.backgrndcolor );
                mglFlush;

            end
            
            [ testval ] = Tested_Input_Logical( 'Enter (1) to redo LUTs or (0) if linearity is sufficient to continue:  ' );
            if (testval)
                
                Make_Gamma_Tables(obj);
            
            else
                clear testval
                %   Save_Monitor_Description( obj );
                % No further action needed, save now in configure display
            end         % test for redo of lut
  
            
        end     % Assorted monitor linearity tests
	
        

        function[obj] = Update_Monitor_Freq( obj )
            % First
            init_mgl_flag = mglWindow_Test( obj );
            
            % Get run time
            [ run_minutes ] = Tested_Input_NumRange( 'Enter data collection time for monitor frequency determination (in minutes): ', 0.1, 60 );

            num_frames = run_minutes * 60 * obj.screen_refresh_freq;
            polarity = 1;

            w = obj.width;
            h = obj.height;
                        
            x_vertices = [0; w; w; 0];
            y_vertices = [0; 0; h; h];
        
             
            t_start = mglGetSecs;
                

            for i = 1:num_frames,
    
                mglClearScreen([0.5, 0.5, 0.5]);
   
                if (polarity)
                    % Then turn frame white
                    mglQuad(x_vertices, y_vertices, [1; 0; 0], 0);  
                    polarity = 0;
                else 
                    mglQuad(x_vertices, y_vertices, [0; 1; 0], 0);         
                    polarity = 1;
                end
    
                mglFlush();
    
            end   % loop through screen flashes

            telapsed = mglGetSecs(t_start);

            frame_period = telapsed / num_frames;

            obj.screen_refresh_freq = 1/frame_period;
        
            fprintf('Monitor refresh rate: %8.6d [Hz]', obj.screen_refresh_freq);
            
            if (init_mgl_flag)
                mglClose;
            else
                % reset background levels
                mglClearScreen( obj.backgrndcolor );
                mglFlush;

            end

        
        end     % Find monitor freq
        

        
        function[obj] = Debug_Gamma_Tables( obj )
          
            
                [ red_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'r', obj.gamma_model, obj.num_lut_bits );
                [ green_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'g', obj.gamma_model, obj.num_lut_bits );
               [ blue_channel_S ] = Analyze_Monitor_Chan( obj.optometer_raw_data, 'b', obj.gamma_model, obj.num_lut_bits );

                % Repackage relevant channel outputs
                obj.red_table = red_channel_S.interp_lut;  % These interpolated LUTS seem better than gamma model for CTX monitor
                obj.green_table = green_channel_S.interp_lut;
                obj.blue_table = blue_channel_S.interp_lut;
            
                obj.red_params = [red_channel_S.fit_gamma , red_channel_S.fit_thresh , red_channel_S.fit_stat_final ];
                obj.green_params = [green_channel_S.fit_gamma , green_channel_S.fit_thresh , green_channel_S.fit_stat_final ];
                obj.blue_params = [blue_channel_S.fit_gamma , blue_channel_S.fit_thresh , blue_channel_S.fit_stat_final ];
        
                
        end     % create gamma table with fine sampling
        
        
        
        
        
        
             
        function[init_mgl_flag] = mglWindow_Test( obj )
            
            global MGL
            
            init_mgl_flag = 0;
            
            if ( isempty(MGL) )                 %no open MGL window exists!
                init_mgl_flag = 1;
            else
                if (MGL.displayNumber == -1)    % then still no open MGL window exists!
                        init_mgl_flag = 1;
                end  
            end
            
            if (init_mgl_flag) 
                                
                    mglOpen( obj.mon_num, obj.width, obj.height, obj.screen_refresh_freq );             
             
                    mglScreenCoordinates;      % set screen coord system to pixels with 0,0 in up-left corner

                    mglSetGammaTable( obj.red_table, obj.green_table, obj.blue_table );
      
            end % window init
                
        end     % mglWindow_Test
        
        
        function Save_Monitor_Description( obj )
            
            save_flag = Tested_Input_Logical('Enter (1) to save current monitor description or (0) to skip: ');
            
            if (save_flag)
                sfn = cat(2, obj.default_mondesc_path, 'monitor_description_', obj.monitor_name, '_', date);
                save(sfn, 'obj');
            end

        end     % Save monitor description
        
        
       function obj = Open_Stimwindow( obj )
            
            % Open the relevant display
            mglOpen( obj.mon_num, obj.width, obj.height, obj.screen_refresh_freq );             
             
            mglScreenCoordinates;      % set screen coord system to pixels with 0,0 in up-left corner

            mglSetGammaTable( obj.red_table, obj.green_table, obj.blue_table );
                                
            mglClearScreen( obj.backgrndcolor );
            
            mglFlush;

        end % open stimwindow
		
  
        
    
    end			% methods block
    
    
end             % Monitor Object