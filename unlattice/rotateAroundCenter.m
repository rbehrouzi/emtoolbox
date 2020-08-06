function rotImgs = rotateAroundCenter(img, anglePsi)
%
%
% see  https://www3.mrc-lmb.cam.ac.uk/relion/index.php/Conventions_%26_File_formats#Coordinate_system

    % change center of rotation from corner to the center of image 
    Rin = imref2d(size(img));
    Rin.XWorldLimits = Rin.XWorldLimits-mean(Rin.XWorldLimits);
    Rin.YWorldLimits = Rin.YWorldLimits-mean(Rin.YWorldLimits);
    rotImgs= imwarp(img,Rin, randomAffine2d("Rotation",[anglePsi anglePsi]),'OutputView', Rin);

end