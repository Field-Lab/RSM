function[ color ] = Color_Test( color )

% ATH version, 07-2015
if (abs(color) > 1)
    fprintf('RSM WARNING: CLIPPING OUT-OF-LIMIT COLOR VALUES !');
    color(color>1) = 1;
    color(color<0) = 0; % here I assume the color range is [0,1]; in Bill's version below it's [-1,1] but in other places it's [0, 1].
end

% Bill's version
% if (max(color) > 1)
%     
%     fprintf('RSM WARNING: CLIPPING OVER-LIMIT COLOR VALUE !');
%     
%     if (color(1) > 1)
%         color(1) = 1;
%     end
%     
%     if (color(2) > 1)
%         color(2) = 1;
%     end
%     
%     if (color(3) > 1)
%         color(3) = 1;
%     end
%     
% end % max test
% 
% if (min(color) < -1)
%     
%     fprintf('RSM WARNING: CLIPPING UNDER-LIMIT COLOR VALUE !');
%     
%     if (color(1) < -1)
%         color(1) = -1;
%     end
%     
%     if (color(2) < -1)
%         color(2) = -1;
%     end
%     
%     if (color(3) < -1)
%         color(3) = -1;
%     end
%     
% end % max test