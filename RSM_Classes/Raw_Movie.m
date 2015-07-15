classdef	Raw_Movie < handle
% Raw_Movie: Play a movie stored in raw movie format.
%
%        $Id: Raw_Movie VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%
	properties
        
        % Required props for all stim classes        

        % colors
        backgrndcolor
        
        % centering and size
        x_start
        y_start
        span_height
        span_width
        
        % key, trigger, repeats
        wait_key
        wait_trigger
        n_repeats
        
        % file path and name, header size
        movie_filename
        header_size
        
        % frames setup
        first_frame
        last_frame
        n_frames
        
        % flip and reverse flags
        reverse_flag
        flip_flag
        
        % interval
        stim_update_freq              
 
        % stealth mode, timestamps
        stealth_flag
        timestamp_record
        
        %debug
        stop_frame
        frame_save
        frame_record
        sync_pulse
        
        
        % initialized
        
        run_date_time
        run_time_total = [];
        main_trigger = 0;
        tmain0 = [];
        trep0 = [];
        frames_shown = 0;
        mem_movie = [];
        current_frame = 0;
        countdown = 1;
        frametex = [];
        digin_dummy = [];
        r_stream = -999;
        
	end			% properties block
    
    properties(Constant)
        stim_name = 'Raw_Movie';
        run_script = 'Run_OnTheFly(exp_obj.stimulus);'; %'Play_Raw_Movie(exp_obj.stimulus);';
        make_frame_script = '[img_frame] = Make_Frame_RawMovie( stim_obj );';
    end
	
	methods
		
        % Constructor method
        function[obj] = Raw_Movie( stimuli, exp_obj )
            
            %%%%%  check if all user-defined fields exist  %%%%%
            
            user_fields = {'stop_frame','flip_flag', 'reverse_flag','first_frame','last_frame',...
            'movie_name','interval','preload'};
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

            % colors
            obj.backgrndcolor = stimuli.back_rgb';
            obj.backgrndcolor = Color_Test( obj.backgrndcolor );

            % centering
            obj.x_start = stimuli.x_start + exp_obj.monitor.width/2; % for top let corner, don't add monitor
            obj.y_start = stimuli.y_start + exp_obj.monitor.height/2; % for top left corner, don't add monitor

            % key, trigger, repeats
            obj.wait_trigger = stimuli.wait_trigger;                            
            obj.wait_key = stimuli.wait_key;
            obj.n_repeats = stimuli.n_repeats;
           
            % file path and name setup
            if (isfield(stimuli,'movie_path'))
                movie_path = stimuli.movie_path;
            else
                % silently set path to default
                movie_path = exp_obj.movie_path;
            end
            obj.movie_filename = cat(2, movie_path, '/', stimuli.movie_name);
            
            % read movie header and extract dimensions and duration (frames)
            fid=fopen(obj.movie_filename,'r');
            temp = fscanf(fid, '%s', 1);% scan the file for a string
            if ~isequal( temp, 'header-size' )% check that string is 'header-size'
                fprintf('\t FATAL ERROR in raw movie read: no header-size.');
                keyboard
            else
                obj.header_size = str2num( fscanf(fid, '%s', 1) );  % now scan and extract header size info
            end
            
            duration_in_frames = [];
            while isempty(findprop(obj,'span_height')) || isempty(findprop(obj,'span_width')) || isempty(duration_in_frames)
                t=fscanf(fid,'%s',1);               
                switch t
                    case 'height'
                        obj.span_height=str2num( fscanf(fid, '%s', 1) );
            
                    case 'width'
                        obj.span_width=str2num( fscanf(fid, '%s', 1) );  
        
                    case {'frames', 'frames-generated'}                
                        duration_in_frames = str2num( fscanf(fid, '%s', 1) );     % we will use n_frames to track number of individual frames
                                                                                % to be shown
                end  % switch on header reading
            
            end      % while loop for header reading
            % the mex code is stand alone: opens and closes at each read operation
           fclose(fid);
            
            % this expands each pixel of the movie by stixel dims
            obj.span_height=obj.span_height * stimuli.stixel_height;
            obj.span_width=obj.span_width * stimuli.stixel_width;
            
            % number of frames
            obj.first_frame = stimuli.first_frame;
            if ~isempty(stimuli.last_frame) % user defined
                if stimuli.last_frame > duration_in_frames
                    fprintf('\t last frame is larger than total movie length');
                    return
                else
                    obj.last_frame = stimuli.last_frame;
                    obj.n_frames = (obj.last_frame - obj.first_frame) + 1;
                end
            else % default, all frames
                obj.n_frames = duration_in_frames;
                obj.last_frame = duration_in_frames;
            end
                      
            % flags for reverse and flip
            obj.flip_flag = stimuli.flip_flag;
            obj.reverse_flag = stimuli.reverse_flag;

            % interval
            obj.stim_update_freq = stimuli.interval;
            
            % timestamp record
            obj.timestamp_record = zeros(1,obj.n_frames);
            
            % stealth mode
            obj.stealth_flag = exp_obj.stealth_flag;

            %debug
            obj.sync_pulse = Sync_Setup_Util( stimuli, exp_obj );
            obj.stop_frame = stimuli.stop_frame;
            obj.frame_save = 0;
            obj.frame_record = [];
     
            %%%%%  Simply initialized  %%%%%
            
            obj.run_date_time = [];
            obj.run_time_total = [];
            obj.main_trigger = 0;
            obj.tmain0 = [];
            obj.trep0 = [];
            obj.frames_shown = 0;
            obj.mem_movie = [];
            obj.current_frame = 0;
            obj.countdown = 1;          
            obj.frametex = [];
            obj.digin_dummy = [];
            obj.r_stream = -999; % This is for signalling purposes. This tells Run_OnTheFly to use Make_Frame script

        end		% constructor
    
	end			% methods block
    
end             % Random Noise clas