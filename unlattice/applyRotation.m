function rotImgs = applyRotation(img, nx, ny, anglePsi)
%
%
    % change center of rotation to the center of image from corner
    Rin = imref2d([nx, ny]);
    Rin.XWorldLimits = Rin.XWorldLimits-mean(Rin.XWorldLimits);
    Rin.YWorldLimits = Rin.YWorldLimits-mean(Rin.YWorldLimits);

    %https://www3.mrc-lmb.cam.ac.uk/relion/index.php/Conventions_%26_File_formats#Coordinate_system
    rotImgs= imwarp(img,Rin, randomAffine2d("Rotation",[anglePsi anglePsi]),'OutputView', Rin);

end