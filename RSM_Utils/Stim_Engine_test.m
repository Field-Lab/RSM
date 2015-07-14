% Stim_Engine: This function is the heart of the code. It holds the
% invocation of the stimulus object presentation methods. It also controls
% the logic of withing stimulus repeats and stimuli that run for fixed
% amounts of time or fixed numbers of repetitions.
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%    purpose: Role

function[ exp_obj ] = Stim_Engine_test( exp_obj )

% save out info about the stimulus
% Name of the stimulus should be already there (copied from pending)
% hack for now:
exp_obj.stimulus = exp_obj.pending_stimuli{1};


fprintf('\n');
fprintf('******************************  Session: %s  Stimulus #: %d  ******************************* \n', exp_obj.session_name, (exp_obj.num_stim_ran + 1));

% Here we recover the hidden MGL global structure for storage purposes
fprintf('\n');
fprintf('SAVING SETUP INFO: %s \n', exp_obj.stimulus.stim_name);

global MGL
fn = strcat(exp_obj.log_file_dir,'/',exp_obj.session_fn);

if ( ~isempty( findprop(exp_obj.stimulus, 'mem_movie') ) )
    if (~isempty( exp_obj.stimulus.mem_movie ) )
        fprintf('\t WARNING: No pre-run-save available with movie in memory. \n');
    end
else
    save( fn, 'exp_obj', 'MGL' );
end


n_repeats = exp_obj.stimulus.n_repeats;
timestamp_record = cell(1, n_repeats);
frames_shown = cell(1, n_repeats);

% first time stamp
exp_obj.stimulus.run_date_time = clock;
% TIME STAMP BEFORE PRESENTATION BEGINS
tmain0 = mglGetSecs;

for repeat_counter = 1:n_repeats
    
    % We are now ready to run stim.
    % Convention is that we record the trigger timestamp before we flush
    % the screen.
    if (exp_obj.stimulus.wait_trigger)
        
        % Wait for main trigger signal from DAQ
        fprintf('WAITING FOR TRIGGER: %s \n', exp_obj.stimulus.stim_name);
        [ exp_obj.stimulus.trep0(repeat_counter) ] = Scan_4_Trigger( exp_obj );  % recall the timestamp occurs within Scan_4_Trigger
        
    elseif (exp_obj.stimulus.wait_key) % wait for key press event
        fprintf('WAITING FOR KEY: %s \n', exp_obj.stimulus.stim_name);
        % wait around and check for trigger event
        pause;
        
    end  % wait for main trigger event or key press
    
    % Trigger condition has now been met, on with the show!
    
    % TIME STAMP AFTER TRIGGER HAS BEEN MET. FOR EACH REPETITION!
    exp_obj.stimulus.trep0(repeat_counter) = mglGetSecs; 
    
    mglClearScreen( exp_obj.stimulus.backgrndcolor );
    mglFlush();
    exp_obj.stimulus.main_trigger = 1; % where is that used, and what for?

    if exp_obj.stealth_flag <= 0
        fprintf('RUNNING STIMULUS: %s \n', exp_obj.stimulus.stim_name);
    end
    
    % Scope data from 06/13/13 suggests that the first pulse from the mac
    % to the daq occurs only 1.6 ms after daq trigger
    % This suggests the first mac2daq is sent out before the first buffer
    % flip to a RN stimulus
    if exp_obj.stealth_flag <= 1
        Pulse_DigOut_Channel;
    end
    
    % Get # pending stimuli
    total_pending_stimuli = length(exp_obj.pending_stimuli);
    
    % run all pending stimuli
    for i = 1:total_pending_stimuli
        
        % Grab a stimulus entry
        exp_obj.stimulus = exp_obj.pending_stimuli{i};
        
        run_flag = 1;
        % subloop to handle duration
        
        % if white noise, we want to reset rng before each repetition
        if ( ~isempty( findprop(exp_obj.stimulus, 'rng_init') ) )
            
            exp_obj.stimulus.r_stream = [];  % NOTE: Setting r_stream to [] is an important signalling device.
            exp_obj.stimulus.rng_init.state = Init_RNG_JavaStyle( exp_obj.stimulus.rng_init.state );
            
        end  % RNG setup stuff
        
        while run_flag % MAIN STIM RUN LOOP
            
            % Phase 1
            % CORE EVAL STATEMENT THAT RUNS EACH STIMULUS REP
            eval(exp_obj.stimulus.run_script);
            
            % could get time stamp here for analysis later
            
            % Phase 2 - figure out what's that later
            % Test whether it is time to output another pulse to the daq
            if exp_obj.stealth_flag <= 1
                if  exp_obj.dio_config.numframes_per_pulse > 0 && ...
                        exp_obj.stimulus.frames_shown > 0 && ...% This prevents double trigger on first pulse out.
                        mod(exp_obj.stimulus.frames_shown, exp_obj.dio_config.numframes_per_pulse)==0
                    Pulse_DigOut_Channel;
                end
            end
            
            % make "frames_shown" common property of all stimuli classes
            exp_obj.stimulus.frames_shown = exp_obj.stimulus.frames_shown + 1;
            
            % Phase 3
            % Test timing if to continue: elapsed frames or total duration
            if ~isempty( findprop(exp_obj.stimulus, 'n_frames') ) % total frames mode (frames: movies, gratings)
                if exp_obj.stimulus.frames_shown >= exp_obj.stimulus.n_frames
                    run_flag = 0;
                    % temporarily save time stamps if present (raw movies)
                    if ~isempty( findprop(exp_obj.stimulus, 'timestamp_record') )
                        timestamp_record{repeat_counter} = exp_obj.stimulus.timestamp_record(1:exp_obj.stimulus.frames_shown);
                    end
                end
            elseif ~isempty( exp_obj.stimulus.run_duration ) % total time mode (s: white noise)
                tmain_elapsed = mglGetSecs(exp_obj.stimulus.trep0(repeat_counter));
                if (tmain_elapsed > exp_obj.stimulus.run_duration)
                    run_flag = 0;
                    % temporarily save time stamps if present (white noise)
                    if ~isempty( findprop(exp_obj.stimulus, 'timestamp_record') )
                        timestamp_record{repeat_counter} = exp_obj.stimulus.timestamp_record(1:exp_obj.stimulus.frames_shown);
                    end
                end
            else % all others: unspecified termination condition, no Run_OnTheFly called, finish now
                run_flag = 0;
            end
            
            
            % this is for debugging
            % Finally we test whether a frame_stop is present and if so whether
            % the condition is met
            if exp_obj.stealth_flag <= 0
                if ( ~isempty( findprop(exp_obj.stimulus, 'stop_frame') ) )
                    if (~isempty(exp_obj.stimulus.stop_frame))
                        if (exp_obj.stimulus.frames_shown == exp_obj.stimulus.stop_frame)
                            keyboard
                        end  % STOP FOR DEBUG ON SPECIFIC FRAME
                    end   % test for debug frame stop being active
                end       % check for stop_frame
            end         % stealth bypass
            
            
        end % MAIN STIM RUN LOOP
        
        % could reset to background after each individual stimulus or after all pending stimuli
        mglClearScreen( exp_obj.monitor.backgrndcolor );
        mglFlush();
        

        frames_shown{repeat_counter} = exp_obj.stimulus.frames_shown;
        exp_obj.stimulus.frames_shown = 0;
        % Now clear out the stim field (play it safe)
        exp_obj.stimulus = [];
        
    end % all pending stimuli
    
    % reset screen coordinates
    mglScreenCoordinates();
    mglClearScreen( exp_obj.monitor.backgrndcolor );
    mglFlush();

    exp_obj.stimulus = exp_obj.pending_stimuli{1}; % set it to 1 to start the new repeat (if requested)
    
    % could get a time stamp for the entire repeat here

end % all repeats

% Post stimulus cleanup and reporting
exp_obj.stimulus.run_time_total = mglGetSecs(tmain0);
exp_obj.num_stim_ran = exp_obj.num_stim_ran + 1;
exp_obj.past_stimuli{ exp_obj.num_stim_ran } = exp_obj.stimulus.stim_name;   % Formerly saved entire exp_obj.stimulus. Decided this might lead to exp_obj.past_stimuli becoming huge memory sink.
% Decided to merely save stim_name as compromise.


    
fprintf('FINISHED WITH: %s \n', exp_obj.stimulus.stim_name);
if ~isempty( findprop(exp_obj.stimulus, 'timestamp_record'))
    % Trim trailing zeros from time-stamp record and then examine it
    exp_obj.stimulus.timestamp_record = timestamp_record;
    exp_obj.stimulus.frames_shown = frames_shown;
    Analyze_Timestamps( exp_obj );
end

fprintf('\n');
fprintf('***********************************************************************************************\n');


% % Finally reset to screen coords (in case something got switched out of
% % screencoords (ie moving gratings)
% [num_pending, first_nonempty] = Num_Nonempty( exp_obj.pending_stimuli );
% 
% if ( num_pending > 0 )
%     % Then there is a pending stimulus
%     if ~( strcmp(exp_obj.pending_stimuli{first_nonempty}.stim_name,'Moving_Grating') || strcmp(exp_obj.pending_stimuli{first_nonempty}.stim_name,'Counterphase_Grating'))
%         % If the next stimulus is a grating then do nothing. (Why? because we expect gratings only after other gratings...
%         % thus we set up the proper screen settings once and then do not reset back to the default screencoordinates.
%         
%         % However, if we have reached this point then something is funky.
%         % We have a non-grating in the pending stim cue... This means we
%         % have presumably not set up from a S-file
%         % So, reset to screen coordinates
%         mglScreenCoordinates();
%     else
%         mglClearScreen( exp_obj.monitor.backgrndcolor );
%         mglFlush();
%     end
%     
% else
%     % No pending stimulus, reset to screen coordinates as usual.
%     mglScreenCoordinates();
%     mglClearScreen( exp_obj.monitor.backgrndcolor );
%     mglFlush();
%     
% end


fprintf('\n');
fprintf('Ready for next stimulus setup; "Stop_RSM" to quit. \n');
    
