function[ val ] = Tested_Input_NumRange( prompt_string, min_val, max_val )

valid = 0;

while (~valid)
    
    val = input(prompt_string);
    
    if (~isempty( val))

        if isnumeric( val )

            if ( (val >= min_val)&&(val <= max_val) )
        
                valid = 1;
        
            end % test for 1 or 0
        end
    end
    
    if (~valid)
        fprintf('\t Valid entries are between %d and %d. Please re-enter input. \n', min_val, max_val);    
    end
end     % while loop