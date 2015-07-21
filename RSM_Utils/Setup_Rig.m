% Setup_Rig: To initialize a data structure used to configure the overall
% exp_obj. Important information exists here. 
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)

%      usage: Called once by Start_RSM.
%     inputs: User set values. 
%    outputs: exp_session (not to be confused with exp_obj). This is a data
%    structure used to pass information to the exp_obj constructor method. 
%      calls:
%
%
%

function[ exp_session ] = Setup_Rig

home_dir_base = '/Users/local-admin/Documents/RSM';

% Setup for experimental session constructor

disp('EJC: key globals being assigned in Setup_Rig.m')
exp_session.home_dir_name = home_dir_base;
exp_session.monitor_dir_name = fullfile(home_dir_base, 'RSM_Monitors');
exp_session.log_file_dir = fullfile(home_dir_base, 'RSM_Log_Files');
exp_session.movie_path = fullfile(home_dir_base, 'RSM_Movie_Vault');
exp_session.prerun_path = fullfile(home_dir_base, 'RSM_Utils/RAWMOV_UTILS');
exp_session.map_path = fullfile(home_dir_base, 'RSM_Map_Vault');

%exp_session.home_dir_name = '/Users/wvinje/documents/RSM';
% exp_session.monitor_filename = 'monitor_OLED.mat';
exp_session.monitor_filename = 'monitor_description_USC_OLED_A_10-Oct-2014.mat';
% exp_session.monitor_filename = 'monitor_test.mat';
%exp_session.monitor_filename = 'Sony_Multiscan200ES_4148279.mat';  % 800 x 600 @100 Hz
%exp_session.monitor_filename = 'Sony_Multiscan200ES_4148279_60_640_480.mat';


% DOESN'T BELONG HERE
exp_session.session_name = 'Foobar';

exp_session.session_fn = 'Foobar';

exp_session.session_diary_fn = 'FoobarDiary';

diary( cat(2, exp_session.log_file_dir, '/', exp_session.session_diary_fn) );


% Next we query for the hostname of system
[ret, host_name] = system('hostname');   

if ( ret ~= 0 ),
   if ( ispc )
      host_name = getenv('COMPUTERNAME');
      fprintf('\t WARNING: Hostname %s to be a PC. RSM not yet tested for pc. \n', host_name);
      fprintf('\t DO NOT PASS GO. DO NOT COLLECT PHYSIOLOGY DATA. \n');

   else      
      host_name = getenv('HOSTNAME');      
   end
end

    disp('EJC: hardcoded host and rig in Setup_Rig.m');
    exp_session.host_name = 'alligator';
    exp_session.rig_ID = 'A';
   
    disp('EJC: hardcoded monitor path in Setup_Rig.m');
    
    monitor_load_fn = cat(2, exp_session.monitor_dir_name, '/', exp_session.monitor_filename);
    
    monitor_obj = load( monitor_load_fn, 'obj' );
    

    if (isempty( monitor_obj ))
        disp('ERROR: No valid monitor_description loaded');
        keyboard
        
    else
        exp_session.monitor = monitor_obj;
        
    end
    
% This option is for beta testing and debugging. Eventually final versions
% willhave only one choise of RNG generator
exp_session.mex_rng_flag = 1;       % 1 => mex file based RNG / 0 => Matlab randstream


% Now echo hostname and rig
fprintf('\nConfigured for host: %s // Rig ID: %s \n', exp_session.host_name, exp_session.rig_ID);