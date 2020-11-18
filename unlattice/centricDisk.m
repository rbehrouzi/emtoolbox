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
[X,Y]= meshgrid(1:maskSize(1)- boxCenter(1),...
              1:maskSize(2)- boxCenter(2));
R2= X.^2 + Y.^2;
r2 =radius.^2;
centricEllipticalMask = ( R2./r2(1) + R2./r2(2) <= 1.0 );

end