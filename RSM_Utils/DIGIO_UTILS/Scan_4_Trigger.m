function[ trigger_time ] = Scan_4_Trigger( exp_obj )
        
    not_done = 1;
    polarity = 'pos'; % for rig-c use'neg';
%    mglDigIO('digin')
%
%ans = 
%
%    type: 0
%    line: 0
%    when: 1.1990e+04

    % First we clear out any stored events crud
    trig_read_struct = mglDigIO('digin');

    clear trig_read_struct;

    while( not_done ) 
     
        % Read tigger channel
        trig_read_struct = mglDigIO('digin');
    
        % test input
        if (~isempty(trig_read_struct))
            
            if strcmp(polarity, 'pos')
                
                trigger_sum = sum( trig_read_struct.type );
                
            else
                % Then we are in neg polarity case
                trigger_sum = sum( trig_read_struct.type == 0);
            
            end % finding trigger_sum
            
            if (trigger_sum > 0)
        
                trigger_time = mglGetSecs; %trig_read_struct.when;
                
                not_done = 0;
                
            end %valid input test
        end  % empty input test
    
        if (not_done)
            % If not done, wait a decent buffer interval. If done just move on.
            mglWaitSecs( 1/exp_obj.dio_config.trigger_sample_rate );
        end 
    
    end % while not done 

            