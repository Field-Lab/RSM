function[ obj ] = Edit_Mon_Obj( obj )



%         obj.monitor_name = varargin{1}.monitor_name;
       %         obj.num_lut_bits = varargin{1}.num_lut_bits;
       %         obj.gamma_model = varargin{1}.gamma_model;
       %         obj.optometer_raw_data = varargin{1}.optometer_raw_data;
       %         obj.red_table = varargin{1}.red_table;
       %         obj.green_table = varargin{1}.green_table;
       %         obj.blue_table = varargin{1}.blue_table;
       %         obj.red_params = varargin{1}.red_params;
       %         obj.green_params = varargin{1}.green_params;
       %         obj.blue_params = varargin{1}.blue_params;
       %         obj.gamma_test_date = varargin{1}.gamma_test_date;
       %         obj.width = varargin{1}.width;
       %         obj.physical_width = varargin{1}.physical_width;
       %         obj.height = varargin{1}.height;
       %         obj.physical_height = varargin{1}.physical_height;
       %         obj.screen_refresh_freq = varargin{1}.screen_refresh_freq;
       %         obj.default_mondesc_path = varargin{1}.default_mondesc_path;     
       %         obj.mon_num = varargin{1}.mon_num;
       %         obj.backgrndcolor = varargin{1}.backgrndcolor;


not_done = 1;

while (not_done)

    clc;
    fprintf('\n\n');
    fprintf('****************************************\n');
    fprintf('*  RSM Monitor Editing                 *\n');
    fprintf('****************************************\n\n');
    fprintf('Current monitor object: \n\n'); 
    obj
    fprintf('Options: \n\n'); 
    fprintf('[ 1]\t Change monitor name. \n');
    fprintf('[ 2]\t Change number lut bits. \n'); 
    fprintf('[ 3]\t Change monitor pixel width. \n'); 
    fprintf('[ 4]\t Change monitor pixel height. \n');
    fprintf('[ 5]\t Change monitor physical width [cm]. \n');
    fprintf('[ 6]\t Change monitor physical height [cm]. \n');    
    fprintf('[ 7]\t Change monitor refresh frequency [Hz]. \n');
    fprintf('[ 8]\t Change default monitor description path. \n');
    fprintf('[ 9]\t Change monitor location number. \n');
    fprintf('[10]\t Change monitor default background color. \n');
    fprintf('[11]\t Exit. \n\n');


    option = Tested_Input_NumRange( 'Enter number of option: ', 1, 11 );

    switch option
        case 1 % Change monitor name
            obj.monitor_name = input('Enter name of monitor (using single quotes): ');
            
        case 2 % Change number lut bits.
            obj.num_lut_bits = Tested_Input_NumRange( 'Enter number of bits in LUT: ', 1, 64 );
            
        case 3 % Change monitor pixel width.
            obj.width = Tested_Input_NumRange( 'Enter number of pixels across monitor width: ', 1, 20000 );
            
        case 4 % Change monitor pixel height.
            obj.height = Tested_Input_NumRange( 'Enter number of pixels across monitor height: ', 1, 20000 );
            
        case 5 % Change monitor physical width 
            obj.physical_width = Tested_Input_NumRange( 'Enter number of cm across monitor width: ', 1, 2000 );
            
        case 6 % Change monitor physical height 
            obj.physical_height = Tested_Input_NumRange( 'Enter number of cm across monitor height: ', 1, 2000 );
            
        case 7 % Change monitor refresh frequency
            obj.screen_refresh_freq = Tested_Input_NumRange( 'Enter monitor refresh frequency in Hz: ', 1, 2000 );
            
        case 8 % Change default monitor description path
            obj.default_mondesc_path = input('Enter path for monitor description (using single quotes): ');
            
        case 9 % Change monitor location number
            obj.mon_num  = Tested_Input_NumRange( 'Enter (0) = window on main screen; (1)= full main screen; (2) = full 2nd screen: ', 0, 2 );
            
        case 10 % Change monitor default back ground color.
            obj.backgrndcolor = Set_Color;
            
        case 11 % Exit
            not_done = 0;
            
    end % switch 

end % while loop
