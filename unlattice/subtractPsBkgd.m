function [bkgdSubPS, bkgd1DFit]= subtractPsBkgd(PS, binSize, minRadius, bkgd1DFit)
%[bkgdSubPS, bkgd1DFit]= subtractPsBkgd(PS, binSize, minRadius, bkgd1DFit)

% subtract global average 
psCenter = fix(size(PS)./2)+1;
PS(~isfinite(PS))=0;
PS = PS - mean2( PS( psCenter(1)+minRadius:end,...
                     psCenter(2)+minRadius:end ) );

radii=1:binSize:psCenter;
if nargin < 4
% if 1D background profile is not provided, calculate it
    radAvg = radialAvg(PS,radii);
    [bkgd1DFit, ~]= fit1DProfile(radii,radAvg);
end

% Radially expand bkgd and subtract from power spectrum
bkgdImg=radialExpand1D(size(PS),binSize,bkgd1DFit);
bkgdSubPS= PS - bkgdImg;

end
