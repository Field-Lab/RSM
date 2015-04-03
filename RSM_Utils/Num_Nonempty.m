function[ num_nonempty, first_nonempty ] = Num_Nonempty( ca ) 
% Num_Nonempty: A simple utility for counting the number of non-empty
% entries in the cell array of pending stimuli. 
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)

% ca is any cell array

len = length(ca);

num_nonempty = 0;
first_nonempty = [];

for i = 1:len,
    
    if (~isempty(ca{i}))
        num_nonempty = num_nonempty + 1; 
        
        if (isempty( first_nonempty ))
            first_nonempty = i;
        end % first 
        
    end % num increment
    
end % loop through CA