addpath('../EMIODist2','../EMIO_parallel'); % IO of star and mrcs files

maskParams.padSize=     2;    % 2x padding in fft
maskParams.loLimAngst=  80;
maskParams.hiLimAngst=  3;
maskParams.smoothPix=   5;
maskParams.sigma= 1.4;
maskParams.resolutionAngst= [15.00 10.00  8.00  5.00];
maskParams.threshold=       [7.20 5.50 4.50 3.50];

%load('p1j55_particles_ctf.mat');
%starFilePath= 'p1j55_particles_ctf.star';
%mrcPathPrefix = './';
%[pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix, 'parallel');

openstackname = ""; fileno = 0;
nParticles=length(pStackIdx);
figure('Renderer', 'painters', 'Position', [1500 100 800 800]); 
for particle = 1:nParticles
    if ~strcmpi(pStackPath{particle},openstackname)
        openstackname=pStackPath{particle};
        [stack, ~]=ReadMRC(pStackPath{particle});
    end
    img= double(padToSquare(stack(:,:,pStackIdx(particle)),maskParams.padSize)); 
    logPS= log(abs(fftshift(fft2(img))));
    sa_mask=createMask(logPS,maskParams,pMetaData.pixA,'sigma');

    f = ones(3,3)/10; %low pass filter
    ax_=subplot(1,2,1); imshow(filter2(f,img)); set(ax_,'CLimMode','auto');ax_.Title.String='Original Image';
    ax_=subplot(1,2,2); imshow(sa_mask); set(ax_,'CLimMode','auto');ax_.Title.String='Power Spectrum (log)';
    drawnow;
end
