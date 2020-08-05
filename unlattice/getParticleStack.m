function [pStackIdx, pStackPath, pMetaData]= getParticleStack(starFilePath, mrcPathPrefix)
% 
% particleIdx@mrcstack_fullpath

[blockNames, blocks, ~] = ReadStarFile(starFilePath);
particles = ismember(blockNames,'data_particles');
if ~any(particles)
    fprintf("data_particles was not found in the STAR file.");
    return;
else
    particleData = blocks{particles};
    nparticles = size(particleData.rlnImageName,1);
    fprintf("found %d particles.\n", nparticles);
end

% compile list of mrc files and read header of the first 
pStackIdx = zeros(nparticles,1,'uint32');
pStackPath = cell(nparticles,1);
for p=1:nparticles
    tokens = regexp(particleData.rlnImageName{p},'(\d+)@(.+)','tokens');
    pStackIdx(p) =          str2double(tokens{1}{1,1});
    pStackPath{p} =         fullfile(mrcPathPrefix,tokens{1}{1,2});
    pMetaData.oriXAngst(p)= particleData.rlnOriginXAngst(p);
    pMetaData.oriYAngst(p)= particleData.rlnOriginYAngst(p);
    pMetaData.anglePsi(p)=  particleData.rlnAnglePsi(p);
    pMetaData.classNr(p)=   particleData.rlnClassNumber(p);
end

% get pixel and image size for particle images
opticsTblIdx= ismember(blockNames,'data_optics');
if any(opticsTblIdx)
% if relion 3.1 use optics table for everything, 
    opticsData = blocks{opticsTblIdx};
    pMetaData.pixA= opticsData.rlnImagePixelSize;
    if isfield(opticsData,'rlnImageSize')
        pMetaData.nx(:)= opticsData.rlnImageSize;
        pMetaData.ny(:)= opticsData.rlnImageSize;
    else
        [~, hdr]= ReadMRC(pStackPath{1},1,0);
        pMetaData.nx(:)= hdr.nx;
        pMetaData.ny(:)= hdr.ny;
    end        

elseif isfield(pMetaData,'rlnImagePixelSize')
% otherwise, check data_particles for pixelSize and first stack for size
    pMetaData.pixA= particleData.rlnImagePixelSize;
    [~, hdr]= ReadMRC(pStackPath{1},1,0);    
    pMetaData.nx(:)= hdr.nx;
    pMetaData.ny(:)= hdr.ny;

else
% otherwise, read mrc header of the first particle stack for everything
    fprintf("Pixel size was read from %s file header",pStackPath{1});
    [~, hdr]= ReadMRC(pStackPath{1},1,0);
    pMetaData.pixA=  hdr.pixA;
    pMetaData.nx(:)= hdr.nx;
    pMetaData.ny(:)= hdr.ny;
end
end