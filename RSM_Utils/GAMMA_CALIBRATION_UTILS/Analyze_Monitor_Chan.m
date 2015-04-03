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


function[ channel_S ] = Analyze_Monitor_Chan( optometer_raw_data, color_chan, Model, N_bits )
%lut_fit, lut_interp
% Model is handle to model functionin use

channel_S.color_chan = color_chan;
%channel_S.background_radpow; % Due to the averaging algorithm this returned value will be the same for all channels

%channel_S.avgraw_radpow_data; 
%channel_S.adjusted_radpow_data

%channel_S.raw_gunvals;


%channel_S.finegrain_gunvals; 
%channel_S.interp_radpow_data;

%channel_S.fit_gamma;
%channel_S.fit_thresh;
%channel_S.fit_stat_final;
%channel_S.fit_radpow_data;

%channel_S.interp_lut
%channel_S.fit_lut

[gun_vals, channel_S.avgraw_radpow_data] = Average_RadPow_Data( optometer_raw_data, color_chan );


% Next pre-processing step
% Subtract background level
channel_S.background_radpow = channel_S.avgraw_radpow_data( gun_vals == 0 );    % There should be only one entry

channel_S.adjusted_radpow_data = channel_S.avgraw_radpow_data - channel_S.background_radpow;


% Next step
% Scale so that top of curve is 1 
max_lum = max( channel_S.adjusted_radpow_data );

channel_S.adjusted_radpow_data = channel_S.adjusted_radpow_data ./ max_lum;


channel_S.raw_gunvals = gun_vals;


% First we use matlab's interp1 function to fill out an empirical LUT
[ channel_S.finegrain_gunvals, channel_S.interp_radpow_data ] = Interpolate_RadPow_Data( gun_vals, channel_S.adjusted_radpow_data, N_bits );

[ channel_S.interp_lut ] = Make_Empirical_LUT( channel_S.finegrain_gunvals, channel_S.interp_radpow_data );


% Now we use our fit utils to fit a gamma function to the data.
% Note that this fitting assumes we have background subtracted the zero
% level luminance, and normalized each max gun value to 1.
% The reference is: 
% Display Characterization
%   David H Brainard
%   Denis G Pelli
%   Tom Robson
[channel_S.fit_gamma, channel_S.fit_thresh, channel_S.fit_stat_final] = Fit_PreProcced_RadPow_Curve( gun_vals, channel_S.adjusted_radpow_data, Model, N_bits);


[channel_S.fit_radpow_data] = Model( [channel_S.fit_gamma, channel_S.fit_thresh], channel_S.finegrain_gunvals, N_bits);


[ channel_S.fit_lut ] = Make_Empirical_LUT( channel_S.finegrain_gunvals, channel_S.fit_radpow_data );
