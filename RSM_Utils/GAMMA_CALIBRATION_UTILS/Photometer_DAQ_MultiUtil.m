% NAME: Role
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%    purpose: Role
%      usage: Examples
%
%

function[ data_out ] = Photometer_DAQ_MultiUtil( obj, levels, grayscale_flag )
fprintf('****************************************\n');
fprintf('Photometer Stimulus Presentation Utility\n');
fprintf('****************************************\n');
fprintf('\n');
fprintf('Pre-supported Optometer protocols:\n');
fprintf('\t (1)Graseby 350 Linear/Log Optometer \n\n');

not_done = 1;
while (not_done),
    selection = input('Enter optometer selection: ');
    not_done = 0;
                 
    switch selection
                     
        case 1,
            optometer_protocol_CA{1} = 'Is Auto-Zero mode set?          (1) to confirm: ';
            optometer_protocol_CA{2} = 'Is Slow Integration Mode set?   (1) to confirm: ';
            if (grayscale_flag)
                optometer_protocol_CA{3} = 'Grayscale data: Set power mult to 10^1?      (1) to confirm: ';
            else
                optometer_protocol_CA{3} = 'Is power mult set to 10^0?      (1) to confirm: ';
            end

        otherwise,
            disp('Please configure your optometer properly.');
            optometer_protocol_CA = [];
                     
    end % switch on stim choice
                 
end % while loop to select valid optometer

% Review protocol

if (~isempty( optometer_protocol_CA ))
    for op = 1:length( optometer_protocol_CA ),

        fprintf('\t');
        [ val ] = Tested_Input_Logical( optometer_protocol_CA{op} );
    
    end % loop through protocol review
end


w = obj.width;
h = obj.height;
                        
x_vertices = [0; w; w; 0];
y_vertices = [0; 0; h; h];

not_done = 1;
data_out = [];
data_index = 0;
if (grayscale_flag == 1)
    max_levels = floor(length(levels) / 3);
else
    max_levels = length(levels);    
end

fprintf('\n');
fprintf('** Commencing Monitor Data Collection **\n');


while( not_done ),
    level_index = 0;

    for gun_color = 1:3,
                
        % Loop through the various gun levels
        for i = 1:max_levels,
        
            level_index = level_index + 1;
            level = levels(level_index);
            
            % Set the colors'
            if (grayscale_flag == 1)
                color = [level; level; level];
                
            else
                switch gun_color, 
        
                    case 1 % red
                        color = [level; 0; 0];

                    case 2 % green
                        color = [ 0; level; 0];

                    case 3 % blue
                        color = [0; 0; level];

                end % switch
            end   % grayscale bypass

            mglQuad(x_vertices, y_vertices, color, 0); 
            
            mglFlush();
         
            % Collect the data
            fprintf('Gun level: %3.2f \t//\t', level );
            power = Tested_Input_NumRange('Enter power reading: ', 0, 1000); %input('Enter power reading: ');
        
            % Fill out the data_out
            data_index = data_index + 1;
            data_out(data_index,:) = [color', power];
        
        end % loop through levels
        
        if (~grayscale_flag)
            level_index = 0;
        end
    
    end     % loop through guns

    %Collect another repetition?
    not_done = Tested_Input_Logical('Enter (1) to collect another repetition or (0) to exit data acquisition: ');
    
end     % rep loop

fprintf('**  Monitor Data Collection Completed **\n');

%Display_Monitor_Data( data_out );
