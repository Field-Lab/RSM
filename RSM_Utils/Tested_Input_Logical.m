function[ val ] = Tested_Input_Logical( prompt_string )
% Tested_Input_Logical: to allow entry of 1 or 0 while not crashing if
% other data is entered. 
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%
%     inputs: A string that askes a prompt questions.
%    outputs: val = 1 or 0.
%      calls: None. 
%

valid = 0;

while (~valid)
    
    val = input(prompt_string);

    if (~isempty( val ) )
        
        if isnumeric( val )

            if ( (val == 0)||(val == 1) )
        
                valid = 1;
        
            end % test for 1 or 0
        end
    end
    
    if (~valid)
        fprintf('\t Valid entries are 0 or 1. Please re-enter input. \n');    
    end
end     % while loop