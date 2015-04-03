function[ trigger_time ] = Scan_4_Trigger_Change( exp_obj )
 %
 % This is a modification of the original Scan_4_Trigger.m
 % This code is intended to detect positive and negative triggers.
 % This version uses information carried by the exp_obj to monitor the 
 % state of the line (logic high or logic low). 
 %
 % Based on this the proper test is applied to 

    
    % This is an example of a data structure returned after a switch from
    % logic high to logic low
%    mglDigIO('digin')
%
%ans = 
%
%    type: 0
%    line: 0
%    when: 1.1990e+04

not_done = 1;
    
while( not_done ) 
     
        % Read tigger channel
        trig_read_struct = mglDigIO('digin');
    
        % test input
        if (~isempty(trig_read_struct))
            
            if ( exp_obj.dio_config.daq2rsm_state == 0 )
                % We are in logic low waiting for a logic high signal
                
                trigger_sum = sum( trig_read_struct.type );
                
            else
                % Then we are in logic low waiting for a logic high signal
                trigger_sum = sum( trig_read_struct.type == 0);
            
            end % finding trigger_sum
            
            if (trigger_sum > 0)
                % We have a trigger
                trigger_time = mglGetSecs; 
                
                not_done = 0;
                
                % Now we need to update daq2rsm_state
                if ( exp_obj.dio_config.daq2rsm_state == 0 )
                    exp_obj.dio_config.daq2rsm_state = 1;
                else
                    exp_obj.dio_config.daq2rsm_state = 0;
                end % changing daq2rsm_state
                
            end %valid input test
        end  % empty input test
    
        if (not_done)
            % If not done, wait a decent buffer interval. If done just move on.
            mglWaitSecs( 1/exp_obj.dio_config.trigger_sample_rate );
        end 
    
end % while not done 

            