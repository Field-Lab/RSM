function[ color ] = Color_Test( color )

if (max(color) > 1)
    
    fprintf('RSM WARNING: CLIPPING OVER-LIMIT COLOR VALUE !');
    
    if (color(1) > 1)
        color(1) = 1;
    end
 
    if (color(2) > 1)
        color(2) = 1;
    end

    if (color(3) > 1)
        color(3) = 1;
    end

end % max test 

if (min(color) < -1)
    
    fprintf('RSM WARNING: CLIPPING UNDER-LIMIT COLOR VALUE !');
    
    if (color(1) < -1)
        color(1) = -1;
    end
 
    if (color(2) < -1)
        color(2) = -1;
    end

    if (color(3) < -1)
        color(3) = -1;
    end
    
end % max test 