function duration = calc_mb_duration(exp_obj)

pending_stim = exp_obj.pending_stimuli;
for i = 1:length(pending_stim)
    duration_trial(i) = ceil(pending_stim{i}.frames);
end
duration = ceil(sum(duration_trial)/exp_obj.monitor.screen_refresh_freq);

end