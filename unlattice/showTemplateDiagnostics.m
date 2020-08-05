function showTemplateDiagnostics(img, imgfft, img_sub, imgfft_sub,padSize)
    logPS=log(abs(imgfft));
    imsize= size(img);
    directional_padsize= padSize+max(imsize)-imsize;
    figure('Renderer', 'painters', 'Position', [1500 100 800 1200]); 
    ax_=subplot(3,2,1); imshow(abs(img)); set(ax_,'CLimMode','auto');ax_.Title.String='Original Image';
    ax_=subplot(3,2,2); imshow(logPS); set(ax_,'CLimMode','auto');ax_.Title.String='Power Spectrum (log)';
    ax_=subplot(3,2,3); imshow(img_sub); set(ax_,'CLimMode','auto', ...
        'Xlim',[directional_padsize(1),directional_padsize(1)+imsize(1)],...
        'Ylim',[directional_padsize(2),directional_padsize(2)+imsize(2)]); 
    ax_.Title.String='Lattice subtracted Image (FFT padded)';
    ax_=subplot(3,2,4); imshow(log(abs(imgfft_sub))); set(ax_,'CLimMode','auto');ax_.Title.String='Masked Power Spectrum (log)'; 
    %circles = insertShape(abs(log(imgfft)),'circle',[imgcenter(:)' innerring; imgcenter(:)' outerring],'color',{'blue','red'});
    %imshow(circles);
    ax_=subplot(3,2,[5,6]);hold on;
    plot(ax_,mean(abs(imgfft)),'DisplayName','before subtraction'); 
    plot(ax_,mean(abs(imgfft_sub)),'DisplayName','after subtraction');
    hold off; legend('boxoff');
    drawnow;

    WriteMRC(img_sub,1,'subtracted_template.mrc');
end  
