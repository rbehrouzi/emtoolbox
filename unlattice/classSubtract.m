function classSubtract()
    restoredefaultpath; 
    addpath('../EMIODist2','../EMIO_parallel'); % IO for star and mrc files
    %clear variables; matlabrc; close all;

    maskSettings.padSize=           64;    % pad size before and after images
    maskSettings.smoothPix=         5;     % square size containing circle to filter (smooth) mask
    maskSettings.loLimAngst=      40;
    maskSettings.hiLimAngst=       3;
    maskSettings.resolutionAngst= [10,7.0,5.8,4.78,3.8,3.4];
    maskSettings.threshold=       [6.0,5.0,4.0,3.6,3.4,3.1];

    starFilePath= 'p1j44_singlestack.star';
    mrcPathPrefix = './';
    [pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix, 'parallel');

    % read all 2D class images
    % and make masks for the ones referenced in particles data
    % classNr indices remain consistent with latticeMask 
    classNr= unique(pMetaData.classNr);
    classesMrcsPath=  '/data/reza/csparc/P1/J44/cryosparc_P1_J44_020_class_averages.mrc';
    classStack= double(ReadMRC(classesMrcsPath)); 
    maskTemplate= padToSquare(false(pMetaData.imageSize),maskSettings.padSize);
    latticeMask= repmat(maskTemplate,1,1,size(classStack,3)); 
    for cls= classNr
        imgfft= fftshift(fft2(padToSquare(classStack(:,:,cls),maskSettings.padSize)));
        logPS=log(abs(imgfft));
        rawmask = maskAboveThreshold(logPS,maskSettings,pMetaData.pixA);
        latticeMask(:,:,cls)= filter2(circle,rawmask); %smoothing 
        [class_sub, classfft_sub]= applyMask(imgfft,latticeMask(:,:,cls), pMetaData.pixA, 'StdNormRand');
        showTemplateDiagnostics(classStack(:,:,cls),imgfft, class_sub, classfft_sub,maskSettings.padSize); % display operation results on template
    end

    openStackName = ''; 
    nParticles=length(pStackIdx);
    class2D= pMetaData.classNr;
    for particle = 1:nParticles
        if ~strcmpi(pStackPath{particle},openStackName)
            if exist('img_sub', 'var')
                WriteMRC(img_sub(maskSettings.padSize+1:maskSettings.padSize+imsize(1),...
                    maskSettings.padSize+1:maskSettings.padSize+imsize(2), :), pixA, ...
                    fullfile(savePath,[lastStackName,'_selfsub',lastStackExt]),2,size(img_sub,3));
            end
    %        fprintf(logger,"Now reading file %d. Total particles read so far is %d.\r",fileno, particle);
            openStackName=pStackPath{particle};
            [stack, s]=ReadMRC(pStackPath{particle});
            img_sub = repmat(padToSquare(zeros(imsize),  maskSettings.padSize),1,1,s.nz);
            [~,lastStackName,lastStackExt]= fileparts(openStackName);
        end
        img= double(stack(:,:,pStackIdx(particle)));    
        imgfft= fftshift(fft2(padToSquare(img,  maskSettings.padSize)));
        rotatedMask= rotateAroundCenter(latticeMask(:,:,class2D(particle)), -pMetaData.anglePsi(particle)); %rotate mask back to unaligned image
        [img_sub(:,:,particle), ~]= applyMask(imgfft,rotatedMask, pMetaData.pixA, 'StdNormRand');
    end
end

