function[ sync_struct ] = Set_Sync_Vertices2( stimuli, mon_w, mon_h, color )

if (( stimuli.interval_sync_xend > mon_w ) || ( stimuli.interval_sync_yend > mon_h ))
    fprintf('\t RSM ERROR: Sync pulse endpoint(s) exceeds monitor limits. \n');
    return  
end
                
%x1   x2  x2  x1
%y1   y1  y2  y2

sync_struct.x_vertices = [ stimuli.interval_sync_xstart; stimuli.interval_sync_xend; stimuli.interval_sync_xend; stimuli.interval_sync_xstart ];  % Lower left corner
sync_struct.y_vertices = [ stimuli.interval_sync_ystart; stimuli.interval_sync_ystart; stimuli.interval_sync_yend; stimuli.interval_sync_yend ];

sync_struct.color = color;
sync_struct.state = 1; % start with an initial pulse of the sync pulse color (when state = 0 the color reverts to background)
