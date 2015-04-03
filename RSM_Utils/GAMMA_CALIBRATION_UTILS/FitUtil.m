function[final_params, final_fit_stat, num] = FitUtil(In_Params, Min_Step_Sizes, Max_Step_Sizes, Tol, Mode, Auxillary_Info, Data, V, Model, N_bits)
% 
%   EVERYTHING IS VECTORIZED
%   final_params, In_Params, & step sizes
%
% 
% INPUT INFORMATION:
% Tol:      This is the tolerance for the test statistic
% Mode:     This specifies whether fixed or adaptive step sizes are used
% Auxillary_Info: This is essentially an open slot designed to allow useful data to be sent to the model and test stat.
%                   It might be a simple vector of independent variable values (such as the x-axis data in a simple
%                   'fit the y-values' kinda problem OR it might be a complicated data structure.
% Data:     Duh, beavis! (Although note, the Model routine does not have access to this variable).
% V:        Verbose flag, 1 gets you goodies
%
%
%
Div = 10;     % sets adaptive scaling
%------------------------------------------------------------------------------
% Set up for running fit
%------------------------------------------------------------------------------

% Set 1: Get the trial_switch
[trial_switches] = Make_Trial_Switches(In_Params);

% Set 2: Determine mode
  
  if (Mode == 'Fixed'),
      trial_steps_mat = Fixed_Trial_Steps(Min_Step_Sizes, trial_switches);
      [final_params, final_fit_stat, num] = RunFit(In_Params, trial_steps_mat, Auxillary_Info, Tol, Data, V, Model, N_bits);

  else	% Mode = Adaptive
      current_step_sizes = Max_Step_Sizes;
      current_params = In_Params;
      num = 0;      
      trial_steps_mat = Fixed_Trial_Steps(current_step_sizes, trial_switches);

      while (current_step_sizes ~= Min_Step_Sizes),

	  [new_params, fit_stat, current_num] = RunFit(current_params, trial_steps_mat, Auxillary_Info, Tol, Data, V, Model, N_bits);
	  num = num + current_num;
	  current_params = new_params;
	  [trial_steps_mat, current_step_sizes] = Adaptive_Trial_Steps(Min_Step_Sizes, trial_switches, current_step_sizes, Div);
   
     end   % Adaptive loop
      
    % Run one last time w/ min step sizes
    trial_steps_mat = Fixed_Trial_Steps(Min_Step_Sizes, trial_switches);
    [final_params, final_fit_stat, current_num] = RunFit(current_params, trial_steps_mat, Auxillary_Info, Tol, Data, V, Model, N_bits);
    num = num + current_num;  
  
  end % mode control
      

%-----------------------------------------------------------------------------------------------
% Set up the trial_steps_mat
%-----------------------------------------------------------------------------------------------
function[trial_steps_mat] = Fixed_Trial_Steps(Step_Sizes, Trial_Switches)

    num_trials = size(Trial_Switches, 1);
    steps_mat = repmat(Step_Sizes, num_trials, 1);
    trial_steps_mat = steps_mat .* Trial_Switches;



%-----------------------------------------------------------------------------------------------
% Adaptively scale the step sizes and set up the trial_steps_mat
%-----------------------------------------------------------------------------------------------
function[trial_steps_mat, new_step_sizes] = Adaptive_Trial_Steps(Min_Step_Sizes, Trial_Switches, Old_Step_Sizes, Div)

% First we find the new step sizes
    num_params = size(Trial_Switches,2);
    new_step_sizes = zeros(1, num_params);

    for i = 1:num_params,

	new_step_sizes(i) = Old_Step_Sizes(i) / Div;
	if (new_step_sizes(i) <= Min_Step_Sizes(i)),	      % If step size goes below minimum stop adapting it
	    new_step_sizes(i) = Min_Step_Sizes(i);
	end   % if loop

    end	      % loop through parameters

% Then we make the trial_steps_mat
    num_trials = size(Trial_Switches, 1);
    steps_mat = repmat(new_step_sizes, num_trials, 1);
    trial_steps_mat = steps_mat .* Trial_Switches;





%-----------------------------------------------------------------------------------------------
% Actually Run the Fit
%-----------------------------------------------------------------------------------------------
function[final_params, final_fit_stat, num] = RunFit(Initial_Params, Trial_Steps_Mat, Auxillary_Info, Tolerance, Data, V, Model, N_bits)

% This stage of the code assumes a fixed step size in all parameters
% THe steps availible are represented in Trial_Steps_Mat

%Get inital estimate of fitstat
  [delta_params, fit_stat_new] = Step(Initial_Params, Trial_Steps_Mat, Auxillary_Info, Data, Model, N_bits);
  	
  params = Initial_Params + delta_params;
  fit_stat_old = fit_stat_new + 1E10;
  num = 1;	

  if (V == 1),	    % Then verbose
      figure
      plot(Auxillary_Info, Data, 'ko');
      hold
      mod = Model(params, Auxillary_Info, N_bits);
      plot(Auxillary_Info, mod, 'r');
      hold
      drawnow
   end

  runflag = 1;
	
% Go down gradient until a LOCAL minima in fit statistic is reached
	
  while  (runflag == 1),

    % Determine whether fit is done
    if (fit_stat_new >= fit_stat_old),
	runflag = 0;			  % Fit is done end fit
    end
    
    if ((fit_stat_old - fit_stat_new) < Tolerance),
	runflag = 0;			  % Fit is no longer improving significantly, end fit
    end

    if (runflag == 1),			  % find next step and take it.
   
      fit_stat_old = fit_stat_new;
      % Find the next step
      [delta_params, fit_stat_new] = Step(params, Trial_Steps_Mat, Auxillary_Info, Data, Model, N_bits);
      num = num + 1;
  
      % Take the next step	
      params = params + delta_params;
      			
      if (V == 1),
	plot(Auxillary_Info,Data, 'ko');
	hold
	mod = Model(params, Auxillary_Info, N_bits);
	plot(Auxillary_Info,mod, 'r');
	hold
	drawnow
     end % Verbose

    end % take next step test
		
  end;	% While loop

% Fit completed, output parameters	
  final_params = params;	
  final_fit_stat = fit_stat_new;

%------------------------------------------------------------------------------
function[delta_params, fit_stat_new] = Step(Params, Trial_Steps_Mat, Auxillary_Info, Data, Model, N_bits)
%------------------------------------------------------------------------------

% The key to remember is that each row contains the parameters for the trial in 
% question

% Set up results array
num_trials = size(Trial_Steps_Mat, 1);
results = zeros(num_trials,1);
	
% Find the trial parameter values
Params_Mat = repmat(Params, num_trials, 1);
Trial_Params = Trial_Steps_Mat + Params_Mat;

% Run the trials
for i = 1:num_trials,

    [model_out] = Model(Trial_Params(i,:), Auxillary_Info, N_bits);
    results(i) = FitStat(model_out, Data, Auxillary_Info);

end	    % Run loop

% Sort
[sorted_results, index] = sort(results);

% Extract delta_params	    Choose the smallest value of the fit statistic
delta_params = Trial_Steps_Mat(index(1), :);
 
fit_stat_new = sorted_results(1);
	


