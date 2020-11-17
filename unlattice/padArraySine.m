function padimg = padArraySine(img,padsize,startR, stopR)
%padimg = padArraySine(img,padsize,startR, stopR)
% Zero pad image to defined ratio and make edges smooth
% smoothing starts at startR and reaches zero at stopR
% startR and StopR are fractions of image size
% padsize is 2-element vector of rows and columns to both sides of each
% dimension of the image
% example: paddArraySine(img, [100 200], 0.75, 1.0)

    img = double(img);
    imsize=size(img);
    sqsize=max(imsize);
    cen=fix(sqsize/2)+1;
    [X,Y]= meshgrid((1:sqsize)-cen,(1:sqsize)-cen);
    R = 2* sqrt(X.^2 + Y.^2)./ sqsize; %normalized radius

    freq=0.5 * pi / (stopR - startR ) ; %1/4 period of cosine
    smthFilter= abs(cos(freq.*(R-startR))); %x shift origin to startR
    smthMask=(R>=startR);
    smthFilter(~smthMask)=1.0;
    smthFilter(R>=stopR)=0.0;
   
    if imsize(1) ~= imsize(2)
        szdif = floor((sqsize-imsize)./2);
        smthimg = padarray(img,szdif,0,'both') .* smthFilter;
    else
        smthimg = img .* smthFilter;
    end
    
    padimg = double(padarray(smthimg,padsize,0,'both')); 
    
end