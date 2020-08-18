function imgsub = radialSub(img, radii, values, minRadius)
% imgsub = radialSub(img, radii, values)
    % subtract values from image pixels
    % Specifically, values(n) is subtracted from all pixels falling on the 
    % ring between radii(n-1) and radii(n).
    % radii(0) is set to minRadius, or 0 as default
    % radii elements that are smaller than minRadius are ignored, i.e.
    % pixels inside minRadius are not affected by radialSub


    if nargin < 4
        minRadius = 0;
    end
    
    [xdim,ydim] = size(img);
    cenx= fix(xdim./2)+1;
    ceny= fix(ydim./2)+1;
    
    [X, Y] = meshgrid( (1:xdim)-cenx, (1:ydim)-ceny);
    R2 = X.^2 + Y.^2;
    imgsub = zeros(size(img));
    for idx = 1:length(radii) % radius of the circle
        if idx==1
            inr2 = minRadius.^2;
        else
            inr2= max( minRadius, radii(idx-1)).^2;
        end
        outr2= radii(idx).^2;
        mask = (inr2 < R2 & R2 < outr2); 
        imgsub(mask) = double(img(mask)) - values(idx);
    end
end