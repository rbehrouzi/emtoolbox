function paddedArray= padToSquare(inArray,padSize)
% Pad inArray with at least padsize elements on before and after each
% dimension. Adjust padding in each dimension so that paddedArray has the
% same size in all dimensions
    imsize= size(inArray);
    directional_padsize= padSize+max(imsize)-imsize;
    paddedArray= padarray(inArray,  directional_padsize);
end