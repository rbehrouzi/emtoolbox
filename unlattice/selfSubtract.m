function selfSubtract()
    restoredefaultpath; 
    addpath('../EMIODist2','../EMIO_parallel'); % IO for star and mrc files
    %clear variables; matlabrc; close all;

    maskParams.padSize=     64;    % pad size before and after images
    maskParams.loLimAngst=  40;
    maskParams.hiLimAngst=  3;
    maskParams.sigma=       1.42;
    maskParams.smoothPix=   5;
    savePath=               '/scratch/J55_sub';
    starFilePath=           'p1j55_particles.star';
    mrcPathPrefix =         './';

    [pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix, 'parallel');
    nParticles=length(pStackIdx);
    pixA= pMetaData.pixA;
    imsize= pMetaData.imageSize;
    openStackName='';
    for particle = 1:nParticles
        if ~strcmpi(pStackPath{particle},openStackName)
            if exist('img_sub', 'var')
                WriteMRC(img_sub(maskParams.padSize+1:maskParams.padSize+imsize(1),...
                    maskParams.padSize+1:maskParams.padSize+imsize(2), :), pixA, ...
                    fullfile(savePath,[lastStackName,'_selfsub',lastStackExt]),2,size(img_sub,3));
            end
            openStackName=pStackPath{particle};
            [stack, s]=ReadMRC(pStackPath{particle});
            img_sub = repmat(padToSquare(zeros(imsize),  maskParams.padSize),1,1,s.nz);
            [~,lastStackName,lastStackExt]= fileparts(openStackName);
        end
        img= double(stack(:,:,pStackIdx(particle)));    
        imgfft= fftshift(fft2(padToSquare(img,  maskParams.padSize)));
        sa_mask=createMask(log(abs(imgfft)),maskParams,pixA,'sigma');
        [img_sub(:,:,particle), ~]= applyMask(imgfft,sa_mask, pixA, 'StdNormRand');

        %TODO: normalize each particle to have standard normal outside particle
        % radius
    end
end

