function [particleIdx, stackPath, alignInfo]= getStackHandle(starFilePath, mrcPathPrefix)
% 
% particleIdx@mrcstack_fullpath

[blockNames, blocks, ~] = ReadStarFile(starFilePath);
particles = ismember(blockNames,'data_particles');
if ~any(particles)
    fprintf("data_particles was not found in the STAR file.");
    return;
else
    pstruct = blocks{particles};
    nparticles = size(pstruct.rlnImageName,1);
    fprintf("found %d particles.\n", nparticles);
end

% compile list of mrc files and read header of the first 
particleIdx = zeros(nparticles,1,'uint32');
stackPath = cell(nparticles,1);
for p=1:nparticles
    tokens = regexp(pstruct.rlnImageName{p},'(\d+)@(.+)','tokens');
    particleIdx(p) = str2double(tokens{1}{1,1});
    stackPath{p} = fullfile(mrcPathPrefix,tokens{1}{1,2});
    alignInfo.oriXAngst(p)= pstruct.rlnOriginXAngst(p);
    alignInfo.oriYAngst(p)= pstruct.rlnOriginYAngst(p);
    alignInfo.anglePsi(p)= pstruct.rlnAnglePsi(p);
end

%read mrc header to get image sizes
%TODO: if relion 3.1 use optics table, otherwise write tmp.star file
[~, hdr]=ReadMRC(stackPath{1},1,0);    
alignInfo.nx(:)= hdr.nx;
alignInfo.ny(:)= hdr.ny;
alignInfo.pixA(:) = hdr.pixA;
end