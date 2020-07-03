% comparaison asc-desc et for-aft
% L2C_v3 et v4

clear

SMAPvers='v4';  % v3 ou v4

set(groot,'DefaultFigureColormap',jet)

plot_fig=1;

year0=2016;

yearc=num2str(year0);
% dires
dires=['plot_' yearc '_vocean_' SMAPvers '\'];
if exist(dires)==0; mkdir(dires); end;

% chargement ISAS
load('G:\dataSMOS\CATDS\repro_2017\isas_CATDS')
yearisas=datemois_isas(:,2);
moisisas=datemois_isas(:,1);
nlon=length(lon_fixgrid);
nlat=length(lat_fixgrid);
lat0=lat_fixgrid;
lon0=lon_fixgrid;

% chargement dmin EASE
load('G:\dataSMOS\CATDS\repro_2017\maskdmin_ease2.mat');
indcoast=find(dmin<0);

% lecture des fichiers journaliers
pathfile=['I:\SMAP_data\RSS\L2C_' SMAPvers '\file_mat_40km\'];
dirfile=dir(pathfile);

[lat00,lon00]=meshgrid(lat0,lon0);
nnk=round(length(dirfile)/4);

mapSSS1A=NaN(nnk,nlon,nlat);
mapSSS1D=NaN(nnk,nlon,nlat);
mapSSS2A=NaN(nnk,nlon,nlat);
mapSSS2D=NaN(nnk,nlon,nlat);

kA=0; kD=0;
for ifi=3:length(dirfile)
    ifi
    namefile=dirfile(ifi).name;
    yearn=str2num(namefile(7:10));
    if yearn==year0
        pathnamefile=[pathfile dirfile(ifi).name];
        load(pathnamefile);    %'SSS1A','SSS2A','tSSS1A','tSSS2A','WS1A','WS2A','rain1A','rain2A'
        if namefile(5)=='A'
            kA=kA+1;
            SSS1(indcoast)=NaN;
            SSS2(indcoast)=NaN;
            mapSSS1A(kA,:,:)=SSS1;
            mapSSS2A(kA,:,:)=SSS2;
            dayA(kA)=str2num(namefile(13:14));
            monA(kA)=str2num(namefile(11:12));
        else
            kD=kD+1;
            SSS1(indcoast)=NaN;
            SSS2(indcoast)=NaN;
            mapSSS1D(kD,:,:)=SSS1;
            mapSSS2D(kD,:,:)=SSS2;
            dayD(kD)=str2num(namefile(13:14));
            monD(kD)=str2num(namefile(11:12));
        end
    end
   
end
kA
kD
mapSSS1A=mapSSS1A(1:kA,:,:);
mapSSS2A=mapSSS2A(1:kA,:,:);
mapSSS1D=mapSSS1D(1:kD,:,:);
mapSSS2D=mapSSS2D(1:kD,:,:);

% comparaison moyenne sur l'annee (carte)

meanSSS1A=squeeze(nanmean(mapSSS1A));
meanSSS2A=squeeze(nanmean(mapSSS2A));
meanSSS1D=squeeze(nanmean(mapSSS1D));
meanSSS2D=squeeze(nanmean(mapSSS2D));

stdSSS1A=squeeze(nanstd(mapSSS1A));
stdSSS2A=squeeze(nanstd(mapSSS2A));
stdSSS1D=squeeze(nanstd(mapSSS1D));
stdSSS2D=squeeze(nanstd(mapSSS2D));

figure
subplot(2,2,1)
hold on
title(['meanSSS ' yearc  ', A, for'])
imagesc(lon0,lat0,meanSSS1A')
axis tight
caxis([32 38])
colorbar
hold off
subplot(2,2,2)
hold on
title('A, aft')
imagesc(lon0,lat0,meanSSS2A')
axis tight
caxis([32 38])
colorbar
hold off
subplot(2,2,3)
hold on
title(['meanSSS ' yearc ', D, for'])
imagesc(lon0,lat0,meanSSS1D')
axis tight
caxis([32 38])
colorbar
hold off
subplot(2,2,4)
hold on
title('D, aft')
imagesc(lon0,lat0,meanSSS2D')
axis tight
caxis([32 38])
colorbar
hold off
saveas(gcf,[dires 'mapSSSmean_' yearc],'png')
saveas(gcf,[dires 'mapSSSmean_' yearc],'fig')

figure
subplot(2,2,1)
hold on
title(['stdSSS ' yearc ', A, for'])
imagesc(lon0,lat0,stdSSS1A')
axis tight
caxis([0 2])
colorbar
hold off
subplot(2,2,2)
hold on
title('A, aft')
imagesc(lon0,lat0,stdSSS2A')
axis tight
caxis([0 2])
colorbar
hold off
subplot(2,2,3)
hold on
title(['stdSSS ' yearc ', D, for'])
imagesc(lon0,lat0,stdSSS1D')
axis tight
caxis([0 2])
colorbar
hold off
subplot(2,2,4)
hold on
title('D, aft')
imagesc(lon0,lat0,stdSSS2D')
axis tight
caxis([0 2])
colorbar
hold off
saveas(gcf,[dires 'mapSSSstd_' yearc],'png')
saveas(gcf,[dires 'mapSSSstd_' yearc],'fig')

% difference asc-desc
figure
subplot(2,1,1)
hold on
title(['diff A-D '  yearc  ', for'])
imagesc(lon0,lat0,meanSSS1A'-meanSSS1D')
axis tight
caxis([-0.5 0.5])
colorbar
hold off
subplot(2,1,2)
hold on
title(['diff A-D ' yearc  ', aft'])
imagesc(lon0,lat0,meanSSS2A'-meanSSS2D')
axis tight
caxis([-0.5 0.5])
colorbar
hold off
saveas(gcf,[dires 'diffSSSmean_A_D_' yearc],'png')
saveas(gcf,[dires 'diffSSSmean_A_D_' yearc],'fig')

% difference aft-for
figure
subplot(2,1,1)
hold on
title(['diff aft-for ' yearc ', A'])
imagesc(lon0,lat0,meanSSS1A'-meanSSS2A')
axis tight
caxis([-0.5 0.5])
colorbar
hold off
subplot(2,1,2)
hold on
title(['diff aft-for ' yearc ', D'])
imagesc(lon0,lat0,meanSSS1D'-meanSSS2D')
axis tight
caxis([-0.5 0.5])
colorbar
hold off
saveas(gcf,[dires 'diffSSSmean_aft_for_' yearc],'png')
saveas(gcf,[dires 'diffSSSmean_aft_for_' yearc],'fig')

% comparaison ISAS mois par mois

ki=0;
mapISASreg0=NaN(365,length(lon0),length(lat0));
biaslat1A=NaN(12,length(lat0));
stdbiaslat1A=NaN(12,length(lat0));
biaslat2A=NaN(12,length(lat0));
stdbiaslat2A=NaN(12,length(lat0));
biaslat1D=NaN(12,length(lat0));
stdbiaslat1D=NaN(12,length(lat0));
biaslat2D=NaN(12,length(lat0));
stdbiaslat2D=NaN(12,length(lat0));

for imo=1:12
    imo
    indA=find(monA==imo);
    meanmonthSSS1A=squeeze(nanmean(mapSSS1A(indA,:,:)));
    meanmonthSSS2A=squeeze(nanmean(mapSSS2A(indA,:,:)));
    stdmonthSSS1A=squeeze(nanstd(mapSSS1A(indA,:,:)));
    stdmonthSSS2A=squeeze(nanstd(mapSSS2A(indA,:,:)));
    
    indD=find(monD==imo);
    meanmonthSSS1D=squeeze(nanmean(mapSSS1D(indD,:,:)));
    meanmonthSSS2D=squeeze(nanmean(mapSSS2D(indD,:,:)));
    stdmonthSSS1D=squeeze(nanstd(mapSSS1D(indD,:,:)));
    stdmonthSSS2D=squeeze(nanstd(mapSSS2D(indD,:,:)));
    
    indISAS=find(yearisas==(year0-2000) & moisisas==imo);
    mapISASreg=squeeze(isasSSS(indISAS,:,:));
    
    for ii=1:length(indA)
        ki=ki+1;
        mapISASreg0(ki,:,:)=mapISASreg;
    end
    
    % biais latitudinal
    biaslat1A(imo,:)=nanmean(meanmonthSSS1A-mapISASreg);
    stdbiaslat1A(imo,:)=nanstd(meanmonthSSS1A-mapISASreg);
    biaslat2A(imo,:)=nanmean(meanmonthSSS2A-mapISASreg);
    stdbiaslat2A(imo,:)=nanstd(meanmonthSSS2A-mapISASreg);
    biaslat1D(imo,:)=nanmean(meanmonthSSS1D-mapISASreg);
    stdbiaslat1D(imo,:)=nanstd(meanmonthSSS1D-mapISASreg);
    biaslat2D(imo,:)=nanmean(meanmonthSSS2D-mapISASreg);
    stdbiaslat2D(imo,:)=nanstd(meanmonthSSS2D-mapISASreg);
    
    if plot_fig==1
        
        figure
        subplot(2,2,1)
        hold on
        title(['isas-smap A for, month=' num2str(imo)])
        imagesc(lon0,lat0,mapISASreg'-meanmonthSSS1A')
        axis tight
        caxis([-1 1])
        colorbar
        hold off
        subplot(2,2,2)
        hold on
        title(['isas-smap A aft, ' yearc])
        imagesc(lon0,lat0,mapISASreg'-meanmonthSSS2A')
        axis tight
        caxis([-1 1])
        colorbar
        hold off
        subplot(2,2,3)
        hold on
        title(['isas-smap D for'])
        imagesc(lon0,lat0,mapISASreg'-meanmonthSSS1D')
        axis tight
        caxis([-1 1])
        colorbar
        hold off
        subplot(2,2,4)
        hold on
        title(['isas-smap D aft'])
        imagesc(lon0,lat0,mapISASreg'-meanmonthSSS2D')
        axis tight
        caxis([-1 1])
        colorbar
        hold off
        saveas(gcf,[dires 'diffSSSisas_smap_' yearc '_month_' num2str(imo)],'png')
        saveas(gcf,[dires 'diffSSSisas_smap_' yearc '_month_' num2str(imo)],'fig')
        
        figure
        subplot(2,2,1)
        hold on
        title(['std smap A for, month=' num2str(imo)])
        imagesc(lon0,lat0,stdmonthSSS1A')
        axis tight
        caxis([0 3])
        colorbar
        hold off
        subplot(2,2,2)
        hold on
        title(['std smap A aft, ' yearc])
        imagesc(lon0,lat0,stdmonthSSS2A')
        axis tight
        caxis([0 3])
        colorbar
        hold off
        subplot(2,2,3)
        hold on
        title(['std smap D for'])
        imagesc(lon0,lat0,stdmonthSSS1D')
        axis tight
        caxis([0 3])
        colorbar
        hold off
        subplot(2,2,4)
        hold on
        title(['std smap D aft'])
        imagesc(lon0,lat0,stdmonthSSS2D')
        axis tight
        caxis([0 3])
        colorbar
        hold off
        saveas(gcf,[dires 'stdSSSsmap_' yearc '_month_' num2str(imo)],'png')
        saveas(gcf,[dires 'stdSSSsmap_' yearc '_month_' num2str(imo)],'fig')
    end
end
mapISASreg0=mapISASreg0(1:ki,:,:);

stddiffSSS1A=squeeze(nanstd(mapSSS1A-mapISASreg0));
stddiffSSS2A=squeeze(nanstd(mapSSS2A-mapISASreg0));
stddiffSSS1D=squeeze(nanstd(mapSSS1D-mapISASreg0));
stddiffSSS2D=squeeze(nanstd(mapSSS2D-mapISASreg0));

if plot_fig==1
    
    figure
    subplot(2,2,1)
    hold on
    title(['std smap -isas A for, ' yearc])
    imagesc(lon0,lat0,stddiffSSS1A')
    axis tight
    caxis([0 3])
    colorbar
    hold off
    subplot(2,2,2)
    hold on
    title(['std smap - isas A aft'])
    imagesc(lon0,lat0,stddiffSSS2A')
    axis tight
    caxis([0 3])
    colorbar
    hold off
    subplot(2,2,3)
    hold on
    title(['std smap - isas D for'])
    imagesc(lon0,lat0,stddiffSSS1D')
    axis tight
    caxis([0 3])
    colorbar
    hold off
    subplot(2,2,4)
    hold on
    title(['std smap - isas D aft'])
    imagesc(lon0,lat0,stddiffSSS2D')
    axis tight
    caxis([0 3])
    colorbar
    hold off
    saveas(gcf,[dires 'stddiffSSSsmap_isas_' yearc '_month_' num2str(imo)],'png')
    saveas(gcf,[dires 'stddiffSSSsmap_isas_' yearc '_month_' num2str(imo)],'fig')
    
    figure
    subplot(2,2,1)
    hold on
    title(['error A for - A aft, ' yearc])
    imagesc(lon0,lat0,stddiffSSS1A'-stddiffSSS2A')
    axis tight
    caxis([-0.25 0.25])
    colorbar
    hold off
    subplot(2,2,2)
    hold on
    title(['error D for - D aft'])
    imagesc(lon0,lat0,stddiffSSS1D'-stddiffSSS2D')
    axis tight
    caxis([-0.25 0.25])
    colorbar
    hold off
    subplot(2,2,3)
    hold on
    title(['error A for - D for'])
    imagesc(lon0,lat0,stddiffSSS1A'-stddiffSSS1D')
    axis tight
    caxis([-0.25 0.25])
    colorbar
    hold off
    subplot(2,2,4)
    hold on
    title(['error A aft - D aft'])
    imagesc(lon0,lat0,stddiffSSS2A'-stddiffSSS2D')
    axis tight
    caxis([-0.25 0.25])
    colorbar
    hold off
    saveas(gcf,[dires 'diff_error_SSSsmap_A_D_for_aft_' yearc],'png')
    saveas(gcf,[dires 'diff_error_SSSsmap_A_D_for_aft_' yearc],'fig')
    
    % LAT BIAS
    figure
    subplot(2,1,1)
    hold on
    title(['latitudinal bias A, for ' yearc])
    plot(lat0,biaslat1A,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('SMAP - ISAS')
    legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(2,1,2)
    hold on
    title(['latitudinal bias A, aft ' yearc])
    plot(lat0,biaslat2A,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('SMAP - ISAS')
   % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    saveas(gcf,[dires 'LAT_BIAS_A_' yearc],'png')
    saveas(gcf,[dires 'LAT_BIAS_A_' yearc],'fig')
    
    figure
    subplot(2,1,1)
    hold on
    title(['latitudinal bias D, for ' yearc])
    plot(lat0,biaslat1D,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('SMAP - ISAS')
    legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(2,1,2)
    hold on
    title(['latitudinal bias D, aft ' yearc])
    plot(lat0,biaslat2D,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('SMAP - ISAS')
   % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    saveas(gcf,[dires 'LAT_BIAS_D_' yearc],'png')
    saveas(gcf,[dires 'LAT_BIAS_D_' yearc],'fig')
    
    figure
    subplot(2,1,1)
    hold on
    title(['latitudinal std(SMAP-ISAS) A, for ' yearc])
    plot(lat0,stdbiaslat1A,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(SMAP - ISAS)')
    legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(2,1,2)
    hold on
    title(['latitudinal std(SMAP-ISAS) A, aft ' yearc])
    plot(lat0,stdbiaslat2A,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(SMAP - ISAS)')
    % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    saveas(gcf,[dires 'LAT_STDBIAS_A_' yearc],'png')
    saveas(gcf,[dires 'LAT_STDBIAS_A_' yearc],'fig')
    
    figure
    subplot(2,1,1)
    hold on
    title(['latitudinal std(SMAP-ISAS) D, for ' yearc])
    plot(lat0,stdbiaslat1D,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(SMAP - ISAS)')
    legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(2,1,2)
    hold on
    title(['latitudinal std(SMAP-ISAS) D, aft ' yearc])
    plot(lat0,stdbiaslat2D,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(SMAP - ISAS)')
   % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    saveas(gcf,[dires 'LAT_STDBIAS_D_' yearc],'png')
    saveas(gcf,[dires 'LAT_STDBIAS_D_' yearc],'fig')
    
end

