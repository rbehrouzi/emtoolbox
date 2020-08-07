function classSubtract()
%
%
%

%matlabrc; close all;
restoredefaultpath; 
clear variables;
addpath('../EMIODist2','../EMIO_parallel','./utils'); 

maskParams.padSize=     2;    % 2x padding in fft
maskParams.loLimAngst=  80;
maskParams.hiLimAngst=  3;
maskParams.smoothPix=   5;
%maskParams.sigma=       1.42;
maskParams.resolutionAngst= [15.00 10.00  8.00  5.00];
maskParams.threshold=       [7.20 5.50 4.50 3.50];

starFilePath=   'p1j55_particles.star';
mrcPathPrefix = './';
classesMrcsPath=  '/mnt/d/csparc/P1/J44/cryosparc_P1_J44_020_class_averages.mrc';
savePath=       '/mnt/d/20200410_cmplx3_SA/particles';
saveFSuff=      '_classsub_p1j44'; %filename suffix

[pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix, 'parallel');
%load(['particles-masks',saveFSuff]);

% read all 2D class images
% and make masks for the ones referenced in particles data
% classNr indices remain consistent with latticeMask 
classNr= unique(pMetaData.classNr);
classStack= ReadMRC(classesMrcsPath); 
maskTemplate= padToSquare(false(size(classStack(:,:,1))),maskParams.padSize);
latticeMask= repmat(maskTemplate,1,1,size(classStack,3)); 
for ii= 1:length(classNr)
    cls= classNr(ii);
    imgfft= fftshift(fft2(padToSquare(classStack(:,:,cls),maskParams.padSize)));
    logPS=log(abs(imgfft));
    latticeMask(:,:,cls)= createMask(logPS,maskParams,pMetaData.pixA);
    [class_sub, classfft_sub]= applyMask(imgfft,latticeMask(:,:,cls), pMetaData.pixA, 'StdNormRand');
    showTemplateDiagnostics(classStack(:,:,cls),imgfft, class_sub, classfft_sub,maskParams.padSize); % display operation results on template
end
save(['particles-masks',saveFSuff],'latticeMask', 'pStackIdx', 'pStackPath', 'pMetaData');

nParticles=length(pStackIdx);
imSize= pMetaData.imageSize;
newStackIdx = zeros(1,nParticles,'uint32');
openStackName='';
slice=1; 
for particle = 1:nParticles
    if ~strcmpi(pStackPath{particle},openStackName)
        if particle>1
            % write out previous img_sub whenever a new stack is to be opened
            fn= fullfile(savePath,[saveFName,saveFSuff,saveFExt]);
            writeUnpadMRC(img_sub(:,:,1:slice-1), imSize, ...
                          pMetaData.pixA, fn, 2);
        end
        slice=1;
        openStackName=pStackPath{particle};
        [~,saveFName,saveFExt]= fileparts(openStackName);
        [stack, stackMetaData]=ReadMRC(pStackPath{particle});
        img_sub = repmat(padToSquare(zeros(imSize,'single'), ...
                         maskParams.padSize),1,1,stackMetaData.nz);
    end
    img= double(stack(:,:,pStackIdx(particle)));    
    imgfft= fftshift(fft2(padToSquare(img,  maskParams.padSize)));
    rotatedMask= rotateAroundCenter(latticeMask(:,:,pMetaData.classNr(particle)), -pMetaData.anglePsi(particle)); %rotate mask back to unaligned image
    [img_sub(:,:,slice), ~]= applyMask(imgfft,rotatedMask, pMetaData.pixA, 'StdNormRand');
    newStackIdx(particle)=slice;
    slice=slice+1;
end

% the very last stack
fn= fullfile(savePath,[saveFName,saveFSuff,saveFExt]);
writeUnpadMRC(img_sub(:,:,slice-1), imSize, pMetaData.pixA, fn, 2);

end

% function showSingleParticles()
% subplot(1,2,1)
% ax_=imshow(log(abs(imgfft)));
% set(gca,'CLim',[5,8]);
% subplot(1,2,2)
% imshow(log(abs(fftshift(fft2(img_sub(:,:,slice))))));
% set(gca,'CLim',[5,8]);
% end
