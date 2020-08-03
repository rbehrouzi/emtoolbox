function [mask_inner] = bg_drill_hole(box_size,r) 
%bg_drill_hole(box_size,radius) => make a hole in the middle 
%within radius and put 1, otherwise 0
%ouput is 2D matrix

mask_inner = zeros(box_size,box_size);
box_center = fix(box_size/2);
for (ii = box_center - r: box_center + r)
  for (jj = box_center - r: box_center + r)
     if( sqrt((ii-box_center)^2 + (jj -box_center)^2) < r )
        mask_inner(ii,jj) = 1;
     else
        mask_inner(ii,jj) = 0;
     end
  end
end

