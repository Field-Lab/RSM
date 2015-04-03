function[ sync_struct ] = Set_Sync_Vertices( sync_setup_struct )

            if (sync_setup_struct.sync_pulse_flag > 0)
                % Setup for sync pulse
                sync_struct.width = sync_setup_struct.sync_pulse_width;
                sync_struct.height = sync_setup_struct.sync_pulse_height;
                w = sync_setup_struct.monitor_width;
                h = sync_setup_struct.monitor_height;
                
                switch sync_setup_struct.sync_pulse_flag,
                    
                    case 1
                        sync_struct.x_vertices = [ 0; sync_struct.width; sync_struct.width; 0];  % Lower left corner
                        sync_struct.y_vertices = [ (h - sync_struct.height); (h - sync_struct.height); h; h];

                    case 2
                        sync_struct.x_vertices = [ 0; sync_struct.width; sync_struct.width; 0];  % Upper left corner
                        sync_struct.y_vertices = [ 0; 0; sync_struct.height; sync_struct.height];

                    case 3
                        sync_struct.x_vertices = [ (w - sync_struct.width); w; w; (w - sync_struct.width)];  % Lower right corner
                        sync_struct.y_vertices = [ (h - sync_struct.height); (h - sync_struct.height); h; h];
            
                    case 4
                        sync_struct.x_vertices = [ (w - sync_struct.width); w; w; (w - sync_struct.width)];  % Upper right corner
                        sync_struct.y_vertices = [ 0; 0; sync_struct.height; sync_struct.height];
                
                    otherwise
                        fprintf('ERROR IN CONFIGURING OBJ: Illegal synch_pulse_flag value (valid entries are 1-4) \n');
                        keyboard
                            
                end 
                
                sync_struct.color = sync_setup_struct.sync_pulse.color;
                sync_struct.state = 1; % start with an initial pulse of the sync pulse color (when state = 0 the color reverts to background)

            else
                sync_struct = [];
            end