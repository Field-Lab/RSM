function[] = CS( )

% Reset to screen coords (in case something got switched out of
% screencoords (ie moving gratings)
mglScreenCoordinates();
mglClearScreen([0.5, 0.5, 0.5]);
mglFlush();

%fprintf('\n');
%fprintf('FLUSHING CURRENT STIM W/O SAVE \n');

    
fprintf('\n');
fprintf('Ready to resume previous queue; "Stop_RSM" to quit. \n');

    