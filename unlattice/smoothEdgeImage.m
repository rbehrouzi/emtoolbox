function smthimg = smoothEdgeImage(img,startR, stopR)
%smthimg = smoothEdgeImage(img,startR, stopR)
% smoothing starts at startR and reaches zero at stopR
% startR and StopR are fractions of image size
%
% % example: smoothEdgeImage(img, 0.75, 1.0)

    imsize=size(img);
    cen=floor((imsize+1)./2);
    [X,Y]= meshgrid((1:imsize(2))-cen(2), ...
                    (1:imsize(1))-cen(1));
    R = 2* sqrt((X./imsize(2)).^2 + (Y./imsize(1)).^2); %normalized radius [0,1]

    freq=0.5 * pi / (stopR - startR ) ; %1/4 period of cosine
    smthFilter= abs(cos(freq.*(R-startR))); %x shift origin to startR
    smthRange=(R>=startR);
    smthFilter(~smthRange)=1.0;
    smthFilter(R>=stopR)=0.0;
    smthimg = img .* smthFilter;    
end