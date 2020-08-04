clear variables;
addpath('../EMIODist2');

%mrcpath_prefix = "/data/reza/csparc2/P12/";
%starfilepath = "/ssd/20200410_csparc_sa_aligned.star";
mrcpath_prefix = "";
starfilepath = "./aligned_ctf.star";
tic;
%[sumaligned, sumorigin] = alignsumstar(starfilepath,mrcpath_prefix,1);
[sumaligned, sumorigin] = alignsumstar_par(starfilepath,mrcpath_prefix,1); %parallel
toc;
fftaligned = fftshift(fft2(sumaligned));%,2^nextpow2(600),2^nextpow2(600)));
fftorigin = fftshift(fft2(sumorigin));%,2^nextpow2(600),2^nextpow2(600)));
% figure;
% imshowpair(sumorigin, sumaligned, 'montage');
% figure;
% imshowpair(abs(fftshift(fftorigin)),abs(fftshift(fftaligned)), 'montage');

%%
figure;
ax_=subplot(2,2,1);
image(sumorigin,'Parent',ax_,'CDataMapping','scaled',...
    'Interpolation','bilinear',...
    'AlphaDataMapping','none');
title('Sum of unaligned particles');
ax_=subplot(2,2,2);
image(abs(log(fftorigin)),'Parent',ax_,'CDataMapping','scaled',...
    'Interpolation','bilinear',...
    'AlphaDataMapping','none');
title('Unaligned FFT');
set(ax_,'XLim',[200,400],'YLim',[200,400]);
ax_=subplot(2,2,3);
image(sumaligned,'Parent',ax_,'CDataMapping','scaled',...
    'Interpolation','bilinear',...
    'AlphaDataMapping','none');
title('Sum of aligned particles');
ax_=subplot(2,2,4);
image(abs(log(fftaligned)),'Parent',ax_,'CDataMapping','scaled',...
    'Interpolation','bilinear',...
    'AlphaDataMapping','none');
title('Aligned FFT');
%set(ax_,'XLim',[200,400],'YLim',[200,400]);

