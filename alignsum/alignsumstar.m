function [sumaligned, sumorigin] = alignsumstar (starfilepath, mrcpath_prefix,logger)

    tic;
    [blockNames, blocks, ~] = ReadStarFile(starfilepath);
    toc;
    particles = ismember(blockNames,'data_particles');
    if ~any(particles)
        disp("data_particles section was not found in the STAR file.");
        return;
    else
        pstruct = blocks{particles};
        nparticles = size(pstruct.rlnImageName,1);
        fprintf("found %d particles.\n", nparticles);
    end

    % compile list of mrc files and read header of the first 
    idxinmrc = zeros(nparticles,1,'uint32');
    stackfname = cell(nparticles,1);
    for p=1:nparticles
        tokens = regexp(pstruct.rlnImageName{p},'(\d+)@(.+)','tokens');
        idxinmrc(p) = str2double(tokens{1}{1,1});
        stackfname{p} = mrcpath_prefix + tokens{1}{1,2};
    end

    %read mrc header to get image sizes 
    [~, hdr]=ReadMRC(stackfname{1},1,0);    
    sumorigin = zeros([hdr.nx, hdr.ny]);
    sumaligned = zeros([hdr.nx, hdr.ny]);
    % change center of rotation to the center of image from corner
    Rin = imref2d([hdr.nx, hdr.ny]);
    Rin.XWorldLimits = Rin.XWorldLimits-mean(Rin.XWorldLimits);
    Rin.YWorldLimits = Rin.YWorldLimits-mean(Rin.YWorldLimits);
    %convert shifts from Ang to pix
    OriginXpix = round(pstruct.rlnOriginXAngst/hdr.pixA); %convert to pixels
    OriginYpix = round(pstruct.rlnOriginYAngst/hdr.pixA);

    %% read particles and average
    openstackname = ""; fileno = 0;
    for row=1:nparticles
        if ~strcmpi(stackfname{row},openstackname)
            openstackname=stackfname{row};
            [stack, ~]=ReadMRC(stackfname{row});
            fileno = fileno + 1;
            fprintf(logger,"Now reading file %d. Total particles read so far is %d.\r",fileno, row);
        end
        m1=stack(:,:,idxinmrc(row)); 
        %https://www3.mrc-lmb.cam.ac.uk/relion/index.php/Conventions_%26_File_formats#Coordinate_system
        tfmatrix = randomAffine2d(...
               "Rotation",[pstruct.rlnAnglePsi(row) pstruct.rlnAnglePsi(row)],... % checked with relion
               "XTranslation",[-OriginXpix(row) -OriginXpix(row)],...%new = old - origin
               "YTranslation",[-OriginYpix(row) -OriginYpix(row)]...
               );
        sumaligned = sumaligned + imwarp(m1,Rin,tfmatrix,'OutputView',Rin);
        sumorigin = sumorigin + m1;
    end
return;
