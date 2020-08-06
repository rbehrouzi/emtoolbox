function [circularMask] = centricDisk(mskSize,radius) 
%MASK = CIRCULARMASK (BOXSIZE, RADIUS) Central cicular mask in box
%   msk is 2D logical array of the size defined by boxsize
%   array elements inside a central circle of radius radius are 1,
%   otherwise zero
%   mskSize is either a scalar, making msk a sqaure matrix, or
%   a vector with two elements for a rectangular msk of size 
%   [msksize(1), msksize(2)]

assert(length(mskSize)<=2);
if isscalar(mskSize)
    boxdims = [mskSize, mskSize];
else
    boxdims = mskSize;
end
boxcen = fix((boxdims)./2)+1;
[x, y]= ndgrid(1:boxdims(1), 1:boxdims(2)); %not needed in newer Matlab
circularMask = ((x - boxcen(1)).^2 + (y - boxcen(2)).^2  <= radius.^2);
end