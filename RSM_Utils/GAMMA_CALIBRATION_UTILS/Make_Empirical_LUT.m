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
% assumes radpow data has been conditioned from zero to 1.
% This scheme works because the gun vals map onto 0 to 1. The algorithm
% first sets the LUT value to the effective gun value needed to produce the
% closest match to radiant power level. Then at the end we normalize the
% LUT to a range from 0 to 1. 

function[ empirical_lut ] = Make_Empirical_LUT( gun_vals, radpow_data )

num_entries = length( gun_vals );

linear_vals = linspace(0, 1, num_entries);

empirical_lut(1) = 0; % 1; was set to this during pre-release debug

for i = 2:(num_entries-1),
    
   mark = linear_vals(i);
   
   above_mark = find( radpow_data > mark ); % each of these is a list of indices in vector form
   below_mark = find( radpow_data < mark );
   
   if ( ~isempty(above_mark) )   
        above_diff = radpow_data( above_mark(1) ) - mark;
   else
       above_diff = inf; % invalidate this option
   end
   
   
   if ( ~isempty(below_mark) )
        below_diff = mark - radpow_data( below_mark(length(below_mark)) );
   else
       below_diff = -inf;
   end
   
   
   if ( abs( above_diff ) < abs( below_diff ) )
       % Then the above mark value was a better estimate of the mark
        empirical_lut( i ) = above_mark(1);
       
   else
       empirical_lut( i ) = below_mark(length(below_mark));
       
   end % test for above versus below entry
    
end  % loop through entries

empirical_lut(num_entries) = num_entries;

empirical_lut = empirical_lut ./ num_entries;