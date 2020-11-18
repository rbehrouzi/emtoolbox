function profile = radialAvg(img, radii, smooth, center)
% profile = radialAvg(img, radii [, smooth=false, center ])
    % computes the radial average of the image IMG around the center point
    % radii is the vector of radii starting from zero
    % smooth default is false. if true, values are smoothed based on
    % distance from radius
    % center default is img center, i.e. floor(imsize+1)./2
    % Modified from script by Hugo Trentesaux 
    % https://www.mathworks.com/matlabcentral/profile/authors/11871854

    imsize = size(img);
    if nargin < 3
        smooth= false;
    end
    if nargin < 4
        center= floor((imsize+1)./2);
    end
    [X,Y]= meshgrid((1:imsize(2))-center(2), ...
                    (1:imsize(1))-center(1));
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