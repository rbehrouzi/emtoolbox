addpath('../../EMIODist2','../../EMIO_parallel','../../unlattice/'); % IO of star and mrcs files

maskSettings.padSize=      128;    % pad size in pixels to add to the largest dimension of image, padded image is square shaped
maskSettings.expandPix=    1;
maskSettings.lowResLimAng= 40;
maskSettings.hiResLimAng=  3;
maskSettings.ringRadius=   [10,7.0,5.8,4.78,3.8,3.4];
maskSettings.threshold=    [6.0,5.0,4.0,3.6,3.4,3.1];

classNr= 1:100;
classesMrcsPath=  '/data/reza/csparc/P1/J44/cryosparc_P1_J44_020_class_averages.mrc';
classStack= double(ReadMRC(classesMrcsPath)); 
maskTemplate= padToSquare(false(pMetaData.nx, pMetaData.ny),maskSettings.padSize);
latticeMask= repmat(maskTemplate,1,1,size(classStack,3)); 
for cls= classNr
    imgfft= fftshift(fft2(padToSquare(classStack(:,:,cls),maskSettings.padSize)));
    logPS=log(abs(imgfft));
    [latticeMask(:,:,cls), ~] = maskAboveThreshold(logPS,maskSettings,pMetaData.pixA);
    [class_sub, classfft_sub]= applyMask(imgfft,latticeMask(:,:,cls), pMetaData.pixA, 'StdNormRand');
    showTemplateDiagnostics(classStack(:,:,cls),imgfft, class_sub, classfft_sub,maskSettings.padSize); % display operation results on template
end