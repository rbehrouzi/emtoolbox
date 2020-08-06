function selfSubtract()
    restoredefaultpath; 
    addpath('../EMIODist2','../EMIO_parallel'); % IO for star and mrc files
    %clear variables; matlabrc; close all;

    maskParams.padSize=     64;    % pad size before and after images
    maskParams.loLimAngst=  40;
    maskParams.hiLimAngst=  3;
    maskParams.sigma=       1.42;
    maskParams.smoothPix=   5;
    savePath=               '/mnt/d/20200410_cmplx3_SA/particles';
    starFilePath=           'p1j55_particles.star';
    mrcPathPrefix =         '/mnt/d/csparc/P1';

    [pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix, 'parallel');
    nParticles=length(pStackIdx);
    pixA= pMetaData.pixA;
    imsize= pMetaData.imageSize;
    openStackName='';
    newStackIdx = zeros(1,nParticles,'uint32');
    for particle = 1:nParticles
        if ~strcmpi(pStackPath{particle},openStackName)
            if exist('img_sub', 'var')
                if slice-1 < s.nz
                    % some particles in the mrc stack were not referenced 
                    % in the star file. Remove empty end of img_sub before saving
                    img_sub(:,:,slice:end)=[];
                end
                WriteMRC(img_sub(maskParams.padSize+1:maskParams.padSize+imsize(1),...
                    maskParams.padSize+1:maskParams.padSize+imsize(2), :), pixA, ...
                    fullfile(savePath,[lastStackName,'_selfsub_sigma142',lastStackExt]),2,size(img_sub,3));
            end
            openStackName=pStackPath{particle};
            [stack, s]=ReadMRC(pStackPath{particle});
            img_sub = repmat(padToSquare(zeros(imsize,'single'),  maskParams.padSize),1,1,s.nz);
            slice=1;
            [~,lastStackName,lastStackExt]= fileparts(openStackName);
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
end

