function imgBkgd = radialExpand1D(imsize,binSize,bkgdFit, minRadius)
%imgBkgd = radialExpand1D(imsize,binSize,bkgdFit, minRadius)
    % 

if nargin < 4
    minRadius= 0;
end
cenx= fix(imsize(1)./2)+1;
ceny= fix(imsize(2)./2)+1;
[X, Y] = meshgrid( (1:imsize(1))-cenx, (1:imsize(2)-ceny) );
R2 = X.^2 + Y.^2;

% compute 1D background profile
radii=1:binSize:max(imsize);
bkgd1D = feval(bkgdFit, radii);

imgBkgd= zeros(imsize);
for idx = 1:length(radii) % radius of the circle
    if idx==1
        inr2 = minRadius.^2;
    else
        inr2= max( minRadius, radii(idx-1)).^2;
    end
    outr2= radii(idx).^2;
    imgBkgd( inr2 < R2 & R2 < outr2 ) = bkgd1D(idx);
end
end