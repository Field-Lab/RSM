function[ ] = Analyze_Timestamps( exp_obj )


num_stable_frames_criterion = 5; % Aribitrary hardset

for repeat_counter = 1:exp_obj.stimulus.n_repeats
    
    timestamp_record = exp_obj.stimulus.timestamp_record{repeat_counter} * 1000;  % So that we are working in ms
    frames_shown = exp_obj.stimulus.frames_shown{repeat_counter};
    save('/Users/alexandra/Desktop/matlab_stimulation/time_stamps.mat','timestamp_record', 'frames_shown');
    trep0 = exp_obj.stimulus.trep0(repeat_counter) * 1000;
    
    % Create basic prediction
    predicted_frame_times = linspace(0, exp_obj.stimulus.frames_shown{repeat_counter}-1, exp_obj.stimulus.frames_shown{repeat_counter});
    
    predicted_frame_times = predicted_frame_times*(exp_obj.stimulus.stim_update_freq / exp_obj.monitor.screen_refresh_freq);
    
    stability_tolerance = (0.1) * (1/exp_obj.monitor.screen_refresh_freq);                % HARDSET for 1/10th screen freq
    
    predicted_frame_times = predicted_frame_times + exp_obj.stimulus.trep0(repeat_counter);
    
    predicted_frame_times = predicted_frame_times * 1000;
    
    
    % Find stable offset point
    diff_vect = diff(diff( exp_obj.stimulus.timestamp_record{repeat_counter} ));
    % The first diff goes from absolute time to the difference between timestamps
    % The second diff lets us look for changes in the relative duration of each frame.
    
    diff_vect = diff_vect < stability_tolerance;        % NB: This is still in ms
    
    not_done = 1;
    ind = 1;
    consecutive_stable_frames = 0;
    
    while (not_done)
        
        ind = ind + 1;
        
        if diff_vect(ind) && diff_vect(ind-1)
            consecutive_stable_frames = consecutive_stable_frames + 1;
        else
            consecutive_stable_frames = 0;
        end
        
        if ( consecutive_stable_frames == num_stable_frames_criterion )
            offset_point = ind;
            offset_time = timestamp_record(ind) - predicted_frame_times(ind);
            not_done = 0;
            
        end
        
        if (ind == length(diff_vect))
            not_done = 0;
            display('ERROR IN ANALYZE_TIMESTAMPS! No stability in timestamps! Examine timestamp data!');
            keyboard
        end
        
    end % trying to find stability
    
    
    % Offset basic predictions
    offset_predicted_times = predicted_frame_times + offset_time;
    
    
    % Compute discrepancy vect
    discrepancy = timestamp_record - offset_predicted_times;
    
    % We will examine the discrepancy vect
    
    % Troll through data in N frame bins... Where N is a small enough number
    % that there will be now excuse to have freq mis-estimation prediction
    % drift be a problem:
    
    % The discrepancy may slope up or down due to freq mis-estimation. I
    % will look at the start and stop discrepancies and see whether there
    % is enough difference to fit in an extra frame.
    fprintf('INSPECTING TIME STAMPS: ');
    
    not_done = 1;
    chunk_size = 100;  % frames
    
    stop_frame = 0;
    no_missed_frames = 1;
    
    while( not_done )
        
        % Check for end of file and fill out next chunk accordingly
        if  (stop_frame + chunk_size) >= length(discrepancy)
            % Then we are done, the last chunk spans the remaining data
            start_frame = stop_frame + 1;
            stop_frame = length(discrepancy);
            not_done = 0;
            
        else
            start_frame = stop_frame + 1;
            stop_frame = stop_frame + chunk_size;
            
        end
        
        % Analyze current chunk of data
        start_discrepancy = discrepancy(start_frame);
        stop_discrepancy = discrepancy(stop_frame);
        
        if ( (stop_discrepancy - start_discrepancy) > (1000 / exp_obj.monitor.screen_refresh_freq) )
            fprintf('\t Putative missed frame(s) between frames %d and %d. \n', start_frame, stop_frame);
            %  discrepancy(start_frame)
            %  discrepancy(stop_frame)
            no_missed_frames = 0;
            
        end
        
        
    end  % loop through data
    
    if (no_missed_frames)
        fprintf(' No missed frames detected. \n');
    end
    
    if (exp_obj.debug_flag)
        
        
        % Now display pre-stable point data (without offset)
        figure
        plot(timestamp_record(1:(offset_point))-trep0, 'k.:');
        hold
        plot(predicted_frame_times(1:(offset_point))-trep0, 'r');
        hold
        
        maxpnt = max([ (timestamp_record(offset_point)-trep0), (predicted_frame_times(offset_point)-trep0) ]) * 1.1;
        
        tdiff1 = timestamp_record(1) - predicted_frame_times(1);
        tdiff2 = timestamp_record(offset_point) - predicted_frame_times(offset_point);
        
        xlab_str = strcat('Frame Number // Frame#1 tdiff: ',num2str(tdiff1, '%3.2f'),' [ms] // Offset point tdiff: ',num2str(tdiff2, '%3.2f'),' [ms]');
        xlabel(xlab_str);
        ylabel('Time [ms]');
        title('Startup timing from tmain0 // Black is timestamp data. // Red is predicted times.');
        
        axis([1, offset_point, 0, maxpnt]);
        
        % We also display the difference plots of the above data
        
        
        
        % Display discrepancy vect
        % This is the best way to spot dropped frames. They appear as pronounced
        % steps.
        figure
        plot( discrepancy( offset_point:exp_obj.stimulus.frames_shown ) );
        
        xlabel('Frame Number');
        ylabel('Discrepancy [ms]');
        title('Timing discrepancy: Data - Predicted (offset to 0 at offset point)');
        
        % Now histogram basic timestamp info
        % Basically for completeness.
        ts_diff_ms = diff(timestamp_record);
        
        lower_ms_lim = 0; %5;
        upper_ms_lim = max(ts_diff_ms) * 1.05; %80;
        
        % NB: If a frame stop has been used the timestamp data becomes unwieldy
        % to histogram.
        
        if (isempty( exp_obj.stimulus.stop_frame ))
            Hist_Util( ts_diff_ms, lower_ms_lim, upper_ms_lim, 1);
        else
            disp('Bypassing histogram of timestamp date because stop-frame is non-empty.');
        end
        
    end  % end debug bypass
    
end % loop through repeats


% difs = diff(timestamp_record);
% one_refresh = exp_obj.stimulus.stim_update_freq / exp_obj.monitor.screen_refresh_freq*1000;
% pred = timestamp_record(1):one_refresh:timestamp_record(end);
% pred = diff(pred);
% plot(difs)

