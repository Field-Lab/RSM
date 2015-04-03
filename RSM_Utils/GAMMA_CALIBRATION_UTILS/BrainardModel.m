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

function[RadPow_Predictions] = BrainardModel(Params, Gun_Values, N_bits)

% Based on eqt. 16 from Brainard, Pelli & Robson

gamma = Params(1);
thresh = Params(2);
%alpha = Params(3);

%N_bits = 8;

gun_rez = 2^N_bits;

RadPow_Predictions = (Gun_Values - thresh) ./ (gun_rez - thresh);

% Now we ensure compliance with eqt 16
mask_vect = Gun_Values > thresh;
%equivalently: mask_vect = RadPow_Predictions > 0;  

RadPow_Predictions = RadPow_Predictions .* mask_vect;

RadPow_Predictions = ( RadPow_Predictions .^ gamma );
