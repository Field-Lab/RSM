function[ lut_vector, lut ] = Set_Lut_BW( color_vect,  backgrndcolor_vect)

 
lut =     [ 1, 1, 1;...             //0
                1, 1, 1;...
                1, 1, 1;...             
                1, 1, 1;...             // 3 
                -1, -1, -1;...             
                -1, -1, -1;...
                -1, -1, -1;...
                -1, -1, -1];...             
           
            
            
            
                     
lut(:,1) = lut(:,1) * color_vect(1);     
lut(:,2) = lut(:,2) * color_vect(2);    
lut(:,3) = lut(:,3) * color_vect(3);                    
            
lut(:,1) = lut(:,1) + backgrndcolor_vect(1);
lut(:,2) = lut(:,2) + backgrndcolor_vect(2);
lut(:,3) = lut(:,3) + backgrndcolor_vect(3);

 
lut = 255 * lut;    % NB: This cannot be converted to 0 to 1
                        % The reason is that these LUT values get directly
                        % read into the texture input as uint values
                        % Any replacement has to be with uint8 values. 

% Now we make the lut vector

lv_i = 0;

for i = 1:8,
   
    for j = 1:3,
        
        lv_i = lv_i + 1;
        lut_vector(lv_i) = lut(i,j);
    
    end
end
    
    
