function[ img_frame ] = Make_Frame_RawMovie( stim_obj )
  
if (stim_obj.reverse_flag == 1) % reverse mode
    stim_obj.current_frame = stim_obj.last_frame - stim_obj.frames_shown;
else % forward mode
    stim_obj.current_frame = stim_obj.first_frame + stim_obj.frames_shown;
end

[temp, img_frame] = Read_RawMov_Frame(stim_obj.movie_filename, stim_obj.span_width, stim_obj.span_height, stim_obj.header_size, stim_obj.current_frame, stim_obj.flip_flag);
        