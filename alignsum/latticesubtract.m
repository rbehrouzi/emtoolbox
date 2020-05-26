%% 1. read mrc file and crop image

clear variables;
%close all;
clc;
%figure;
%restoredefaultpath;
%matlabrc
%addpath  /media/HDD2-8TB/cate/BGH_2A_RIB/K3_strep_sub/00_script  ; 

%% PARAMETER INITIALIZE  
% Pad_Box_Size =         4400;
Pad_Origin_X  =        200 ;
Pad_Origin_Y   =       200 ;  %% Changed to 1000 for K3
Low_res_lim_Ang  =   90 ;
Hi_res_lim_Ang =   12  ;    %% Changed K3, Will be (2 * Pixel_Ang + 0.2 Ang)
Pixel_Ang  =           1.13 ;
Threshold  =           1.57 ;
expand_pixel = 1; 
pad_out_opt =   0; 

%  PARAMETER READING
% filein = fopen('PARAMETER','r') ;
% Array = textscan(filein, '%s  %s');
% name_list = Array{1,1}   ; 
% num_list  = Array{1,2}   ; 
% list_count = size(name_list,1);
% 
% for ii = 1:list_count
%     if ( contains(name_list{ii}, "inside_radius_Ang",'IgnoreCase',true) )
%         Low_res_lim_Ang  =  str2double(num_list{ii})  ;
%     elseif ( contains(name_list{ii}, "outside_radius_Ang",'IgnoreCase',true) )
%         Hi_res_lim_Ang  =  str2double(num_list{ii})  ;
%     elseif ( contains(name_list{ii}, "pixel_Ang",'IgnoreCase',true) )
%         Pixel_Ang  =  str2double(num_list{ii})  ;
%     elseif ( contains(name_list{ii}, "threshold",'IgnoreCase',true) )
%         Threshold   =  str2double(num_list{ii})  ; 
%     end
% end
% fclose(filein);

%Hi_res_lim_Ang = Pixel_Ang * 2 + 0.2;  %%  Changed for K3 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 2. IMAGE FILE READ IN and Auto Padding
name_list =  'class4.mrc'; 
img = ReadMRC(name_list);

%%% auto_padding : bgh Oct-18 2017
img_left = img(:,1);
img_top  = img(1,:);
dummy = size(img);
row_count = dummy(1) ;
column_count = dummy(2) ;
Pad_Box_Size = max(row_count, column_count) + Pad_Origin_X*2  ; 
Pad_Box_Size = round(Pad_Box_Size / 10) * 10 ; %%  bg_FastSubtract imresize limits box_size choice  
img_right = img(:,column_count);
img_bottom = img(row_count,:);
mean_edge  =  ( mean(img_left) + mean(img_right) + mean(img_top) + mean(img_bottom) ) /4 ;  %%% just information
mean_all = mean(mean(img)) ;
left_st_minus_1 = Pad_Box_Size ; 

corner_pad_stROW = Pad_Origin_X - 1; 
corner_pad_stCOL = Pad_Origin_Y - 1; 

coner_pad_endROW = Pad_Box_Size - row_count - corner_pad_stROW  ;        
coner_pad_endCOL = Pad_Box_Size - column_count - corner_pad_stCOL ; 

% exit ;  %%%% K3 
pad_1 =     padarray(img,   [ corner_pad_stROW   corner_pad_stCOL ],mean_all, 'pre');
pad_image = padarray(pad_1, [ coner_pad_endROW   coner_pad_endCOL ], mean_all, 'post');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 3. lattice subtraction

unit_cell_pixel_Fourier = Pixel_Ang/57 * Pad_Box_Size;
img2 = double(pad_image);
%   imshow(img2,[]);

lattice_sub = normAboveThreshold(img2,Threshold,expand_pixel,Pixel_Ang,Low_res_lim_Ang,Hi_res_lim_Ang);
%lattice_sub = bg_push_by_rot(img2,Threshold,expand_pixel,Pixel_Ang,Low_res_lim_Ang,Hi_res_lim_Ang);

%% 4. output
%   figure; imshow(lattice_sub,[]);
name_sub = 'output.mrc';  
out_sub = lattice_sub ; 
if ( pad_out_opt == 0 ) 
    x_cut = Pad_Origin_X + row_count - 1;
    y_cut = Pad_Origin_Y + column_count - 1;  
    out_sub = lattice_sub(Pad_Origin_X:x_cut, Pad_Origin_Y:y_cut); 
end  
WriteMRC(out_sub,1,name_sub);

%%%%%%%%%%%%%%%%%%
   
