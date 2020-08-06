addpath('../../EMIODist2','../../EMIO_parallel','../../unlattice/'); % IO of star and mrcs files

maskSettings.padSize=      64;    % pad size to add to each side of image
maskSettings.sigma_contrast= 1.42;
maskSettings.expandPix= 5;
expandradius   = fix(expandPix./2)+1;

starFilePath= '../p1j44_particles.star';
mrcPathPrefix = '../';
%[pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix, 'parallel');

openstackname = ""; fileno = 0;
nParticles=length(pStackIdx);
figure('Renderer', 'painters', 'Position', [1500 100 800 800]); 
for particle = 1:nParticles
    if ~strcmpi(pStackPath{particle},openstackname)
        openstackname=pStackPath{particle};
        [stack, ~]=ReadMRC(pStackPath{particle});
        fileno = fileno + 1;
    end
    img= double(padToSquare(stack(:,:,pStackIdx(particle)),maskSettings.padSize)); 
    logPS= log(abs(fftshift(fft2(img))));
    f = ones(3,3)/10; %low pass filter
    %expand mask to make msk_filtered
    sa_mask=logPS>(mean(logPS,'all')+maskSettings.sigma_contrast*std(logPS,1,'all'));
    circle = centricDisk(maskSettings.expandPix,expandradius);
    sa_mask= filter2(circle,sa_mask); %equivalent to conv2(~mask,rot90(circle,2))

    ax_=subplot(1,2,1); imshow(filter2(f,img)); set(ax_,'CLimMode','auto');ax_.Title.String='Original Image';
    ax_=subplot(1,2,2); imshow(sa_mask); set(ax_,'CLimMode','auto');ax_.Title.String='Power Spectrum (log)';
    drawnow;
end
