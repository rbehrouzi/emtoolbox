function [bkgdSubPS, bkgd1DFit]= subtractPsBkgd(PS, binSize, minRadius, bkgd1DFit)
%[bkgdSubPS, bkgd1DFit]= subtractPsBkgd(PS, binSize, minRadius, bkgd1DFit)


if nargin < 4
% if 1D background profile is not provided, calculate it
    psCenter = floor((size(PS)+1)./2);
    radii=1:binSize:psCenter; 
    radAvg = radialAvg(PS,radii);
    [bkgd1DFit, ~]= fit1DProfile(radii,radAvg, minRadius);
end

% compute 1D background profile
imsize=  size(PS);
cen= floor((max(imsize)+1)./2);
radii=1:binSize:max(cen);
bkgd1D = feval(bkgd1DFit, radii);

% Radially expand bkgd and subtract from power spectrum
bkgdImg=radialExpand1D(radii, bkgd1D, imsize);
bkgdSubPS= PS - bkgdImg;

end
