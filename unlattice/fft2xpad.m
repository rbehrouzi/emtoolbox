function imgfft = fft2xpad(img)
%imgfft = fft2xpad(img)
%   pads img by a factor of 2 (or more to reach next power of 2) with 
%   leading and trailing zeros 
%   returns unpadded and shifted fft2 so that size(img) == size(imgfft)
%
%   if image is not square, 2x padding is calculated for the larger dim
%   and adjusted for the smaller dimension to create square before fft2 
%   calculation.

imsize= size(img);
sqSize = 2 ^ nextpow2( max(imsize) );
pad= floor( (sqSize - imsize)./2 );
imgPad= padarray(img,pad,'both');
fftPad= fftshift(fft2(imgPad));

imgfft = fftPad( pad(1)+1:pad(1)+imsize(1), ...
                 pad(2)+1:pad(2)+imsize(2));


end

