function[trial_switches] = Make_Trial_Switches(In_Params)

% Get number of params, n
n = size(In_Params,2);

% Initialize step_switches
trial_switches = zeros((3.^n), n);
num_trials = size(trial_switches,1);

% Make nth column
elemental_vect = [1; 0; -1];
trial_switches(:,n) = repmat(elemental_vect, (num_trials/3), 1);

% Fill out (n-1) th to 1st columns
for i = 1:(n-1),

    elemental_vect = [ones((3^i),1); zeros((3^i),1); -ones((3^i),1)];
    trial_switches(:,(n-i)) = repmat(elemental_vect, (num_trials/(3^(i+1))), 1);

end % i loop
