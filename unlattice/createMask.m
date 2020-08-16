function mask= createMask(img,maskParams, pixA, method)
%CREATEMASK(IMG, MASKPARAMS, PIXANGST, METHOD) 
%
% masked values are 1, other regions 0
%

    if nargin < 4
        method= 'threshold';
    end
    imsize = size(img);
    pixAngst= pixA./maskParams.padSize;
    
    switch method
        case 'threshold'
            previousDisk= zeros(imsize);
            imgMask=zeros(imsize);
            for disk= 1:length(maskParams.threshold)
                resolutionRingPix= fix(pixAngst/maskParams.resolutionAngst(disk) * imsize);
                currentDisk= centricDisk(imsize,resolutionRingPix);
                diskMsk= (img >= maskParams.threshold(disk)) & ...
                             ~previousDisk & currentDisk;
                imgMask= imgMask | diskMsk;
                previousDisk= currentDisk;
            end 

        case 'sigma'
            imgMask= (img >= ( mean(img,'all') + ...
                               maskParams.sigma * std(img,1,'all')));
    end
    
    %apply resolution constraints to mask
    inRingPix= max(1, fix(pixAngst/maskParams.loLimAngst * imsize)); 
    outRingPix= min(fix((imsize)./2)+1,(pixAngst/maskParams.hiLimAngst) * imsize );  
    mask =  imgMask & ~centricDisk(imsize,inRingPix) ...
            & centricDisk(imsize,outRingPix);   

    %smooth mask
    if maskParams.smoothPix > 1
        r= fix(maskParams.smoothPix./2)+1;
        smoothFilter = centricDisk(maskParams.smoothPix,r);
        mask= filter2(smoothFilter,mask); 
    end
end




