function[stimulus, seq, trial_num_total] = rand_stim(stim_in)

% randomize the sequence of stimuli combination of spatial period, temporal
% peroid and direction.

% xyao 05/21/14
if (strcmp(stim_in.type, 'MG') || strcmp(stim_in.type, 'CG'))
    
    if (isfield(stim_in, 'temporal_period'))
        if (isfield(stim_in, 'spatial_period'))
            if (isfield(stim_in, 'direction'))
                if (isfield(stim_in, 'n_for_each_stim'))
                    tp = stim_in.temporal_period;
                    sp = stim_in.spatial_period;
                    dr = stim_in.direction;
                    rp = stim_in.n_for_each_stim;
                else
                   fprintf('\t RSM ERROR: repeats not recognized. Please define repeats and try again. \n');
                   return
                end
            else
               fprintf('\t RSM ERROR: direction not recognized. Please define direction and try again. \n');
               return
            end
        else
           fprintf('\t RSM ERROR: spatial period not recognized. Please define spatial period and try again. \n');
           return
        end
    else
       fprintf('\t RSM ERROR: temporal period not recognized. Please define temporal period and try again. \n');
       return
    end


    trial_num = length(tp)*length(sp)*length(dr);
    trial_num_total = trial_num*rp;
    stimulus_temp(1:trial_num) = stim_in;


    % create structure arrays with non-randomized stimuli sequence

    for i = 1:length(sp)
        for j = 1:length(tp)
            for k = 1:length(dr)
                idx = length(tp)*length(dr)*(i-1) + length(dr)*(j-1) + k;
                stimulus_temp(idx).temporal_period = tp(j);
                stimulus_temp(idx).spatial_period = sp(i);
                stimulus_temp(idx).direction = dr(k);
            end
        end
    end
elseif strcmp(stim_in.type, 'MB')
    
    if (isfield(stim_in, 'delta'))
        if (isfield(stim_in, 'bar_width'))
            if (isfield(stim_in, 'direction'))
                if (isfield(stim_in, 'n_for_each_stim'))
                    tp = stim_in.delta;
                    sp = stim_in.bar_width;
                    dr = stim_in.direction;
                    rp = stim_in.n_for_each_stim;
                else
                   fprintf('\t RSM ERROR: n_for_each_stim not recognized. Please define repeats and try again. \n');
                   return
                end
            else
               fprintf('\t RSM ERROR: direction not recognized. Please define direction and try again. \n');
               return
            end
        else
           fprintf('\t RSM ERROR: bar_width not recognized. Please define spatial period and try again. \n');
           return
        end
    else
       fprintf('\t RSM ERROR: delta not recognized. Please define temporal period and try again. \n');
       return
    end
    trial_num = length(tp)*length(sp)*length(dr);
    trial_num_total = trial_num*rp;
    stimulus_temp(1:trial_num) = stim_in;


    % create structure arrays with non-randomized stimuli sequence

    for i = 1:length(sp)
        for j = 1:length(tp)
            for k = 1:length(dr)
                idx = length(tp)*length(dr)*(i-1) + length(dr)*(j-1) + k;
                stimulus_temp(idx).delta = tp(j);
                stimulus_temp(idx).bar_width = sp(i);
                stimulus_temp(idx).direction = dr(k);
            end
        end
    end
else
      fprintf('\t RSM ERROR: The stimulus type must be Moving_Bar, Moving_Grating, or Counterphase_Grating \n');
      return

end

seq = [];

for i = 1:rp
    seq = [seq; randperm(trial_num)];
end

stimulus = stimulus_temp(seq(1, :));
if rp > 1
    for i = 2:rp
        stim_1 = stimulus(1:trial_num);
        stimulus = [stimulus stim_1(seq(i, :))];
    end
end

seq(1, :) = 1:trial_num;
seq = reshape(seq', 1, rp*trial_num);
        
end
