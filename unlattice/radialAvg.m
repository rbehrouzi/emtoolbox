function profile = radialAvg(img, radii, smooth, cenx, ceny)
% profile = radialAvg(img, radii [, smooth=false, cenx, ceny ])
    % computes the radial average of the image IMG around the cx,cy point
    % radii is the vector of radii starting from zero
    % smooth default is false. if true, values are smoothed based on
    % distance from radius
    % cenx, ceny default values are floor(imsize+1)./2)
    % Modified from script by Hugo Trentesaux 
    % https://www.mathworks.com/matlabcentral/profile/authors/11871854

    [xdim,ydim] = size(img);
    if nargin < 3
        smooth= false;
    end
    if nargin < 4
        cenx= fix(xdim./2)+1;
        ceny= fix(ydim./2)+1;
    end
    
    [X, Y] = meshgrid( (1:xdim)-cenx, (1:ydim)-ceny);
    R2 = X.^2 + Y.^2;
    profile = zeros(size(radii));
    for idx = 1:length(radii) % radius of the circle
        radius= radii(idx);
        mask = ((radius-1).^2<R2 & R2<(radius+1).^2); % smooth 1 px around the radius
        if smooth
            values = (1-abs( sqrt(R2(mask))-radius)) .* double(img(mask)); % smooth based on distance to ring
        else
            values = img(mask); % without smooth
        end
        
        profile(idx) = mean2(values);
    end
end