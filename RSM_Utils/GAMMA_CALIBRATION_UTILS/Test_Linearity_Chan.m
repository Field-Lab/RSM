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
%   .gun_vals
%   .avgraw_radpow_data
%   .slope
%   .intercept
%   .final_fit_stat


function[ channel_S ] = Test_Linearity_Chan( optometer_raw_data, color_chan, Model, N_bits)


[channel_S.gun_vals, channel_S.avgraw_radpow_data] = Average_RadPow_Data( optometer_raw_data, color_chan );


[channel_S.slope, channel_S.intercept, channel_S.final_fit_stat] = Fit_Line_RadPow(channel_S.gun_vals, channel_S.avgraw_radpow_data, Model, N_bits);

