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

function[ ] = Display_Monitor_Data( optometer_raw_data )


[ red_gunvals, red_data ] = Average_RadPow_Data( optometer_raw_data, 'r' );
[ green_gunvals, green_data ] = Average_RadPow_Data( optometer_raw_data, 'g' );
[ blue_gunvals, blue_data ] = Average_RadPow_Data( optometer_raw_data, 'b' );


figure
plot(red_gunvals, red_data, 'r.');
hold
plot(green_gunvals, green_data, 'g.');
plot(blue_gunvals, blue_data, 'b.');
hold

xlabel('Gun Values');
ylabel('Radiant Power');
title('Gun Transfer Function');

max_gunval = max([max(red_gunvals), max(green_gunvals), max(blue_gunvals)]);

max_val = max([max(red_data), max(green_data), max(blue_data)]);

axis([-0.05, 1.05, 0, 1.05*max_val]);
