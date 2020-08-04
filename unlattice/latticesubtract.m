function latticesubtract()
addpath('../EMIODist2'); % IO of star and mrcs files
clear variables;
%restoredefaultpath; matlabrc; close all;

padsize=            200;    % pad size in pixels to add to the largest dimension of image, padded image is square shaped
Low_res_lim_Ang=    30;     % lowest resolution to mask
Hi_res_lim_Ang=     3;      % highest resolution to mask
Pixel_Ang=          1.13;   % pixel size in anstrums
Threshold=          5;    % PICK FROM LOG OF RAW POWER SPECTRUM
expand_diameter=      1;    % expansion diameter of mask in pixels; applies to filtered mask


templateImgPath=  'class5.mrc'; 
template_img= double(ReadMRC(templateImgPath));

% pad image to square
imsize= size(template_img);
directional_padsize= padsize+max(imsize)-imsize;
img_padded= padarray(template_img,  directional_padsize);

imgfft= fftshift(fft2(img_padded));
logPS=log(abs(imgfft));
[hotpixmsk, ~] = maskAboveThreshold(logPS,Threshold,expand_diameter,Pixel_Ang,Low_res_lim_Ang,Hi_res_lim_Ang);
%TODO: adaptive radial threshold value is needed

[img_sub, imgfft_sub]= applyMask(imgfft,hotpixmsk,'StdNormRand', Pixel_Ang);
showTemplateDiagnositcs(template_img,imgfft, img_sub, imgfft_sub,padsize,Threshold); % display operation results on template
WriteMRC(img_sub,Pixel_Ang,'template_subtracted.mrc',2,1);

starFilePath= 'raw_test.star';
mrcPathPrefix = './';
[particleIdx, stackPath, alignInfo]= getStackHandle(starFilePath, mrcPathPrefix);

openstackname = ""; fileno = 0;
nParticles=length(particleIdx);
img_sub = zeros(size(img_sub,1),size(img_sub,2),nParticles);

for particle = 1:nParticles
    if ~strcmpi(stackPath{particle},openstackname)
        openstackname=stackPath{particle};
        [stack, ~]=ReadMRC(stackPath{particle});
        fileno = fileno + 1;
%        fprintf(logger,"Now reading file %d. Total particles read so far is %d.\r",fileno, row);
    end
    img= double(stack(:,:,particleIdx(particle)));    
    img_padded= padarray(img,  directional_padsize);
    rotatedMask= applyRotation(hotpixmsk, size(img_padded,1), size(img_padded,2),-alignInfo.anglePsi(particle)); %rotate mask back to unaligned image
    imgfft= fftshift(fft2(img_padded));
    [img_sub(:,:,particle), ~]= applyMask(imgfft,rotatedMask,'StdNormRand', alignInfo.pixA);
%    imshowpair(abs(imgfft),abs(subfft),'montage')
end
WriteMRC(img_sub(directional_padsize(1)+1:directional_padsize(1)+imsize(1),...
                 directional_padsize(2)+1:directional_padsize(2)+imsize(2), :), ...
         alignInfo.pixA(1),'sa_sub.mrcs',2,nParticles);
end

function showTemplateDiagnositcs(img, imgfft, img_sub, imgfft_sub,padsize,Threshold)
    logPS=log(abs(imgfft));
    imsize= size(img);
    directional_padsize= padsize+max(imsize)-imsize;
    figure('Renderer', 'painters', 'Position', [1500 100 800 1200]); 
    ax_=subplot(3,2,1); imshow(abs(img)); set(ax_,'CLimMode','auto');ax_.Title.String='Original Image';
    ax_=subplot(3,2,2); imshow(logPS); set(ax_,'CLimMode','auto');ax_.Title.String='Power Spectrum (log)';
    ax_=subplot(3,2,3); imshow(img_sub); set(ax_,'CLimMode','auto', ...
        'Xlim',[directional_padsize(1),directional_padsize(1)+imsize(1)],...
        'Ylim',[directional_padsize(2),directional_padsize(2)+imsize(2)]); 
    ax_.Title.String='Lattice subtracted Image (FFT padded)';
    ax_=subplot(3,2,4); imshow(log(abs(imgfft_sub))); set(ax_,'CLimMode','auto');ax_.Title.String=sprintf('Masked PS (log, threshold %1.2f)',Threshold); 
    %circles = insertShape(abs(log(imgfft)),'circle',[imgcenter(:)' innerring; imgcenter(:)' outerring],'color',{'blue','red'});
    %imshow(circles);
    ax_=subplot(3,2,[5,6]);hold on;
    plot(ax_,mean(abs(imgfft)),'DisplayName','before subtraction'); 
    plot(ax_,mean(abs(imgfft_sub)),'DisplayName','after subtraction');
    hold off; 
    drawnow;

    WriteMRC(img_sub,1,'subtracted_template.mrc');
end  
