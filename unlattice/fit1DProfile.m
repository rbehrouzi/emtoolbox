function [bkgdFit, gof]= fit1DProfile(radii, radAvg)
% [bkgdFit, gof]= fit1DProfile(radii, radAvg)
%

%TODO: auto adjust according to iamge size and bin
excludeInFit=10; 
[xData, yData] = prepareCurveData( ...
                    radii(excludeInFit:end), radAvg(excludeInFit:end) );

% fit 1D profile with exponential
ft = fittype( 'c-a*(1-exp(-b*x))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0];
opts.StartPoint = [1 0.005 1];
opts.Upper = [100 0.001 100];
[bkgdFit, gof] = fit( xData, yData, ft, opts );

%debug%
show1DFit(bkgdFit, xData, yData);
%debug%

end

function show1DFit(bkgdFit, xData, yData)
figure( 'Name', 'bkgd fit' );
h = plot( bkgdFit, xData, yData );
legend( h, 'Radial average PS', 'exponential decay', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'radius (pix)', 'Interpreter', 'none' );
ylabel( 'Intensity', 'Interpreter', 'none' );
grid on; 
drawnow;
display(bkgdFit); 
end