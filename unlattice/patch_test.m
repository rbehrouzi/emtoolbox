addpath("utils/","../EMIO_parallel/","../EMIODist2/");
impathbase='/data/reza/datasets/20200410_cmplx3_SA/average/10Apr2020_';
imlowdef=ReadMRC([impathbase,'208-1.mrc']);
img=permute(imlowdef,[2,1]);

%calcualte background profile on whole micrograph and use it for patches
ps=log(abs(fft2xSmooth(img,'original')));
[psbkcor, bkgd1DFit] = subtractPsBkgd(ps, 10,10);
psmax = max(ps,[],'all');
figure;imshow(psbkcor);set(gca,'CLim',[0 0.1*psmax]);title('background sub');

imsize = size(img);
patchno=[2 2];
patchsizes=floor(imsize./patchno);
patchxup=ones(1,patchno(1)+1);
patchyleft=ones(1,patchno(2)+1);
for ii=2:patchno(1)
    patchxup(ii)=patchxup(ii-1)+patchsizes(1);
end
patchxup(end)=imsize(1);

for jj=2:patchno(2)
    patchyleft(jj)=patchyleft(jj-1)+patchsizes(2);
end
patchyleft(end)=imsize(2);
nplots=patchno(1)*patchno(2);
ax_ = cell(1,nplots);
figure;
tiledlayout(patchno(1),patchno(2),'TileSpacing','none','Padding','none')
for ii=1:patchno(1)
    for jj=1:patchno(2)
        plotidx = (ii-1)*patchno(1) + jj;
        imgpatch=img(patchxup(ii)  :patchxup(ii+1)   ,...
                     patchyleft(jj):patchyleft(jj+1));
        imgpatchfft= fft2xSmooth(imgpatch);
        absimgpatchfft=abs(imgpatchfft);
        pspatch=log(abs(absimgpatchfft));
        [pspatchbkcor, ~]= subtractPsBkgd(pspatch,5,10, bkgd1DFit);
        ax_{plotidx}=nexttile;
        imshow(pspatchbkcor); 
        center = fix(size(pspatchbkcor)./2)+1;
        pspmax = max(pspatchbkcor(center(1)+10:end,center(2)+10:end),[],'all');
        set(ax_{plotidx},'CLim',[0, pspmax]);

    end
end
linkaxes([ax_{:}]);