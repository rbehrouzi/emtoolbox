function [centricEllipticalMask] = centricDisk(mskSize,radius) 
%
%
%


assert(length(mskSize)<=2);
if isscalar(mskSize)
    mskSize = [mskSize, mskSize];
end
if isscalar(radius)
    radius= [radius, radius];
end
mskCenter = fix((mskSize)./2)+1;
[x, y]= ndgrid(1:mskSize(1), 1:mskSize(2)); %not needed in newer Matlab
centricEllipticalMask = (((x - mskCenter(1))./radius(1)).^2 + ((y - mskCenter(2))./radius(2)).^2  <= 1);
end