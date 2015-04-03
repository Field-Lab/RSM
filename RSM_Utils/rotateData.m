function [xr,yr] = rotateData(x,y,xo,yo,theta)
%[XR,YR] = rotateData(X,Y,X0,Y0,THETA)
%
%   Rotate coordinates especified by [X,Y] around the point [X0,Y0], by an
%   angle (in radians) defined by THETA and to the clockwise direction. 
%


%-- Make sure we have row vectors
x = x(:)';
y = y(:)';

%-- Bring vectors to rotation origin
X = x-xo;
Y = y-yo;

%-- Define rotation matrix

r = [cos(theta) sin(theta); -sin(theta) cos(theta)];
 
%-- Define outputs
XYr = r*[X;Y];
xor = XYr(1,:);
yor = XYr(2,:);

xr = xor+xo;
yr = yor+yo;
