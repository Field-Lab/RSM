function[ img_frame ] = Make_Frame_RawMovie( stim_obj )
  
        Set_Frame_Num( stim_obj );
    
        [temp, img_frame] = Read_RawMov_Frame(stim_obj.movie_filename, stim_obj.span_width, stim_obj.span_height, stim_obj.header_size, stim_obj.current_frame, stim_obj.flip_flag);
        