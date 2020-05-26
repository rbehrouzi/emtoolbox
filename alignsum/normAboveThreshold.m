function img_sub = normAboveThreshold(img,threshold,expandPix,pixAng,lowResLimAng,HiResLimAng)
%NORMABOVETHRESHOLD mask pixels higher than threshold with expanded_pixels with circular shape
%   modified from BG Han (Oct 30 2017)
%

img2=double(img);
boxsize = size(img2,1);
imgfft = fftshift(fft2(img2));
%imgcenter = fix(size(imgfft)./2)+1;
pw=abs(log(imgfft));
sub_ = bg_FastSubtract_standard(pw);
hotpixmskraw = (sub_ > threshold);
figure; ax_=subplot(3,2,4); imshow(sub_); set(ax_,'CLimMode','auto');ax_.Title.String='bkgd sub fft';

innerring = max(1, fix(pixAng/lowResLimAng * boxsize)); 
outerring = min(fix((boxsize)./2)+1,(pixAng/HiResLimAng) * boxsize );  
smallcircle = centerCircMask(boxsize,innerring); 
bigcircle = centerCircMask(boxsize,outerring);
bandpassmsk = ~smallcircle & bigcircle;
hotpixmskband =  bandpassmsk & hotpixmskraw;   
ax_=subplot(3,2,1); imshow(hotpixmskband); set(ax_,'CLimMode','auto');ax_.Title.String='raw hotpix mask'; 

expandradius   = fix((expandPix)./2)+1;
circle = centerCircMask(expandPix,expandradius);
hotpixmsk  = filter2(circle,hotpixmskband); %equivalent to conv2(~mask,rot90(circle,2))
ax_=subplot(3,2,2); imshow(hotpixmsk); set(ax_,'CLimMode','auto');ax_.Title.String='filtered hotpix mask';


%middle = fix(boxsize/2)+1
%y2_strip = imgfft(middle - 20: middle + 20, :) ;
ax_=subplot(3,2,3);plot(ax_,mean(abs(imgfft)),'DisplayName','before subtraction'); 

% zippy local averaging; average four local areas (half unit cell apart)    
imgfftgoodpix = (~hotpixmsk) .* imgfft;
imgfftgoodpix_val = abs(imgfftgoodpix); 
ax_=subplot(3,2,5); imshow(abs(log(imgfftgoodpix))); set(ax_,'CLimMode','auto');ax_.Title.String='unchanged area';
pospixshift =  floor(pixAng/116 * boxsize);   %half-unit cell for SA
negpixshift = pospixshift  * -1 ;
imgfftgoodpix_avg = circshift(imgfftgoodpix_val,[pospixshift  0]);
imgfftgoodpix_avg = imgfftgoodpix_avg + circshift(imgfftgoodpix_val,[negpixshift  0]); 
imgfftgoodpix_avg = imgfftgoodpix_avg + circshift(imgfftgoodpix_val,[0    pospixshift]); 
imgfftgoodpix_avg = imgfftgoodpix_avg + circshift(imgfftgoodpix_val,[0    negpixshift]); 
imgfftgoodpix_avg = imgfftgoodpix_avg ./4;
%random_noise = random('Normal',0,1,box_size,box_size) ;
%shift_ave = shift_ave .*  random_noise; 

hotpixnewvals = abs (hotpixmsk .* imgfftgoodpix_avg);
hotpixphases = angle(hotpixmsk .* imgfft);
imgfft_sub = imgfftgoodpix + hotpixnewvals .* exp(1i .* hotpixphases); 
ax_=subplot(3,2,6); imshow(abs(log(imgfft_sub))); set(ax_,'CLimMode','auto');ax_.Title.String='lattice sub fft';
%circles = insertShape(abs(log(imgfft)),'circle',[imgcenter(:)' innerring; imgcenter(:)' outerring],'color',{'blue','red'});
%imshow(circles);

middle = fix(boxsize/2)+1; 
%y2_strip = imgfft(middle - 20: middle + 20, :) ;
ax_=subplot(3,2,3); hold on; plot(ax_,mean(abs(imgfft_sub)),'DisplayName','after subtraction');
hold off; set(ax_,'Xlim',[middle-100, middle+100]);

img_sub = real(ifft2(ifftshift(imgfft_sub))); 

end


