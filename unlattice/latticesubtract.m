function latticesubtract()
addpath('../EMIODist2'); % IO of star and mrcs files
clear variables;
%restoredefaultpath; matlabrc; close all;

maskSettings.padSize=      200;    % pad size in pixels to add to the largest dimension of image, padded image is square shaped
maskSettings.expandPix=    1;
maskSettings.lowResLimAng= 40;
maskSettings.hiResLimAng=  3;
maskSettings.ringRadius=   [10,7.0,5.8,4.78,3.8,3.4];
maskSettings.threshold=    [6.0,5.0,4.0,3.6,3.4,3.1];

starFilePath= 'test_big_stack.star';
mrcPathPrefix = './';
[pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix);

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
    showTemplateDiagnositcs(classStack(:,:,cls),imgfft, class_sub, classfft_sub,maskSettings.padSize); % display operation results on template
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
    img_padded= padarray(img,  directional_padsize);
    rotatedMask= applyRotation(latticeMask, size(img_padded,1), size(img_padded,2),-pMetaData.anglePsi(particle)); %rotate mask back to unaligned image
    imgfft= fftshift(fft2(img_padded));
    [img_sub(:,:,particle), ~]= applyMask(imgfft,rotatedMask, pMetaData.pixA, 'StdNormRand');
%    imshowpair(abs(imgfft),abs(subfft),'montage')
end
WriteMRC(img_sub(directional_padsize(1)+1:directional_padsize(1)+imsize(1),...
                 directional_padsize(2)+1:directional_padsize(2)+imsize(2), :), ...
         pMetaData.pixA(1),'test_big_sub_radial.mrcs',2,nParticles);
end

function showTemplateDiagnositcs(img, imgfft, img_sub, imgfft_sub,padSize)
    logPS=log(abs(imgfft));
    imsize= size(img);
    directional_padsize= padSize+max(imsize)-imsize;
    figure('Renderer', 'painters', 'Position', [1500 100 800 1200]); 
    ax_=subplot(3,2,1); imshow(abs(img)); set(ax_,'CLimMode','auto');ax_.Title.String='Original Image';
    ax_=subplot(3,2,2); imshow(logPS); set(ax_,'CLimMode','auto');ax_.Title.String='Power Spectrum (log)';
    ax_=subplot(3,2,3); imshow(img_sub); set(ax_,'CLimMode','auto', ...
        'Xlim',[directional_padsize(1),directional_padsize(1)+imsize(1)],...
        'Ylim',[directional_padsize(2),directional_padsize(2)+imsize(2)]); 
    ax_.Title.String='Lattice subtracted Image (FFT padded)';
    ax_=subplot(3,2,4); imshow(log(abs(imgfft_sub))); set(ax_,'CLimMode','auto');ax_.Title.String='Masked Power Spectrum (log)'; 
    %circles = insertShape(abs(log(imgfft)),'circle',[imgcenter(:)' innerring; imgcenter(:)' outerring],'color',{'blue','red'});
    %imshow(circles);
    ax_=subplot(3,2,[5,6]);hold on;
    plot(ax_,mean(abs(imgfft)),'DisplayName','before subtraction'); 
    plot(ax_,mean(abs(imgfft_sub)),'DisplayName','after subtraction');
    hold off; legend('boxoff');
    drawnow;

    WriteMRC(img_sub,1,'subtracted_template.mrc');
end  
