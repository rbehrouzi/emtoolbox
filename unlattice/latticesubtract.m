function latticesubtract()
addpath('../EMIODist2','../EMIO_parallel'); % IO of star and mrcs files
clear variables;
%restoredefaultpath; matlabrc; close all;

maskSettings.padSize=      200;    % pad size in pixels to add to the largest dimension of image, padded image is square shaped
maskSettings.expandPix=    1;
maskSettings.lowResLimAng= 40;
maskSettings.hiResLimAng=  3;
maskSettings.ringRadius=   [10,7.0,5.8,4.78,3.8,3.4];
maskSettings.threshold=    [6.0,5.0,4.0,3.6,3.4,3.1];

starFilePath= 'p1j44_singlestack.star';
mrcPathPrefix = './';
[pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix, 'parallel');

% read all 2D class images
% and make masks for the ones referenced in particles data
% classNr indices remain consistent with latticeMask 
classNr= unique(pMetaData.classNr);
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

openstackname = ""; fileno = 0;
nParticles=length(pStackIdx);
img_sub = zeros(size(class_sub,1),size(class_sub,2),nParticles);

for particle = 1:nParticles
    if ~strcmpi(pStackPath{particle},openstackname)
        openstackname=pStackPath{particle};
        [stack, ~]=ReadMRC(pStackPath{particle});
        fileno = fileno + 1;
%        fprintf(logger,"Now reading file %d. Total particles read so far is %d.\r",fileno, row);
    end
    img= double(stack(:,:,pStackIdx(particle)));    
    imgfft= fftshift(fft2(padToSquare(img,  maskSettings.padSize)));
    rotatedMask= applyRotation(latticeMask, size(imgfft,1), size(imgfft,2),-pMetaData.anglePsi(particle)); %rotate mask back to unaligned image
    [img_sub(:,:,particle), ~]= applyMask(imgfft,rotatedMask, pMetaData.pixA, 'StdNormRand');
%    imshowpair(abs(imgfft),abs(subfft),'montage')
end
WriteMRC(img_sub(directional_padsize(1)+1:directional_padsize(1)+imsize(1),...
                 directional_padsize(2)+1:directional_padsize(2)+imsize(2), :), ...
         pMetaData.pixA(1),'test_big_sub_radial.mrcs',2,nParticles);
end

