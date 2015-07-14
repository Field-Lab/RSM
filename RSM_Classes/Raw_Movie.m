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
 
        timestamp_record
        make_frame_script
        movie_path
        movie_filename 
        fid
        
        header_size
        span_height
        span_width
        blank_frame
        
        r_stream                % used for signalling to Run_OnTheFly
                
        predicted_frame_times

        x_cen_offset
        y_cen_offset
        
        frame_save 
        frame_record
        frames_shown            % formerly reps_run
        n_frames                % formerly num_reps

        stop_frame              % for interrupts at a given frame shown
        first_frame
        last_frame
        
        current_frame

        mem_movie
     
        
        countdown               % used for holding each movie frame for multiple screen refreshes
        frametex
        
        wait_key
        wait_trigger
        
        sync_pulse
        
        digin_dummy
        
        n_repeats
        repeat_num 

        backgrndcolor
        
        cen_width
        cen_height
        
        stealth_flag
        
        reverse_flag
        flip_flag
        
	end			% properties block
	
	
	
	methods
		
        % Constructor method
        function[obj] = Raw_Movie( stimuli, exp_obj )
            
            %%%%%  check if all user-defined fields exist  %%%%%
            
            user_fields = {'stop_frame','flip_flag', 'reverse_flag','first_frame','last_frame',...
            'fn','interval','preload'};
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
        
        
            [ obj.sync_pulse ] = Sync_Setup_Util( stimuli, exp_obj );

            obj.stop_frame = stimuli.stop_frame;
        
            
            obj.n_repeats = stimuli.n_repeats;
            
            obj.flip_flag = stimuli.flip_flag;
            obj.reverse_flag = stimuli.reverse_flag;
            obj.first_frame = stimuli.first_frame;
            obj.last_frame = stimuli.last_frame;
            
            nopath_movie_filename = stimuli.fn;
            obj.stim_update_freq = stimuli.interval;
            


            if (isfield(stimuli,'movie_path'))
                obj.movie_path = stimuli.movie_path;        
            else
                % silently set path to default
                obj.movie_path = exp_obj.movie_path;             
            end


            obj.wait_trigger = stimuli.wait_trigger;                            
            obj.wait_key = stimuli.wait_key;

            obj.backgrndcolor = stimuli.back_rgb';
            obj.backgrndcolor = Color_Test( obj.backgrndcolor );
            
            obj.stim_name = 'Raw_Movie';

            obj.run_date_time = [];
            obj.run_time_total = [];
           
            obj.main_trigger = 0;
            obj.tmain0 = [];
            
            obj.rep_trigger = 1;
            obj.trep0 = [];
            
            obj.run_script = 'Run_OnTheFly(exp_obj.stimulus);'; %'Play_Raw_Movie(exp_obj.stimulus);';
            obj.make_frame_script = '[img_frame] = Make_Frame_RawMovie( stim_obj );';

            
            %---------------------
            
            obj.movie_filename = cat(2, obj.movie_path, '/', nopath_movie_filename);
            
            obj.fid=fopen(obj.movie_filename,'r');

            temp = fscanf(obj.fid, '%s', 1);% scan the file for a string

            if ~isequal( temp, 'header-size' )% check that string is 'header-size'
                fprintf('\t FATAL ERROR in raw movie read: no header-size.');
                keyboard
            else
                obj.header_size = str2num( fscanf(obj.fid, '%s', 1) );  % now scan and extract header size info
            end


            obj.span_height=[];
            obj.span_width=[];
            n_frames = [];

            while ( isempty(obj.span_height) || isempty(obj.span_width) || isempty(n_frames) ) 
                t=fscanf(obj.fid,'%s',1);               
                switch t
                    case 'height'
                        obj.span_height=str2num( fscanf(obj.fid, '%s', 1) );
            
                    case 'width'
                        obj.span_width=str2num( fscanf(obj.fid, '%s', 1) );  
        
                    case 'frames'                     
                        n_frames = str2num( fscanf(obj.fid, '%s', 1) );     % we will use n_frames to track number of individual frames
                                                                                % to be shown
                    case 'frames-generated'                     % also see 'frames'
                        n_frames = str2num( fscanf(obj.fid, '%s', 1) );
            
                    otherwise
                        fscanf(obj.fid, '%s', 1);
                end  % switch on header reading
            
            end      % while loop for header reading

            % setup number of frames to be shown
            if ( ~isempty(obj.last_frame) )
                % the user has specified a start and stop frame; find
                % n_frames from that
                obj.n_frames = (obj.last_frame - obj.first_frame) + 1;
                
            else
                % Then we are using the default mode where we auto-detect
                % the number of frames
                obj.n_frames = n_frames;
                obj.last_frame = n_frames;

            end     % test for default stop_frame
            % Close file (the mex code is stand alone: opens and closes
            % w/ each read operation)
         
%            fclose(obj.fid);
            
            % Now re-open and bypass header
            obj.fid=fopen(obj.movie_filename,'r');

            fread(obj.fid, obj.header_size);

             
            blank = zeros(4, obj.span_width, obj.span_height, 'uint8');
            
            blank(4,:,:) = ones(1, obj.span_width, obj.span_height, 'uint8') * 255;
            obj.blank_frame = blank;
            
            obj.r_stream = -999; % This is for signalling purposes. This tells Run_OnTheFly to use Make_Frame script
            num_frames_planned = obj.n_frames;
            obj.timestamp_record = zeros(1,num_frames_planned);
     
            obj.frame_save = 0;
            obj.frame_record = [];
            obj.frames_shown = 0;

            obj.mem_movie = [];
           
            obj.current_frame = 0;
            obj.repeat_num = 0;
            obj.countdown = 1;          
            obj.frametex = [];
            
            obj.digin_dummy = [];
            
            
            obj.cen_width = exp_obj.monitor.cen_width;
            obj.cen_height = exp_obj.monitor.cen_height;
            
            obj.stealth_flag = exp_obj.stealth_flag;

        end		% constructor
		
		

        function Set_Frame_Num( obj )
            
            % Set start and stop limits 
            if (obj.reverse_flag == 1)
                % reverse case
                obj.current_frame = obj.last_frame - obj.frames_shown;
                
            else
                % forward case
                obj.current_frame = obj.first_frame + obj.frames_shown;

            end % reverse 
            
            
        end     % set frame num
	
        
	end			% methods block
    
    
end             % Random Noise clas