function[ ] = Hist_Util( ts_diff_ms, lower_ms_lim, upper_ms_lim, log_flag)

figure

bin_cens = linspace(lower_ms_lim, upper_ms_lim, (upper_ms_lim - lower_ms_lim)*10);    % 0.1 ms bins  

bin_cens = bin_cens + 0.05; % so bin centers are shifted to be centers of the 0.1 ms bins


tsd_N = hist( ts_diff_ms, bin_cens );


if (log_flag)
    nonzero_ind = find(tsd_N > 0);
    ones_ind = find(tsd_N == 1);

    tsd_N(nonzero_ind) = log10( tsd_N(nonzero_ind) );
    
    tsd_N(ones_ind) = (log10(2) / 2) * ones(size(ones_ind));
end


bar( bin_cens, tsd_N, 1, 'b');

ti_str = strcat('Timestamp Differences: <mean> = ',num2str( mean(ts_diff_ms) ),' [ms]' );
title(ti_str);
xlabel('[ms]');

if (log_flag)
    ylabel('log10[ Count ] +');
else
    ylabel('Count');
end


hold


maxplot = max( tsd_N );

axis([lower_ms_lim, upper_ms_lim, 0, (1.1* maxplot)]);

hold