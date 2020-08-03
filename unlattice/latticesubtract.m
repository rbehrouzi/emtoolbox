function latticesubtract()
clear variables;
%restoredefaultpath; matlabrc; close all;

padsize=            200;    % pad size in pixels to add to the largest dimension of image, padded image is square shaped
Low_res_lim_Ang=    20;     % lowest resolution to mask
Hi_res_lim_Ang=     5;      % highest resolution to mask
Pixel_Ang=          1.13;   % pixel size in anstrums
Threshold=          6.0;    % PICK FROM LOG OF RAW POWER SPECTRUM
expand_diameter=      1;    % expansion diameter of mask in pixels; applies to filtered mask


templateImgPath=  'class5.mrc'; 
template_img= ReadMRC(templateImgPath); template_img= double(template_img);

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

    WriteMRC(img_sub,1,'subtracted_template.mrc');
end  
