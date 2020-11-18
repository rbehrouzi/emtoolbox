function val2D = radialExpand1D( radii, val1D , imsize , minRadius)
%val2D = radialExpand1D( val1D, imsize, binSize, minRadius)
    % 

if nargin < 4
    minRadius= 0;
end
center= floor((imsize+1)./2);
[X,Y]= meshgrid((1:imsize(2))-center(2), ...
                (1:imsize(1))-center(1));
R2 = X.^2 + Y.^2;
val2D= zeros(imsize);
for idx = 1:length(radii) % radius of the circle
    if idx==1
        inr2 = minRadius.^2;
    else
        inr2= max( minRadius, radii(idx-1)).^2;
    end
    outr2= radii(idx).^2;
    val2D( inr2 < R2 & R2 < outr2 ) = val1D(idx);
end
end