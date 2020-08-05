function [msk, msk_filtered] = maskAboveThreshold(img,maskParams, pixA)
%MASKABOVETHRESHOLD 
% masked values are 1, other regions 0
%

%TODO:fix centricDisk to produce non-circle
imsize = size(img,1);

previousDisk= zeros(imsize);
aboveThrMsk=zeros(imsize);
for disk= 1:length(maskParams.ringRadius)
    radiusPix= fix(pixA/maskParams.ringRadius(disk) * imsize);
    currentDisk= centricDisk(imsize,radiusPix);
    diskMsk= img >= maskParams.threshold(disk) & ...
                 ~previousDisk & currentDisk;
    aboveThrMsk= aboveThrMsk | diskMsk;
    previousDisk= currentDisk;
end 

inRingPix = max(1, fix(pixA/maskParams.lowResLimAng * imsize)); 
outRingPix = min(fix((imsize)./2)+1,(pixA/maskParams.hiResLimAng) * imsize );  
msk =  aboveThrMsk & ~centricDisk(imsize,inRingPix) ...
        & centricDisk(imsize,outRingPix);   

%expand mask to make msk_filtered
expandradius   = fix((maskParams.expandPix)./2)+1;
circle = centricDisk(maskParams.expandPix,expandradius);
msk_filtered  = filter2(circle,msk); %equivalent to conv2(~mask,rot90(circle,2))

end


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

