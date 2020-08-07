function writeUnpadMRC(img,oriImageSize,pixAngst,fileName,dataType)
%WRITEUNPADMRC write original image from FFT padded image
%   Detailed explanation goes here
if nargin < 5
    dataType= 2;
end

% this works even if img is 2-dimensional
padding=floor( (size(img(:,:,1)) - oriImageSize) ./2 ); 
WriteMRC( img(padding(1)+1:padding(1)+oriImageSize(1),...
              padding(2)+1:padding(2)+oriImageSize(2), :),...
          pixAngst, fileName, dataType);

end

