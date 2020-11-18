function paddedArray= padToSquare(inArray,padSize)
% Pad inArray with by padSizex factor (calculated on largest dim)
% dimension. Adjust padding in each dimension so that paddedArray has the
% same size in all dimensions
    imsize= size(inArray);
    longestDim= max(imsize);
    padding= floor( ((padSize -1)*longestDim)./2); 
    dimensionalPadding= padding+floor((longestDim-imsize)./2);
    paddedArray= padarray(inArray,  dimensionalPadding);
end