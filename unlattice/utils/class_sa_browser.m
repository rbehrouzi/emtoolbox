maskParams.padSize=     2;    % pad size before and after images
maskParams.loLimAngst=  80;
maskParams.hiLimAngst=  3;
maskParams.smoothPix=   5;
%maskParams.sigma=       1.42;
maskParams.resolutionAngst= [15.00 10.00  8.00  5.00];
maskParams.threshold=       [7.20 5.50 4.50 3.50];

classesMrcsPath=  '/mnt/d/csparc/P1/J44/cryosparc_P1_J44_020_class_averages.mrc';
[classStack, metaData]= ReadMRC(classesMrcsPath); 
classNr = metaData.nz;
pixAngst = metaData.pixA;

maskTemplate= padToSquare(false(size(classStack(:,:,1))),maskParams.padSize);
latticeMask= repmat(maskTemplate,1,1,size(classStack,3)); 
for cls= 1:classNr
    imgfft= fftshift(fft2(padToSquare(classStack(:,:,cls),maskParams.padSize)));
    logPS=log(abs(imgfft));
    latticeMask(:,:,cls)= createMask(logPS,maskParams,pixAngst,'threshold');
    [class_sub, classfft_sub]= applyMask(imgfft,latticeMask(:,:,cls), pixAngst, 'StdNormRand');
    showTemplateDiagnostics(classStack(:,:,cls),imgfft, class_sub, classfft_sub,maskParams.padSize); % display operation results on template
    pause;
end