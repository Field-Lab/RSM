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

function[RadPow_Predictions] = LineModel(Params, Gun_Values, N_bit_dummy)

slope = Params(1);
intercept = Params(2);

RadPow_Predictions = (slope * Gun_Values) + intercept;

