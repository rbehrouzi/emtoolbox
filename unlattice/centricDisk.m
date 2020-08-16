function [centricEllipticalMask] = centricDisk(maskSize,radius) 
%
%
% TODO: make it for n dimensional

if isscalar(maskSize)
    if isscalar(radius) 
        %create circle in square mask
        radius= [radius, radius];
        maskSize = [maskSize, maskSize];
    else
        maskSize = repmat(maskSize,1,length(radius));
    end
else
    if isscalar(radius)
        radius = repmat(radius,1,length(maskSize));
    else
        assert( length(maskSize) == length(radius) );
    end
end

boxCenter = fix(maskSize./2)+1;
[x,y]= ndgrid(1:maskSize(1), 1:maskSize(2));
centricEllipticalMask = ( ((x - boxCenter(1))./radius(1)).^2 + ...
                          ((y - boxCenter(2))./radius(2)).^2  ...
                          <= 1.0 );

end