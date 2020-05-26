function [alignedtotal, origintotal] = alignsumstar_par (starfilepath, mrcpath_prefix,logger)
    tic;
    [blockNames, blocks, ~] = ReadStarFile_par(starfilepath);
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
    % center image on origin, so that imwarp rotation is applied to center
    Rin = imref2d([hdr.nx, hdr.ny]);
    Rin.XWorldLimits = Rin.XWorldLimits-mean(Rin.XWorldLimits);
    Rin.YWorldLimits = Rin.YWorldLimits-mean(Rin.YWorldLimits);
    %convert shifts from Ang to pix
    OriginXpix = round(pstruct.rlnOriginXAngst/hdr.pixA); %convert to pixels
    OriginYpix = round(pstruct.rlnOriginYAngst/hdr.pixA);

    starData = distributed.cell(5,nparticles);
    starData(1,:) = stackfname;
    starData(2,:) =  num2cell(idxinmrc);
    starData(3,:) =  num2cell(-OriginXpix); %target = source - origin
    starData(4,:) =  num2cell(-OriginYpix);
    starData(5,:) =  num2cell(pstruct.rlnAnglePsi); %checked with relion
    spmd
        c = getLocalPart(starData);
        lab_nparticles = size(c,2);
        fprintf(logger,"Processing %d particles.\n",lab_nparticles);
        thisstack = "";
        for ii=1:lab_nparticles
            if ~strcmpi(c{1,ii},thisstack)
                thisstack=c{1,ii};
                [stack, ~]=ReadMRC(thisstack);
            end
            slice=stack(:,:,c{2,ii}); 
            tfmatrix = randomAffine2d(...
               "XTranslation", [c{3,ii} c{3,ii}] ,...
               "YTranslation", [c{4,ii} c{4,ii}] ,...
               "Rotation",     [c{5,ii} c{5,ii}] );
            sumaligned = sumaligned + imwarp(slice,Rin,tfmatrix,'OutputView',Rin);
            sumorigin = sumorigin + slice;
        end
    end
    %sum returns from parallel workers
    alignedtotal= zeros([hdr.nx, hdr.ny]);
    origintotal = zeros([hdr.nx, hdr.ny]);
    for i=1:size(sumaligned,2)
        alignedtotal= alignedtotal + sumaligned{i};
        origintotal= origintotal + sumorigin{i};
    end    
return 