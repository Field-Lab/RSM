function[exp_obj] = run_RSM( exp_obj )
% run_RSM: The real action takes place in Stim_Engine. run_RSM is really
% little more than a wrapper that handles the process of going throught the
% pending_stimuli cell array. 
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)


not_done = 1;

% Now loop through stimuli pending in the queue
while( not_done )
    
    % Get the Number of stim remaining in fifo
    [num_pending_stim, first_nonempty] = Num_Nonempty( exp_obj.pending_stimuli );
    
    % Grab the first entry off the fifo
    exp_obj.stimulus = exp_obj.pending_stimuli{first_nonempty};
     
    % Now clear the entry from the pending queue
    exp_obj.pending_stimuli{first_nonempty} = [];

    [ exp_obj ] = Stim_Engine( exp_obj );

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
