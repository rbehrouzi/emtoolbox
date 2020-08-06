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
msk_filtered  = filter2(circle,msk); %smoothing 

end




