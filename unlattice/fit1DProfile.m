function [bkgdFit, gof]= fit1DProfile(radii, radAvg, excludeInFit)
% [bkgdFit, gof]= fit1DProfile(radii, radAvg [, excludeInFit])
%
if nargin < 3
    %TODO: auto adjust according to iamge size and bin
    excludeInFit=3; 
end 
[xData, yData] = prepareCurveData( ...
                    radii(excludeInFit:end), radAvg(excludeInFit:end) );

% fit 1D profile with a smooth spline
ft = fittype( 'smoothingspline' );
opts = fitoptions( 'Method', 'SmoothingSpline' );
opts.Normalize = 'on';
opts.SmoothingParam = 0.95;

[bkgdFit, gof] = fit( xData, yData, ft, opts );

%debug%
show1DFit(bkgdFit, xData, yData);
%debug%

end

function show1DFit(bkgdFit, xData, yData)
figure( 'Name', 'bkgd fit' );
h = plot( bkgdFit, xData, yData );
legend( h, 'Radial average PS', 'smooth decay', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'radius (pix)', 'Interpreter', 'none' );
ylabel( 'Intensity', 'Interpreter', 'none' );
grid on; 
drawnow;
display(bkgdFit); 
end