function imgfft = fft2xSmooth(img,mode,startR, stopR)
%imgfft = fft2xSmooth(img,mode,startR, stopR)
%   smoothes edges and zero 2x pads iamge leading and trailing zeros 
%   if mode='original', returns unpadded and shifted fft2 
%                       so that size(img) == size(imgfft)
%   if mode='square' (default)
%                    imgfft is square with the size max(size(img))
%
%   Note: if image is not square, 2x padding is calculated based on the larger 
%   dimension.

if nargin < 2
    mode= 'square';
end
if nargin < 3
    startR= 0.85;
    stopR=  0.99;
end

imsize= size(img);
img = smoothEdgeImage(img,startR, stopR);
imgpad = double(padToSquare(img,2)); 
fftPad= fftshift(fft2(imgpad));

szdif = floor((size(imgpad)-imsize)./2);
switch mode
    case 'original'
        imgfft = fftPad( szdif(1)+1:szdif(1)+imsize(1), ...
                        szdif(2)+1:szdif(2)+imsize(2));
    case 'square'
        imgfft = fftPad( min(szdif)+1:min(szdif)+max(imsize), ...
                        min(szdif)+1:min(szdif)+max(imsize));
end

%debug
% figure;
% tiledlayout('flow');
% nexttile;
% imshow(img);set(gca,'YDir','normal');
% title('smooth edge micrograph');
% set(gca,'CLimMode','auto');
% nexttile;
% imshow(log(abs(fftPad)));set(gca,'YDir','normal','CLim',[12,16]);
% title('Padded PS');
% axis on;set(gca,'CLimMode','auto');
% rectangle('Position',[szdif(1)+1,szdif(2)+1,imsize(1),imsize(2)],'edgecolor','r','linewidth',1)
% rectangle('Position',[min(szdif)+1,min(szdif)+1,max(imsize),max(imsize)],'edgecolor','b','linewidth',1)
% drawnow;
%debug

end