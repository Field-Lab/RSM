
%--------------------------------------------------------------------------%
% LSS Routine for Use as model TS
%--------------------------------------------------------------------------%

function[LSS] = FitStat(model, data, auxillary_info)

% NB: Assumes that the model and data have identical dimensionality  

% NB: THe auxillary_info field is just a placeholder

LSS = sum( (model - data).^2 );

% To improve fitting performance I am taking the natural log of both model and data
% This should cast gamma as an effective slope term.

 %       LSS = sum( (safelog(model) - safelog(data)).^2 );
        
        
        
function[output] = safelog(input)
 
% The idea is to take a logarithm without blowwing up at zero.
% At this point I will simply THROW OUT all data where things are zero!

counter = 1;

for i = 1:length(input),
    
       if (input(i) ~= 0),
           output(counter) = input(i);
           counter = counter + 1;
       end  % if then
end      % for loop
keyboard