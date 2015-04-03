function[ cyc_per_dva ] = Convert_SF2DVA( pix_per_cyc, exp_obj )

% Note: assumes square pixels
% From  help mglVisualAngleCoordinates
% mglSetParam('visualAngleSquarePixels',1)
% 
%  What this does is set the transformation to have the same pix2deg in
%  the x and y dimension. This is useful for things like rotating a texture with
%  mglBltTexture which basically has to assume that pixels are square (i.e. it
%  does not scale the texture differently when it is oriented horizontally vs
%  vertically, for instance). If you wanted to compensate for non-square pixels
%  it would be a bit messy. So visualAngleSquarePixels defaults to 1.

% Note: "dva" is really a theoretical dva for a hypothetical observer at 57
% cm. The real importanec is pix per cyc
 

% Everything is based on width:

% Commanded cycles per screen
cyc_per_screen_w = exp_obj.monitor.width / pix_per_cyc;

% DVA per screen is simply screen size in cm (assuming 57 cm distance)
dva_per_screen_w = exp_obj.monitor.physical_width;


% goal: cycles per deg
cyc_per_dva =  cyc_per_screen_w / dva_per_screen_w;