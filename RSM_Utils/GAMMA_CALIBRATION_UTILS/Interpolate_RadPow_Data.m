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

function[ gunval_interp, radpow_interp ] = Interpolate_RadPow_Data( gun_vals, radpow_data, N_bits )

%Nbits = 8;

gunval_interp = linspace(0,((2^N_bits)-1),(2^N_bits));

% gunval_interp = gunval_interp ./ (2^N_bits-1);

radpow_interp = interp1(gun_vals, radpow_data, gunval_interp);
