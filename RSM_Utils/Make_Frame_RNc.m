function[ texture, img_frame_RNc] = Make_Frame_RNc(field_width, field_height, multiplier, img_frame_RNc, r_stream)
%-----------------------------------------
% Example stim script
%
% This is for a random noise stim with colored stixels (RNc)
% each stixel is part of a matlab matrix that gets dumped to a mgl texture
% call
%

img_frame_RNc(1:3,:,:) = uint8( floor( rand( r_stream, [3, field_width, field_height] ) * (256 * multiplier) ) );
    
texture = mglCreateTexture( img_frame_RNc, [], 0, {'GL_TEXTURE_MAG_FILTER','GL_NEAREST'} );

