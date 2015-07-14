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

function[ exp_obj ] = Stim_Engine( exp_obj )


not_done = 1;

% Now loop through stimuli pending in the queue
while( not_done )
    
    % Get the Number of stim remaining in fifo
    [num_pending_stim, first_nonempty] = Num_Nonempty( exp_obj.pending_stimuli );
    
    % Grab the first entry off the fifo
    exp_obj.stimulus = exp_obj.pending_stimuli{first_nonempty};
    
    % Now clear the entry from the pending queue
    exp_obj.pending_stimuli{first_nonempty} = [];
    
    
    exp_obj.stimulus.repeat_num = 1;
    
    % Stub for repeat functionality code.
    
%     % seed the random number gen
    if ( ~isempty( findprop(exp_obj.stimulus, 'rng_init') ) )
        
        exp_obj.stimulus.r_stream = [];  % NOTE: Setting r_stream to [] is an important signalling device.
        exp_obj.stimulus.rng_init.state = Init_RNG_JavaStyle( exp_obj.stimulus.rng_init.state );
        
    end  % RNG setup stuff
    
    if exp_obj.stealth_flag <= 0
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
        
    end
    
    
    
    exp_obj.stimulus.run_date_time = clock;
    
    
    % We are now ready to run stim.
    % Convention is that we record the trigger timestamp before we flush
    % the screen.
    if (exp_obj.stimulus.wait_trigger)
        
        % Wait for main trigger signal from DAQ
        fprintf('WAITING FOR TRIGGER: %s \n', exp_obj.stimulus.stim_name);
        [ exp_obj.stimulus.tmain0(exp_obj.stimulus.repeat_num) ] = Scan_4_Trigger( exp_obj );  % recall the timestamp occurs within Scan_4_Trigger
        
    else
        if (exp_obj.stimulus.wait_key)
            fprintf('WAITING FOR KEY: %s \n', exp_obj.stimulus.stim_name);
            % wait around and check for trigger event
            pause;
        end  % wait for key press event
        
%         exp_obj.stimulus.tmain0(exp_obj.stimulus.repeat_num) = mglGetSecs;
        
    end  % wait for main trigger event
    
    exp_obj.stimulus.tmain0(exp_obj.stimulus.repeat_num) = mglGetSecs;
    
    % Trigger condition has now been met, on with the show!
    mglClearScreen( exp_obj.stimulus.backgrndcolor );
    mglFlush();
    exp_obj.stimulus.main_trigger = 1;
    
    
    % Set run flags and initialize timers
    run_flag = 1;
    exp_obj.stimulus.trep0 = exp_obj.stimulus.tmain0;
    
    
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
    
    
    % While loop that runs one repeat of a stim presentation
    while run_flag 
        
        % *** STUB FOR REP LEVEL TRIGGERING ***
        
        % Phase 1
        % CORE EVAL STATEMENT THAT RUNS EACH STIMULUS REP
        eval(exp_obj.stimulus.run_script);
        
        
        % Phase 2
        % Test whether it is time to output another pulse to the daq
        if exp_obj.stealth_flag <= 1
            if  ~isempty( findprop(exp_obj.stimulus, 'frames_shown') ) && ...
                    exp_obj.dio_config.numframes_per_pulse > 0 && ...
                    exp_obj.stimulus.frames_shown > 0 && ...% This prevents double trigger on first pulse out.
                    mod(exp_obj.stimulus.frames_shown, exp_obj.dio_config.numframes_per_pulse)==0
                Pulse_DigOut_Channel;
            end
        end
        
        
        % Phase 3
        % Test for relevant presentation tracking attributes. If none
        % exist then do nothing.
        if ( ~isempty( findprop(exp_obj.stimulus, 'frames_shown') ) )
            % then we are in frames mode
            exp_obj.stimulus.frames_shown = exp_obj.stimulus.frames_shown + 1;
            
        elseif ( ~isempty( findprop(exp_obj.stimulus, 'reps_run') ) )
            % then we are in num_reps mode
            exp_obj.stimulus.reps_run = exp_obj.stimulus.reps_run + 1;
            
        end
        
        
        
        % Phase 4
        % check whether we are done with timed duration or fixed number of reps.
        if (~isempty( exp_obj.stimulus.run_duration ))
            % timed duration mode
            
            % First we reset the rep_trigger
            exp_obj.stimulus.trep0 = mglGetSecs;
            exp_obj.stimulus.rep_trigger = 0;
            
            % Then we check for run duration being expired
            tmain_elapsed = mglGetSecs(exp_obj.stimulus.tmain0(exp_obj.stimulus.repeat_num));
            
            if (tmain_elapsed > exp_obj.stimulus.run_duration)
                run_flag = 0;
            end
            
        else
            % fixed number of repetition mode
            % For movies (or any other interval capable stimulus) we only want to update this every time a novel
            % frame is shown.
            if ( ~isempty( findprop(exp_obj.stimulus, 'n_frames') ) )
                % then we are in n_frames
                if (exp_obj.stimulus.frames_shown >= exp_obj.stimulus.n_frames)
                    % then we are done
                    run_flag = 0;
                end
                
            else
                % then we are in num_reps mode
                if (exp_obj.stimulus.reps_run >= exp_obj.stimulus.num_reps)
                    % then we are done
                    run_flag = 0;
                end
            end     % test for rep versus frame notation
            
        end % test for timed duration versus num reps mode
        
        
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
    
    
    % Post stimulus cleanup and reporting
    
    exp_obj.stimulus.run_time_total = mglGetSecs(exp_obj.stimulus.tmain0(1));
    exp_obj.num_stim_ran = exp_obj.num_stim_ran + 1;
    exp_obj.past_stimuli{ exp_obj.num_stim_ran } = exp_obj.stimulus.stim_name;   % Formerly saved entire exp_obj.stimulus. Decided this might lead to exp_obj.past_stimuli becoming huge memory sink.
    % Decided to merely save stim_name as compromise.
    
    % Here we save after the run
    if exp_obj.stealth_flag <= 0
        
        fprintf('FINISHED WITH: %s \n', exp_obj.stimulus.stim_name);
        if (( ~isempty( findprop(exp_obj.stimulus, 'timestamp_record') ) ) && ( ~isempty( findprop(exp_obj.stimulus, 'frames_shown') ) ))
            % Trim trailing zeros from time-stamp record and then examine it
            exp_obj.stimulus.timestamp_record = exp_obj.stimulus.timestamp_record(:,1:exp_obj.stimulus.frames_shown);
            Analyze_Timestamps( exp_obj );
        end
        
        fprintf('\n');
        fprintf('***********************************************************************************************\n');
    end  % stealth mode
    
    
    % Finally reset to screen coords (in case something got switched out of
    % screencoords (ie moving gratings)
    [num_pending, first_nonempty] = Num_Nonempty( exp_obj.pending_stimuli );
    
    if ( num_pending > 0 )
        % Then there is a pending stimulus
        if ~( strcmp(exp_obj.pending_stimuli{first_nonempty}.stim_name,'Moving_Grating') || strcmp(exp_obj.pending_stimuli{first_nonempty}.stim_name,'Counterphase_Grating'))
            % If the next stimulus is a grating then do nothing. (Why? because we expect gratings only after other gratings...
            % thus we set up the proper screen settings once and then do not reset back to the default screencoordinates.
            
            % However, if we have reached this point then something is funky.
            % We have a non-grating in the pending stim cue... This means we
            % have presumably not set up from a S-file
            % So, reset to screen coordinates
            mglScreenCoordinates();
        else
            mglClearScreen( exp_obj.monitor.backgrndcolor );
            mglFlush();
        end
        
    else
        % No pending stimulus, reset to screen coordinates as usual.
        mglScreenCoordinates();
        mglClearScreen( exp_obj.monitor.backgrndcolor );
        mglFlush();
        
    end
    
    
    
    
    
    % Now clear out the stim field (play it safe)
    exp_obj.stimulus = [];
    
    % Check for end
    if (num_pending_stim == 1)
        not_done = 0;
    end
    
end % loop through stim




if (~exp_obj.stealth_flag)

    fprintf('\n');
    fprintf('Ready for next stimulus setup; "Stop_RSM" to quit. \n');

end % stealth flag
