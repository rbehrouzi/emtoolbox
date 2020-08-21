function imgfft = fft2xSmooth(img,mode,startR, stopR)
%imgfft = fft2xSmooth(img,mode,startR, stopR)
%   smoothes edges and zero 2x pads iamge leading and trailing zeros 
%   if mode='original', returns unpadded and shifted fft2 
%                       so that size(img) == size(imgfft)
%   if mode='square' (default)
%                    imgfft is square with the size max(size(img))
%
%   Note: if image is not square, 2x padding is calculated for the larger 
%   dimension and adjusted for the smaller one to create square before fft2 
%   calculation.

if nargin < 2
    mode= 'square';
end
if nargin < 3
    startR= 0.85;
    stopR=  0.99;
end

imsize= size(img);
sqSize = 2 ^ nextpow2(2*max(imsize));
pad= floor( (sqSize - imsize)./2 );
imgpad= padArraySine(img, pad, startR, stopR);
fftPad= fftshift(fft2(imgpad));

switch mode
    case 'original'
        imgfft = fftPad( pad(1)+1:pad(1)+imsize(1), ...
                        pad(2)+1:pad(2)+imsize(2));
    case 'square'
        imgfft = fftPad( min(pad)+1:min(pad)+max(imsize), ...
                        min(pad)+1:min(pad)+max(imsize));
end

%debug
figure;
tiledlayout('flow');
nexttile;
imshow(imgpad);set(gca,'YDir','normal');
set(gca,'CLimMode','auto');
nexttile;
imshow(log(abs(fftPad)));set(gca,'YDir','normal','CLim',[12,16]);
axis on;set(gca,'CLimMode','auto');
rectangle('Position',[pad(1)+1,pad(2)+1,imsize(1),imsize(2)],'edgecolor','r','linewidth',1)
rectangle('Position',[min(pad)+1,min(pad)+1,max(imsize),max(imsize)],'edgecolor','b','linewidth',1)
drawnow;
%debug

end