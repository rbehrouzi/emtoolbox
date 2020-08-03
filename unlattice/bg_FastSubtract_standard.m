function [subtracted] = bg_FastSubtract_standard(file_in) 
%bg_FastSubtract(2d_file,edge) : (name,30) :
% => produce background subtracted 2D matrix (background was from smoothing fucntion
% edge size should be multiple of 10
%ouput is 2D matrix
%Oct 27 2017 

[xsize, ysize] = size(file_in);

if( xsize < 500 && ysize < 500)
   smoothed = medfilt2(file_in,[10 10]); 
   edge  = 10;
else 
     shrink = 500/xsize; 
     blow   = xsize/500;
%     blow = 5 ; 
     small = imresize(file_in,shrink); 
     small  = medfilt2(small, [10 10]);   
     smoothed = imresize(small, [xsize  ysize]);
     edge   = 10*blow;  
end 
%image_smooth = 'smooth_out.mrc';
%WriteMRC(smoothed,1,image_smooth);

subtracted = file_in - smoothed ; 
block_mean = ones([xsize, ysize]);
mean_value = mean(mean(subtracted));
block_mean = block_mean * mean_value;

% edge hiding : edge shows erroneous drop
edge = floor(edge); 
subtracted(1:edge,:)    = block_mean(1:edge,:);
subtracted(xsize - edge: xsize,:) = block_mean(xsize - edge: xsize,:);
subtracted(:,1:edge)                = block_mean(:,1:edge);
subtracted(:,ysize - edge: ysize) = block_mean(:,ysize - edge: ysize);
%image_sub = 'subtract_out.mrc';
%WriteMRC(subtracted,1,image_sub);

