function[ new_display ] = Configure_Display()

not_done = 1;
new_display = [];
no_valid_obj = 1;
no_valid_gamma = 1;

while (not_done)

    clc;
    fprintf('\n\n');
    fprintf('****************************************\n');
    fprintf('*  RSM Monitor Configuration Utility.  *\n');
    fprintf('****************************************\n');

    fprintf('Options: \n\n'); 
    fprintf('[ 1]\t Create new monitor object. \n\n'); 
    fprintf('[ 2]\t Load existing monitor object. \n\n'); 
    fprintf('[ 3]\t Edit existing monitor object. \n\n');
    fprintf('[ 4]\t Collect data for new gamma profile. \n\n');
    fprintf('[ 5]\t Visualize gamma profile. \n\n');    
    fprintf('[ 6]\t Remake gamma tables using best-fit gamma parameters. \n\n');
    fprintf('[ 7]\t Remake gamma tables using values interpolated from data. \n\n');
    fprintf('[ 8]\t Test existing gamma profile linearity. \n\n');
    fprintf('[ 9]\t Determine frame refresh frequency. \n\n');
    fprintf('[10]\t Save new monitor object. \n\n\n');
    fprintf('[11]\t Exit. \n\n\n\n');


    option = Tested_Input_NumRange( 'Enter number of option: ', 1, 11 );

    switch option
        
        case 1  % Create new monitor object
            new_display = Monitor_Obj;
            
            
        case 2  % Load existing monitor object
            monitor_description_filename = input('Enter filename of monitor description file (using single quotes and including ".mat"): ');

            %fn = cat(2, obj.default_mondesc_path, monitor_description_filename);

            new_display = load(monitor_description_filename, 'obj');
 
            
        case 3   % Edit existing monitor object
            new_display = Edit_Mon_Obj( new_display );
            
        case 4   % Collect data for new gamma profile
            new_display = Make_Gamma_Tables( new_display );
            
        case 5   % Visualize gamma profile
            
        case 6   % Remake with best-fit gamma values
            new_display = Remake_Gamma_Tables_Fit( new_display );
            
        case 7   % Remake with interpolated gamma values
            new_display = Remake_Gamma_Tables_Interp( new_display );
            
        case 8   % Test existing gamma profile
            new_display = Test_Monitor_Linearity( new_display );
            
        case 9   % Determine frame refresh freq
            new_display = Update_Monitor_Freq( new_display );
            
        case 10   % Save monitor object
            % Test for valid monitor description
            Save_Monitor_Description( new_display );

        case 11  % Exit
            % Ask for confirmation
            finish_flag = Tested_Input_Logical( 'Enter (1) to exit, (0) to return to configuration options: ' );
            if (finish_flag)
                not_done = 0;
            end % final exit
            
        otherwise
            
    end % switch on option
            
end     % while loop