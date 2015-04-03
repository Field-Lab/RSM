function Pulse_DigOut_Channel( )
% Pulse_DigOut_Channel: purpose
%
%        $Id: NAME VER_ID DATA-TIME vinje $
%      usage: NAME(Args)
%         by: william vinje
%       date: Date
%  copyright: (c) Date William Vinje, Eduardo Jose Chichilnisky (GPL see RSM/COPYING)
%
%      usage: Examples
%     inputs: None.
%    outputs: Only impacts output line on output device. 
%      calls: 
%
		

    mglDigIO('digout',0,1);         % Set default output port to high (with no latency)
            
    %mglWaitSecs(exp_obj.dio_config.outpulse_duration);             % Wait for 1ms 

    mglDigIO('digout',0,0);         % Return output port to low (with no latency)

  