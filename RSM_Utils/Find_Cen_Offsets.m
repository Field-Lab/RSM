function[ pix_cen_offset ] = Find_Cen_Offsets( pix_start, pix_end, screen_span )

% pix_start, pix_end might be reversed
stim_span = abs(pix_end - pix_start);

stim_half_span = stim_span / 2;

screen_half_point = screen_span / 2;

pix_cen_offset = round(min(pix_start, pix_end) + stim_half_span) - screen_half_point;
  