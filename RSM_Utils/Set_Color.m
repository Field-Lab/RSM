function[ color_vect ] = Set_Color()

fprintf('\n');
fprintf('Set stimulus color. \n');
fprintf('Available presets: \n');
fprintf('\t (1) Black \t [0, 0, 0] \n');
fprintf('\t (2) White \t [1, 1, 1] \n');
fprintf('\t (3) Gray \t [0.5, 0.5, 0.5] \n');
fprintf('\t (4) Dark Gray \t [0.1, 0.1, 0.1] \n');
fprintf('\t (5) User enters values. \n \n');
            
selection = Tested_Input_NumRange('Please enter selection: ', 1, 5);
            
switch selection
                case 1,
                    color_vect = [0; 0; 0];  % NB: Due to the mglQuad command we actually want a vertical rgb vect instead of a horz.
                    
                case 2,
                    color_vect = [1; 1; 1];
                    
                case 3,
                    color_vect = [0.5; 0.5; 0.5];

                case 4,
                    color_vect = [0.1; 0.1; 0.1];
                    
                otherwise,
                    accept = 0;

                    while (~accept)

                        fprintf('\n');
                        fprintf('Values must range from 0 to 1. \n');
                        r = Tested_Input_NumRange('Enter red value: ', 0, 1);
                        g = Tested_Input_NumRange('Enter green value: ', 0, 1);
                        b = Tested_Input_NumRange('Enter blue value: ', 0, 1);
                        fprintf('\n');
                        color_vect = [r; g; b];
                        %color_vect = color_vect / 255;
        
                        accept = Tested_Input_Logical('Enter (1) to accept or (0) to reject: ');

                    end % acceptance test
               
end % switch

color_vect = Color_Test( color_vect );