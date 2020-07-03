% comparaison asc-desc et beam1-beam2
clear

set(groot,'DefaultFigureColormap',jet)

plot_fig=1;

year0=2012;

jjinit=datenum(year0,1,1,0,0,0);
jjfin=datenum(year0,12,31,0,0,0);

ndtot=jjfin-jjinit+1;


yearc=num2str(year0);
% dires
dires=['plot_' yearc '_vocean\'];
if exist(dires)==0; mkdir(dires); end;

% chargement ISAS
load('G:\dataSMOS\CATDS\repro_2017\correction_biais\isas_CATDS')
yearisas=datemois_isas(:,2);
moisisas=datemois_isas(:,1);
nlon=length(lon_fixgrid);
nlat=length(lat_fixgrid);
lat0=lat_fixgrid;
lon0=lon_fixgrid;

% chargement dmin EASE
load('G:\dataSMOS\CATDS\repro_2017\maskdmin_ease2.mat');
indcoast=find(dmin<400);

% lecture des fichiers journaliers
pathfile='I:\Aquarius_data\RSS\L2\file_mat\';
dirfile=dir(pathfile);

[lat00,lon00]=meshgrid(lat0,lon0);
nnk=ndtot*2;
pasday=1;
nnk1=round(nnk/pasday);

mapSSS1A=NaN(nnk1,nlon,nlat); % beam 1, asc
mapSSS1D=NaN(nnk1,nlon,nlat); % beam 1, desc
mapSSS2A=NaN(nnk1,nlon,nlat); % beam 2, asc
mapSSS2D=NaN(nnk1,nlon,nlat); % beam 2, desc
mapSSS3A=NaN(nnk1,nlon,nlat); % beam 3, asc
mapSSS3D=NaN(nnk1,nlon,nlat); % beam 3, desc
juldayA=NaN(nnk1,1);
juldayD=NaN(nnk1,1);

kA=0; kD=0;
for ifi=3:pasday:length(dirfile)
    %ifi
    namefile=dirfile(ifi).name;
    yearn=str2num(namefile(7:10));
    if yearn==year0
        pathnamefile=[pathfile dirfile(ifi).name];
        load(pathnamefile);    %'SSSA','SSTA','WSA','tSSSA','eSSSA','SSSargoA','beamA'
        if namefile(5)=='A'
            kA=kA+1
            SSSA(indcoast)=NaN;
            
            ind=find(beamA==1);
            SSS1=SSSA+NaN;
            SSS1(ind)=SSSA(ind);
            mapSSS1A(kA,:,:)=SSS1;
            
            ind=find(beamA==2);
            SSS1=SSSA+NaN;
            SSS1(ind)=SSSA(ind);
            mapSSS2A(kA,:,:)=SSS1;
            
            ind=find(beamA==3);
            SSS1=SSSA+NaN;
            SSS1(ind)=SSSA(ind);
            mapSSS3A(kA,:,:)=SSS1;
            
            dayA(kA)=str2num(namefile(13:14));
            monA(kA)=str2num(namefile(11:12));
            yeaA(kA)=yearn;
            juldayA(kA)=datenum(yeaA(kA),monA(kA),dayA(kA),0,0,0);
        else            
            kD=kD+1
            SSSD(indcoast)=NaN;
            
            ind=find(beamD==1);
            SSS1=SSSD+NaN;
            SSS1(ind)=SSSD(ind);
            mapSSS1D(kD,:,:)=SSS1;
            
            ind=find(beamD==2);
            SSS1=SSSD+NaN;
            SSS1(ind)=SSSD(ind);
            mapSSS2D(kD,:,:)=SSS1;
            
            ind=find(beamD==3);
            SSS1=SSSD+NaN;
            SSS1(ind)=SSSD(ind);
            mapSSS3D(kD,:,:)=SSS1;
            
            dayD(kD)=str2num(namefile(13:14));
            monD(kD)=str2num(namefile(11:12));
            yeaD(kD)=yearn;
            juldayD(kD)=datenum(yeaD(kD),monD(kD),dayD(kD),0,0,0);
        end
    end
end
kA
kD
mapSSS1A=mapSSS1A(1:kA,:,:);
mapSSS2A=mapSSS2A(1:kA,:,:);
mapSSS3A=mapSSS3A(1:kA,:,:);
mapSSS1D=mapSSS1D(1:kD,:,:);
mapSSS2D=mapSSS2D(1:kD,:,:);
mapSSS3D=mapSSS3D(1:kD,:,:);

% comparaison moyenne sur l'annee (carte)

meanSSS1A=squeeze(nanmedian(mapSSS1A));
meanSSS2A=squeeze(nanmean(mapSSS2A));
meanSSS3A=squeeze(nanmean(mapSSS3A));

meanSSS1D=squeeze(nanmean(mapSSS1D));
meanSSS2D=squeeze(nanmean(mapSSS2D));
meanSSS3D=squeeze(nanmean(mapSSS3D));

stdSSS1A=squeeze(nanstd(mapSSS1A));
stdSSS2A=squeeze(nanstd(mapSSS2A));
stdSSS3A=squeeze(nanstd(mapSSS3A));
stdSSS1D=squeeze(nanstd(mapSSS1D));
stdSSS2D=squeeze(nanstd(mapSSS2D));
stdSSS3D=squeeze(nanstd(mapSSS3D));

figure
subplot(2,2,1)
hold on
title(['meanSSS ' yearc  ', A, beam1'])
imagesc(lon0,lat0,meanSSS1A')
axis tight
caxis([32 38])
colorbar
hold off
subplot(2,2,2)
hold on
title('A, beam2')
imagesc(lon0,lat0,meanSSS2A')
axis tight
caxis([32 38])
colorbar
hold off
subplot(2,2,3)
hold on
title(['meanSSS ' yearc ', D, beam1'])
imagesc(lon0,lat0,meanSSS1D')
axis tight
caxis([32 38])
colorbar
hold off
subplot(2,2,4)
hold on
title('D, beam2')
imagesc(lon0,lat0,meanSSS2D')
axis tight
caxis([32 38])
colorbar
hold off
saveas(gcf,[dires 'mapSSSmean_' yearc],'png')
saveas(gcf,[dires 'mapSSSmean_' yearc],'fig')

% difference asc-desc
% on empile les desc
meanSSSD=zeros(3,1388,584);
meanSSSD(1,:,:)=meanSSS1D;
meanSSSD(2,:,:)=meanSSS2D;
meanSSSD(3,:,:)=meanSSS3D;
meanSSSD=squeeze(nanmean(meanSSSD));

% on empile les asc
meanSSSA=zeros(3,1388,584);
meanSSSA(1,:,:)=meanSSS1A;
meanSSSA(2,:,:)=meanSSS2A;
meanSSSA(3,:,:)=meanSSS3A;
meanSSSA=squeeze(nanmean(meanSSSA));

figure
hold on
title(['SSS asc - SSSdesc, beam1+beam2+beam3, ' yearc] )
imagesc(lon0,lat0,meanSSSA'-meanSSSD')
axis tight
caxis([-0.5 0.5])
colorbar
hold off

saveas(gcf,[dires 'DIFFA_DmapSSSmean_' yearc],'png')
saveas(gcf,[dires 'DIFFA_DmapSSSmean_' yearc],'fig')

figure
subplot(2,2,1)
hold on
title(['stdSSS ' yearc ', A, beam1'])
imagesc(lon0,lat0,stdSSS1A')
axis tight
caxis([0 2])
colorbar
hold off
subplot(2,2,2)
hold on
title('A, beam2')
imagesc(lon0,lat0,stdSSS2A')
axis tight
caxis([0 2])
colorbar
hold off
subplot(2,2,3)
hold on
title(['stdSSS ' yearc ', D, beam1'])
imagesc(lon0,lat0,stdSSS1D')
axis tight
caxis([0 2])
colorbar
hold off
subplot(2,2,4)
hold on
title('D, beam2')
imagesc(lon0,lat0,stdSSS2D')
axis tight
caxis([0 2])
colorbar
hold off
saveas(gcf,[dires 'mapSSSstd_' yearc],'png')
saveas(gcf,[dires 'mapSSSstd_' yearc],'fig')


% comparaison ISAS mois par mois

ki=0;
mapISASreg0=NaN(365,length(lon0),length(lat0));
biaslat1A=NaN(12,length(lat0));
stdbiaslat1A=NaN(12,length(lat0));
biaslat2A=NaN(12,length(lat0));
stdbiaslat2A=NaN(12,length(lat0));
biaslat3A=NaN(12,length(lat0));
stdbiaslat3A=NaN(12,length(lat0));
biaslat1D=NaN(12,length(lat0));
stdbiaslat1D=NaN(12,length(lat0));
biaslat2D=NaN(12,length(lat0));
stdbiaslat2D=NaN(12,length(lat0));
biaslat3D=NaN(12,length(lat0));
stdbiaslat3D=NaN(12,length(lat0));

for imo=1:12
    imo
    indA=find(monA==imo);
    meanmonthSSS1A=squeeze(nanmean(mapSSS1A(indA,:,:)));
    meanmonthSSS2A=squeeze(nanmean(mapSSS2A(indA,:,:)));
    meanmonthSSS3A=squeeze(nanmean(mapSSS3A(indA,:,:)));
    stdmonthSSS1A=squeeze(nanstd(mapSSS1A(indA,:,:)));
    stdmonthSSS2A=squeeze(nanstd(mapSSS2A(indA,:,:)));
    stdmonthSSS3A=squeeze(nanstd(mapSSS3A(indA,:,:)));
    
    indD=find(monD==imo);
    meanmonthSSS1D=squeeze(nanmean(mapSSS1D(indD,:,:)));
    meanmonthSSS2D=squeeze(nanmean(mapSSS2D(indD,:,:)));
    meanmonthSSS3D=squeeze(nanmean(mapSSS3D(indD,:,:)));
    stdmonthSSS1D=squeeze(nanstd(mapSSS1D(indD,:,:)));
    stdmonthSSS2D=squeeze(nanstd(mapSSS2D(indD,:,:)));
    stdmonthSSS3D=squeeze(nanstd(mapSSS3D(indD,:,:)));
    
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
    biaslat3A(imo,:)=nanmean(meanmonthSSS3A-mapISASreg);
    stdbiaslat3A(imo,:)=nanstd(meanmonthSSS3A-mapISASreg);
    biaslat1D(imo,:)=nanmean(meanmonthSSS1D-mapISASreg);
    stdbiaslat1D(imo,:)=nanstd(meanmonthSSS1D-mapISASreg);
    biaslat2D(imo,:)=nanmean(meanmonthSSS2D-mapISASreg);
    stdbiaslat2D(imo,:)=nanstd(meanmonthSSS2D-mapISASreg);
    biaslat3D(imo,:)=nanmean(meanmonthSSS3D-mapISASreg);
    stdbiaslat3D(imo,:)=nanstd(meanmonthSSS3D-mapISASreg);
    
    if plot_fig==1
        
        figure
        subplot(2,2,1)
        hold on
        title(['isas-Aquarius A beam1, month=' num2str(imo)])
        imagesc(lon0,lat0,mapISASreg'-meanmonthSSS1A')
        axis tight
        caxis([-1 1])
        colorbar
        hold off
        subplot(2,2,2)
        hold on
        title(['isas-Aquarius A beam2, ' yearc])
        imagesc(lon0,lat0,mapISASreg'-meanmonthSSS2A')
        axis tight
        caxis([-1 1])
        colorbar
        hold off
        subplot(2,2,3)
        hold on
        title(['isas-Aquarius D beam1'])
        imagesc(lon0,lat0,mapISASreg'-meanmonthSSS1D')
        axis tight
        caxis([-1 1])
        colorbar
        hold off
        subplot(2,2,4)
        hold on
        title(['isas-Aquarius D beam2'])
        imagesc(lon0,lat0,mapISASreg'-meanmonthSSS2D')
        axis tight
        caxis([-1 1])
        colorbar
        hold off
        saveas(gcf,[dires 'diffSSSisas_Aquarius_' yearc '_month_' num2str(imo)],'png')
        saveas(gcf,[dires 'diffSSSisas_Aquarius_' yearc '_month_' num2str(imo)],'fig')
        
        figure
        subplot(2,2,1)
        hold on
        title(['std Aquarius A beam1, month=' num2str(imo)])
        imagesc(lon0,lat0,stdmonthSSS1A')
        axis tight
        caxis([0 3])
        colorbar
        hold off
        subplot(2,2,2)
        hold on
        title(['std Aquarius A beam2, ' yearc])
        imagesc(lon0,lat0,stdmonthSSS2A')
        axis tight
        caxis([0 3])
        colorbar
        hold off
        subplot(2,2,3)
        hold on
        title(['std Aquarius D beam1'])
        imagesc(lon0,lat0,stdmonthSSS1D')
        axis tight
        caxis([0 3])
        colorbar
        hold off
        subplot(2,2,4)
        hold on
        title(['std Aquarius D beam2'])
        imagesc(lon0,lat0,stdmonthSSS2D')
        axis tight
        caxis([0 3])
        colorbar
        hold off
        saveas(gcf,[dires 'stdSSSAquarius_' yearc '_month_' num2str(imo)],'png')
        saveas(gcf,[dires 'stdSSSAquarius_' yearc '_month_' num2str(imo)],'fig')
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
    title(['std Aquarius -isas A beam1, ' yearc])
    imagesc(lon0,lat0,stddiffSSS1A')
    axis tight
    caxis([0 3])
    colorbar
    hold off
    subplot(2,2,2)
    hold on
    title(['std Aquarius - isas A beam2'])
    imagesc(lon0,lat0,stddiffSSS2A')
    axis tight
    caxis([0 3])
    colorbar
    hold off
    subplot(2,2,3)
    hold on
    title(['std Aquarius - isas D beam1'])
    imagesc(lon0,lat0,stddiffSSS1D')
    axis tight
    caxis([0 3])
    colorbar
    hold off
    subplot(2,2,4)
    hold on
    title(['std Aquarius - isas D beam2'])
    imagesc(lon0,lat0,stddiffSSS2D')
    axis tight
    caxis([0 3])
    colorbar
    hold off
    saveas(gcf,[dires 'stddiffSSSAquarius_isas_' yearc '_month_' num2str(imo)],'png')
    saveas(gcf,[dires 'stddiffSSSAquarius_isas_' yearc '_month_' num2str(imo)],'fig')
    
    
    % LAT BIAS
    figure
    subplot(3,1,1)
    hold on
    title(['SSS latitudinal bias A, beam1 ' yearc])
    plot(lat0,biaslat1A,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('Aquarius - ISAS')
    legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(3,1,2)
    hold on
    title(['latitudinal bias A, beam2 ' yearc])
    plot(lat0,biaslat2A,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('Aquarius - ISAS')
   % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(3,1,3)
    hold on
    title(['latitudinal bias A, beam3 ' yearc])
    plot(lat0,biaslat3A,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('Aquarius - ISAS')
   % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    saveas(gcf,[dires 'LAT_BIAS_A_' yearc],'png')
    saveas(gcf,[dires 'LAT_BIAS_A_' yearc],'fig')
    
    figure
    subplot(3,1,1)
    hold on
    title(['SSS latitudinal bias D, beam1 ' yearc])
    plot(lat0,biaslat1D,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('Aquarius - ISAS')
    legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(3,1,2)
    hold on
    title(['latitudinal bias D, beam2 ' yearc])
    plot(lat0,biaslat2D,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('Aquarius - ISAS')
   % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(3,1,3)
    hold on
    title(['latitudinal bias D, beam3 ' yearc])
    plot(lat0,biaslat3D,'-')
    grid on
    axis([-90 90 -1 1])
    xlabel('lat')
    ylabel('Aquarius - ISAS')
   % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off

    saveas(gcf,[dires 'LAT_BIAS_D_' yearc],'png')
    saveas(gcf,[dires 'LAT_BIAS_D_' yearc],'fig')
    
    figure
    subplot(3,1,1)
    hold on
    title(['SSS latitudinal std(Aquarius-ISAS) A, beam1 ' yearc])
    plot(lat0,stdbiaslat1A,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(Aquarius - ISAS)')
    legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(3,1,2)
    hold on
    title(['latitudinal std(Aquarius-ISAS) A, beam2 ' yearc])
    plot(lat0,stdbiaslat2A,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(Aquarius - ISAS)')
    % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(3,1,3)
    hold on
    title(['latitudinal std(Aquarius-ISAS) A, beam3 ' yearc])
    plot(lat0,stdbiaslat3A,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(Aquarius - ISAS)')
    % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    saveas(gcf,[dires 'LAT_STDBIAS_A_' yearc],'png')
    saveas(gcf,[dires 'LAT_STDBIAS_A_' yearc],'fig')
    
    figure
    subplot(3,1,1)
    hold on
    title(['SSS latitudinal std(Aquarius-ISAS) D, beam1 ' yearc])
    plot(lat0,stdbiaslat1D,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(Aquarius - ISAS)')
    legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(3,1,2)
    hold on
    title(['latitudinal std(Aquarius-ISAS) D, beam2 ' yearc])
    plot(lat0,stdbiaslat2D,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(Aquarius - ISAS)')
   % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    subplot(3,1,3)
    hold on
    title(['latitudinal std(Aquarius-ISAS) D, beam3 ' yearc])
    plot(lat0,stdbiaslat3D,'-')
    grid on
    axis([-90 90 0 3])
    xlabel('lat')
    ylabel('std(Aquarius - ISAS)')
   % legend('m=1', 'm=2', 'm=3', 'm=4', 'm=5' ,'m=6', 'm=7', 'm=8', 'm=9', 'm=10', 'm=11', 'm=12')
    hold off
    saveas(gcf,[dires 'LAT_STDBIAS_D_' yearc],'png')
    saveas(gcf,[dires 'LAT_STDBIAS_D_' yearc],'fig')
    
end

