function [newimg, newimgfft] = applyMask(imgfft,msk,mthd,pixAng)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    imgfft_unmsk = (~msk) .* imgfft;

    switch mthd
        case 'StdNormRand'
            % Random noise with standard Gaussian distribution 
            % mu = 0, sigma = 1

            imgfft_newvals = abs (msk .* normrnd(0,1,size(msk)));

        case 'Local4'
            % zippy local averaging; 
            % average four local areas (half unit cell apart)    
            
            local_val = abs(imgfft_unmsk) + abs (msk .* normrnd(0,1,size(msk))); 

            shiftsize =  floor(pixAng/116 * size(imgfft,1));   %half-unit cell for SA in pixels
            localavg = 0.25 *  circshift(local_val,[shiftsize  0]) + ...
                                        circshift(local_val,[-shiftsize 0]) + ... 
                                        circshift(local_val,[0    shiftsize]) + ... 
                                        circshift(local_val,[0   -shiftsize]); 
            imgfft_newvals = abs (msk .* localavg);

        otherwise
    end
    
    imgfft_phases = angle(msk .* imgfft);
    newimgfft = imgfft_unmsk + imgfft_newvals .* exp(1i .* imgfft_phases); 
    newimg = real(ifft2(ifftshift(newimgfft))); 
end

