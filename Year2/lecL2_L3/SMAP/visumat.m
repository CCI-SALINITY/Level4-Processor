% visualisation des produits journaliers .mat pour verification

set(groot,'DefaultFigureColormap',jet)

fileD='smapD_20150402.mat';
fileA='smapA_20150402.mat';

for ii=2:9
    fileD(14)=num2str(ii)
    fileA(14)=num2str(ii)
    
    load(fileA);  %'SSS1A','SSS2A','tSSS1A','tSSS2A','WS1A','rain1A','WS2A','rain2A')
    load(fileD);
    
    figure
    subplot(4,2,1); hold on
    imagesc(SSS1A); caxis([32 38])
    axis tight; hold off
    subplot(4,2,2); hold on
    imagesc(SSS2A); caxis([32 38])
    axis tight; hold off
    subplot(4,2,3); hold on
    imagesc(SSS1D); caxis([32 38])
    axis tight; hold off
    subplot(4,2,4); hold on
    imagesc(SSS2D); caxis([32 38])
    axis tight; hold off
    subplot(4,2,5); hold on
    imagesc(WS1A); caxis([0 20])
    axis tight; hold off
    subplot(4,2,6); hold on
    imagesc(WS1D); caxis([0 20])
    axis tight; hold off
    subplot(4,2,7); hold on
    imagesc(WS2A); caxis([0 20])
    axis tight; hold off
    subplot(4,2,8); hold on
    imagesc(WS2D); caxis([0 20])
    axis tight; hold off

    figure
    subplot(3,2,1); hold on
    imagesc(tSSS1A); 
    axis tight; hold off
    subplot(3,2,2); hold on
    imagesc(tSSS2A); 
    axis tight; hold off
    subplot(3,2,3); hold on
    imagesc(tSSS1D); 
    axis tight; hold off
    subplot(3,2,4); hold on
    imagesc(tSSS2D); 
    axis tight; hold off
    

    
end