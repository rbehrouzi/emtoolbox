function [msk] = centerCircMask(boxsize,radius) 
%MASK = CIRCULARMASK (BOXSIZE, RADIUS) Central cicular mask in box
%   msk is 2D logical array of the size defined by boxsize
%   array elements inside a central circle of radius radius are 1,
%   otherwise zero
%   boxsize is either a scalar, making msk a sqaure matrix, or
%   a vector with two elements for a rectangular msk of size 
%   [boxsize(1), boxsize(2)]
assert(length(boxsize)<=2);
if isscalar(boxsize)
    boxdims = [boxsize, boxsize];
else
    boxdims = boxsize;
end
boxcen = fix((boxdims)./2)+1;
[x, y]= ndgrid(1:boxdims(1), 1:boxdims(2)); %not needed in newer Matlab
msk = ((x - boxcen(1)).^2 + ...
       (y - boxcen(2)).^2  ...
        <= radius.^2);
end

