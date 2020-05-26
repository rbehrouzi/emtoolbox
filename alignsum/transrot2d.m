function imagerot = transrot2d(image,degree,xshift, yshift)
%ROTATEIMAGE Summary of this function goes here
%   rotation is applied to center of image

    % To do: Special cases
%     case 0
%         imagerot = image;
%     case 90
%         imagerot = rot90(image);
%     case 180
%         imagerot = image(end:-1:1, end:-1:1);
%     case 270
%         imagerot = rot90(image(end:-1:1, end:-1:1));
%     % General rotations
%     otherwise
% 
    % Convert to radians and create transformation matrix
    % according to relion 
    a = degree*pi/180;
    cosine = cos(a); sine = sin(a);
    tform = [ cosine -sine  cosine*xshift-sine*yshift; ...
              sine   cosine cosine*yshift+sine*xshift; ...
                0        0            1                   ];
    invtform = inv(tform); %inverse tform
    % image size is kept constant
    [xdim,ydim,cdim] = size(image);
    imagerot = zeros([xdim, ydim, cdim],class(image));
    
    % rotation is applied to the center of the image
    % note: matlab arrays are 1-indexed
    xcen= int(xdim./2)+1; 
    ycen= int(ydim./2)+1;
    minx= -xcen + 1;
    maxx= xdim - xcen;
    miny= -ycen + 1;
    maxy= ydim - ycen;

    % Map all pixels of the transformed image to the original image
    for ii = 1:ydim
        dest = [1 - xcen;...   %rotation applied to center
                ii - ycen;...
                1];
        for jj = 1:xdim
            source = invtform*dest;
            if all(source >= 1) && all(source <= [xdim ydim])

                % Get all 4 surrounding pixels
                C = ceil(source);
                F = floor(source);

                % Compute the relative areas
                weights = [...
                    ((C(2)-source(2))*(C(1)-source(1))),...
                    ((source(2)-F(2))*(source(1)-F(1)));
                    ((C(2)-source(2))*(source(1)-F(1))),...
                    ((source(2)-F(2))*(C(1)-source(1)))];

                % Extract colors and re-scale them relative to area
                cols = weights .* double(image(F(1):C(1),F(2):C(2),:));

                % Assign                     
                imagerot(ii,jj,:) = sum(sum(cols),2);

            end
        end
    end        
%end
end

