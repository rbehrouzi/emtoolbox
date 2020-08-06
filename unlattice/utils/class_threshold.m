
maskParams.padSize=     64;    % pad size before and after images
maskParams.loLimAngst=  40;
maskParams.hiLimAngst=  3;
maskParams.smoothPix=   5;
%maskParams.sigma=       1.42;
maskParams.resolutionAngst= [10,7.0,5.8,4.78,3.8,3.4];
maskParams.threshold=       [6.0,5.0,4.0,3.6,3.4,3.1];

classesMrcsPath=  '/mnt/d/csparc/P1/J44/cryosparc_P1_J44_020_class_averages.mrc';
[classStack, metaData]= ReadMRC(classesMrcsPath); 
classNr = metaData.nz;
pixAngst = metaData.pixA;

% read all 2D class images
% and make masks for the ones referenced in particles data
% classNr indices remain consistent with latticeMask 
maskTemplate= padToSquare(false(size(classStack(:,:,1))),maskParams.padSize);
latticeMask= repmat(maskTemplate,1,1,size(classStack,3)); 
for cls= 1:classNr
    happy=false;
    while ~happy
        imgfft= fftshift(fft2(padToSquare(classStack(:,:,cls),maskParams.padSize)));
        logPS=log(abs(imgfft));
        latticeMask(:,:,cls)= createMask(logPS,maskParams,pixAngst,'threshold');
        [class_sub, classfft_sub]= applyMask(imgfft,latticeMask(:,:,cls), pixAngst, 'StdNormRand');
        showTemplateDiagnostics(classStack(:,:,cls),imgfft, class_sub, classfft_sub,maskParams.padSize); % display operation results on template
        
        prompt = {'Resolution rings in Angstroms:','Threshold values for each ring:'};
        dlgtitle = 'Threshold variation';
        dims = [1 35];
        definput = {num2str(maskParams.resolutionAngst,'%1.2f '),...
                    num2str(maskParams.threshold,'%1.2f ')};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        if isempty(answer) %cancel button
            happy=true;
        else
            maskParams.resolutionAngst = str2num(answer{1});
            maskParams.threshold= str2num(answer{2});
        end
    end
end
