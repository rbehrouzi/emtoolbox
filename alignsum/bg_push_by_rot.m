function [push_down] = bg_push_by_rot(img,threshold,expand_pixel,Pixel_Ang,Inside_Radius_Ang,Outside_Radius_Ang)
% bg_push_down_thresh(img,threshold,expand_pixel) 
% read in img and mask area higher than threshold with the expanded_pixels with circular shape
% Oct 30 2017
img2=double(img);
box_size = size(img2,1);

%%%   radius_pixel_for_given_resoln  = Nyq_Ang * 0.5 /resoln_Ang * box = Pixel_Ang / resoln_Ang * box   
%%%   rad_inside and rad_outside are loosely named, they meant to produce opposite mask 
rad_inside_pixel  = (Pixel_Ang/Inside_Radius_Ang) * box_size  ; 
rad_outside_pixel  = (Pixel_Ang/Outside_Radius_Ang) * box_size  ;  

central_radius_not_delete = fix(rad_inside_pixel) ;
outside_radius_not_delete = fix(rad_outside_pixel) ;

if (outside_radius_not_delete  >   box_size/2 -1 )
     outside_radius_not_delete  =  floor(box_size/2 - 1);
end

%% 2. compute FFT and save power for annotations

y = fft2(img2);y = fftshift(y);
%%%  radial mask 
%half_box = floor(box_size/2) - 2; 
%mask_full = bg_drill_hole(box_size,half_box); 
%y = mask_full .* y; 

pw=abs(log(y));
sub_ = bg_FastSubtract_standard(pw);
figure; ax_=subplot(3,2,4); imshow(sub_); set(ax_,'CLimMode','auto');ax_.Title.String='original';

%figure;imshow(sub_,[]);

mask_center = bg_drill_hole(box_size,central_radius_not_delete); 
mask_outside = bg_drill_hole(box_size,outside_radius_not_delete);

%%write_image =  'sub_.mrc';
%%WriteMRC(sub_,1,write_image); 

mask = ( sub_  > threshold) ;
mask =  ~mask +  ~mask_outside  + mask_center   ;  

mask_final = ( mask(:,:) ~= 0 ); %Error: this eliminates bandpass masking
ax_=subplot(3,2,1); imshow(mask_final); set(ax_,'CLimMode','auto');ax_.Title.String='mask'; 

%%image_check =  'out_mask.mrc'; 
%%WriteMRC(mask_final,1,image_check) ; 

%%figure;imshow(mask_final,[]);

rad_expand   = fix(expand_pixel/2) - 1;

circle = bg_drill_hole(expand_pixel,rad_expand);

%%figure;imshow(circle,[]);

mask_rev  = filter2(circle,~mask_final);
mask_final = ~mask_rev;
ax_=subplot(3,2,2); imshow(mask_final); set(ax_,'CLimMode','auto');ax_.Title.String='filtered mask';
%%%% Figure out to pick out area from masked area  

y2 = y ;
middle = floor(box_size/2);
y2_strip = y2(middle - 20: middle + 20, :) ;
push_y2_all = mean(abs(y2_strip));
ax_=subplot(3,2,3);plot(ax_,push_y2_all,'DisplayName','before norm'); 

y2_A = mask_final .* y2;

%%  zippy local averaging
%% average four local areas (half unit cell apart)    
shift_pixel =  floor(Pixel_Ang/116 * box_size);   
neg_shift = shift_pixel  * -1 ;

  abs_y2_A = abs(y2_A); 
  ax_=subplot(3,2,5); imshow(abs(log(y2_A))); set(ax_,'CLimMode','auto');ax_.Title.String='y2_A';

  shifted = circshift(abs_y2_A,[shift_pixel  0]);
  shifted = shifted + circshift(abs_y2_A,[neg_shift  0]); 
  shifted = shifted + circshift(abs_y2_A,[0    shift_pixel]); 
  shifted = shifted + circshift(abs_y2_A,[0    neg_shift]); 

shift_ave = shifted ./4;
%%random_noise = random('Normal',0,1,box_size,box_size) ;
%%shift_ave = shift_ave .*  random_noise; 

y2_B = ~mask_final .*  shift_ave;
value_y2_B     = abs(y2_B);  %% redundant but in case  


angle_y2_ori_B = angle(y .* ~mask_final) ;
%angle_y2_ori_B = angle(y2_B .* ~mask_final) ;

y2 = y2_A + value_y2_B .* exp(1i .* angle_y2_ori_B)  ; 
ax_=subplot(3,2,6); imshow(abs(log(y2))); set(ax_,'CLimMode','auto'); ax_.Title.String='y2';
%hold on 

middle = floor(box_size/2); 
y2_strip = y2(middle - 20: middle + 20, :) ;
push_y2_all = mean(abs(y2_strip));
ax_=subplot(3,2,3); hold on; plot(ax_,push_y2_all,'DisplayName','after norm');
hold off; set(ax_,'Xlim',[middle-100, middle+100]);

y2 = ifftshift(y2);
x2 = ifft2(y2);
push_down = real(x2); 

