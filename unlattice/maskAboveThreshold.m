function [hotpixmsk, hotpixmsk_filtered] = maskAboveThreshold(img,threshold,expandPix,pixAng,lowResLimAng,HiResLimAng)
%MASKABOVETHRESHOLD mask pixels higher than threshold with expanded_pixels with circular shape
%
boxsize = size(img,1);
hotpixmskraw=imbinarize(img,threshold);
innerring = max(1, fix(pixAng/lowResLimAng * boxsize)); 
outerring = min(fix((boxsize)./2)+1,(pixAng/HiResLimAng) * boxsize );  
smallcircle = centerCircMask(boxsize,innerring); 
bigcircle = centerCircMask(boxsize,outerring);
bandpassmsk = ~smallcircle & bigcircle;
hotpixmsk =  bandpassmsk & hotpixmskraw;   

expandradius   = fix((expandPix)./2)+1;
circle = centerCircMask(expandPix,expandradius);
hotpixmsk_filtered  = filter2(circle,hotpixmsk); %equivalent to conv2(~mask,rot90(circle,2))

end


