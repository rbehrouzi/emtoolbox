function selfSubtract()
%
%
%

%matlabrc; close all;
restoredefaultpath; 
clear variables;
addpath('../EMIODist2','../EMIO_parallel'); % IO for star and mrc files

maskParams.padSize=     64;    % pad size before and after images
maskParams.loLimAngst=  40;
maskParams.hiLimAngst=  3;
maskParams.smoothPix=   5;
maskParams.sigma=       1.42;
%maskSettings.resolutionAngst= [10,7.0,5.8,4.78,3.8,3.4];
%maskSettings.threshold=       [6.0,5.0,4.0,3.6,3.4,3.1];

savePath=               '/mnt/d/20200410_cmplx3_SA/particles';
starFilePath=           'p1left.star';
mrcPathPrefix =         '/mnt/d/csparc/P1';
saveFSuff=          ['_selfsub_sigma-',...  
                         strrep(num2str(maskParams.sigma),'.','p')]; %filename suffix

[pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix, 'serial');
nParticles=length(pStackIdx);
pixA= pMetaData.pixA; 
imsize= pMetaData.imageSize;
padSize=maskParams.padSize;
newStackIdx = zeros(1,nParticles,'uint32');
openStackName='';
slice=1; 
for particle = 1:nParticles
    if ~strcmpi(pStackPath{particle},openStackName)
        if particle>1
            % write out previous img_sub whenever a new stack is to be opened
            WriteMRC( img_sub(padSize+1:padSize+imsize(1),...
                              padSize+1:padSize+imsize(2), 1:slice-1),...
                pixA, fullfile(savePath,[saveFName,saveFSuff,saveFExt]),...
                2);
        end
        slice=1;
        openStackName=pStackPath{particle};
        [~,saveFName,saveFExt]= fileparts(openStackName);
        [stack, stackMetaData]=ReadMRC(pStackPath{particle});
        img_sub = repmat(padToSquare(zeros(imsize,'single'), ...
                         maskParams.padSize),1,1,stackMetaData.nz);
    end
    img= double(stack(:,:,pStackIdx(particle)));    
    imgfft= fftshift(fft2(padToSquare(img,  maskParams.padSize)));
    sa_mask=createMask(log(abs(imgfft)),maskParams,pixA,'sigma');
    [img_sub(:,:,slice), ~]= applyMask(imgfft,sa_mask, pixA, 'StdNormRand');
    newStackIdx(particle)=slice;
    slice=slice+1;

    %TODO: normalize each particle to have standard normal outside particle
    % radius
end

% the very last stack
WriteMRC( img_sub(padSize+1:padSize+imsize(1),...
                  padSize+1:padSize+imsize(2), 1:slice-1),...
    pixA, fullfile(savePath,[saveFName,saveFSuff,saveFExt]),...
    2);

end

