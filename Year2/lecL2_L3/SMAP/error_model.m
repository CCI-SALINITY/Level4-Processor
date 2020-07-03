% modèle d'erreur
clear

SMAPvers='v3';  % v3 ou v4


set(groot,'DefaultFigureColormap',jet)

plot_fig=1;
% pour utiliser densityplot
limxy.xmin=-3; limxy.xmax=32;
limxy.ymin=-8; limxy.ymax=8;
limxy.facm=20;

% dires
dires=['plot_2016_' SMAPvers '\'];
if exist(dires)==0; mkdir(dires); end;

% chargement ISAS
load('G:\dataSMOS\CATDS\repro_2017\isas_CATDS')
yearisas=datemois_isas(:,2);
moisisas=datemois_isas(:,1);

% lecture des fichiers journaliers
pathfile=['I:\SMAP_data\RSS\L2C_' SMAPvers '\file_mat_40km\'];
dirfile=dir(pathfile);

nlon=length(lon_fixgrid);
nlat=length(lat_fixgrid);

nfil=20;

mapSSS1A=NaN(nfil,nlon,nlat);
mapSSS1D=NaN(nfil,nlon,nlat);
mapSSS2A=NaN(nfil,nlon,nlat);
mapSSS2D=NaN(nfil,nlon,nlat);
mapSSTA=NaN(nfil,nlon,nlat);
mapSSTD=NaN(nfil,nlon,nlat);
mapISAS=NaN(nfil,nlon,nlat);

kA=0; kD=0;
for ifi=3:15
    ifi
    namefile=dirfile(ifi).name;
    
    namefile(5)='A';
    pathnamefile=[pathfile namefile];
    load(pathnamefile);    %'SSS1A','SSS2A','tSSS1A','tSSS2A','WS1A','WS2A','rain1A','rain2A'
    
    kA=kA+1;
    mapSSS1A(kA,:,:)=SSS1;
    mapSSS2A(kA,:,:)=SSS2;
    mapSSTA(kA,:,:)=SST1;
    dayA(kA)=str2num(namefile(13:14));
    monA(kA)=str2num(namefile(11:12));
    
    namefile(5)='D';
    pathnamefile=[pathfile namefile];
    load(pathnamefile);
    
    kD=kD+1;
    mapSSS1D(kD,:,:)=SSS1;
    mapSSS2D(kD,:,:)=SSS2;
    mapSSTD(kD,:,:)=SST1;
    dayD(kD)=str2num(namefile(13:14));
    monD(kD)=str2num(namefile(11:12));
    
    fmonth=monD(kD);
    fyear=str2num(namefile(9:10));
    indisas=find(fyear==yearisas & fmonth==moisisas);
    mapISAS0=squeeze(isasSSS(indisas,:,:));
    mapISAS(kD,:,:)=mapISAS0;
    
end

% keyboard
% intervalle temporel
it=1:10;
lit=length(it);
mapSST1=mapSSTA(it,:,:);
mapSSS1=mapSSS1A(it,:,:);
mapSST2=mapSSTA(it,:,:);
mapSSS2=mapSSS2A(it,:,:);
mapISAS1=mapISAS(it,:,:);

indok=find(isnan(mapSSS1)==0 & isnan(mapSSS2)==0);
SSTA=mapSST1(indok);
dSSSA=mapSSS1(indok)-mapSSS2(indok);
dSSS1isas=mapSSS1(indok)-mapISAS1(indok);
dSSS2isas=mapSSS2(indok)-mapISAS1(indok);

diffSSSok=dSSSA;
SSTok=SSTA;

dSST=1.;
SST0=-2:30;
sigSSS=0*SST0;
meanSSS=0*SST0;
sigSSS1=0*SST0;
sigSSS2=0*SST0;
diffSSS1=0*SST0;
diffSSS2=0*SST0;
for ii=1:length(SST0)
    ind1=find( SSTok<SST0(ii)+dSST & SSTok>SST0(ii)-dSST);
    sigSSS(ii)=nanstd(diffSSSok(ind1))/sqrt(2);
    meanSSS(ii)=nanmedian(diffSSSok(ind1))/sqrt(2);
    sigSSS1(ii)=nanstd(dSSS1isas(ind1));
    sigSSS2(ii)=nanstd(dSSS2isas(ind1));
    diffSSS1(ii)=nanmedian(dSSS1isas(ind1));
    diffSSS2(ii)=nanmedian(dSSS2isas(ind1));
end

[p, s]=polyfit(SST0,sigSSS,2);
sigtheo=p(1)*SST0.*SST0+p(2)*SST0+p(3);

[p, s]=polyfit(SST0,diffSSS1,2);
sigtheo2=p(1)*SST0.*SST0+p(2)*SST0+p(3);

[p, s]=polyfit(SST0,diffSSS2,2);
sigtheo3=p(1)*SST0.*SST0+p(2)*SST0+p(3);

sig_theo=0.45./(0.015.*SST0+0.25);

if plot_fig==1
    
    
    [Nr,xr,yr,C] = densityplot(SSTA,dSSSA,limxy);
    
    figure
    hold on
    title('A, for-aft')
   % plot(SSTA,dSSSA,'.')
    imagesc(xr,yr,Nr')
    plot(SST0,sigSSS,'k-','Linewidth',2)
    plot(SST0,meanSSS,'g-','Linewidth',2)
    plot(SST0,sig_theo,'r--','Linewidth',2)
    axis([-2 30 -4 4]); caxis([0 3e4]); colorbar
    grid on
    xlabel('SST')
    ylabel('diffSSS & sigdiff/\surd{2}')
    legend('std','mean','theory with \Delta TB ~ 0.45K')
    hold off
    
    saveas(gcf,[dires 'errorSSS_SST_A_' num2str(min(it)) '_' num2str(max(it))],'png')
    saveas(gcf,[dires 'errorSSS_SST_A_' num2str(min(it)) '_' num2str(max(it))],'fig')

    
    [Nr,xr,yr,C] = densityplot(SSTA,dSSS1isas,limxy);
    figure
    subplot(2,1,1)
    hold on
    title('A, for - ISAS')
   % plot(SSTA,dSSS1isas,'.')
    imagesc(xr,yr,Nr')
    plot(SST0,sigSSS1,'k-','Linewidth',2)
    plot(SST0,diffSSS1,'g-','Linewidth',2)
    plot(SST0,sig_theo,'r--','Linewidth',2)
    axis([-2 30 -4 4]); caxis([0 3e4]);
    grid on
    xlabel('SST')
    ylabel('diffSSS & sigdiff')
    legend('std','mean','theory with \Delta TB ~ 0.45K')
    hold off
    [Nr,xr,yr,C] = densityplot(SSTA,dSSS2isas,limxy);
    subplot(2,1,2)
    hold on
    title('A, aft - ISAS')
    imagesc(xr,yr,Nr')
    plot(SST0,sigSSS2,'k-','Linewidth',2)
    plot(SST0,diffSSS2,'g-','Linewidth',2)
    plot(SST0,sig_theo,'r--','Linewidth',2)
    axis([-2 30 -4 4]); caxis([0 3e4]);
    grid on
    xlabel('SST')
    ylabel('diffSSS & sigdiff')
    hold off
    
    saveas(gcf,[dires 'error_biasSSS_ISAS_SST_A_' num2str(min(it)) '_' num2str(max(it))],'png')
    saveas(gcf,[dires 'error_biasSSS_ISAS_SST_A_' num2str(min(it)) '_' num2str(max(it))],'fig')
    
end

mapSST1=mapSSTD(it,:,:);
mapSSS1=mapSSS1D(it,:,:);
mapSST2=mapSSTD(it,:,:);
mapSSS2=mapSSS2D(it,:,:);
mapISAS1=mapISAS(it,:,:);

indok=find(isnan(mapSSS1)==0 & isnan(mapSSS2)==0);
SSTD=mapSST1(indok);
dSSSD=mapSSS1(indok)-mapSSS2(indok);
dSSS1isas=mapSSS1(indok)-mapISAS1(indok);
dSSS2isas=mapSSS2(indok)-mapISAS1(indok);

diffSSSok=dSSSD;
SSTok=SSTD;

dSST=1.;
SST0=-2:30;
sigSSS=0*SST0;
meanSSS=0*SST0;
sigSSS1=0*SST0;
sigSSS2=0*SST0;
diffSSS1=0*SST0;
diffSSS2=0*SST0;
for ii=1:length(SST0)
    ind1=find( SSTok<SST0(ii)+dSST & SSTok>SST0(ii)-dSST);
    sigSSS(ii)=nanstd(diffSSSok(ind1))/sqrt(2);
    meanSSS(ii)=nanmedian(diffSSSok(ind1))/sqrt(2);
    sigSSS1(ii)=nanstd(dSSS1isas(ind1));
    sigSSS2(ii)=nanstd(dSSS2isas(ind1));
    diffSSS1(ii)=nanmean(dSSS1isas(ind1));
    diffSSS2(ii)=nanmean(dSSS2isas(ind1));
end

[p, s]=polyfit(SST0,sigSSS,2);
sigtheo=p(1)*SST0.*SST0+p(2)*SST0+p(3);

[p, s]=polyfit(SST0,diffSSS1,2);
sigtheo2=p(1)*SST0.*SST0+p(2)*SST0+p(3);

[p, s]=polyfit(SST0,diffSSS2,2);
sigtheo3=p(1)*SST0.*SST0+p(2)*SST0+p(3);

sig_theo=0.45./(0.015.*SST0+0.25);

if plot_fig==1
    
    [Nr,xr,yr,C] = densityplot(SSTD,dSSSD,limxy);

    figure
    hold on
    title('D, for-aft')
    imagesc(xr,yr,Nr')
    plot(SST0,sigSSS,'k-','Linewidth',2)
    plot(SST0,meanSSS,'g-','Linewidth',2)
    plot(SST0,sig_theo,'r--','Linewidth',2)
    axis([-2 30 -4 4]); caxis([0 3e4]);
    grid on
    xlabel('SST')
    ylabel('diffSSS & sigdiff/\surd{2}')
    legend('std','mean','theory with \Delta TB ~ 0.45K')
    hold off
    
    saveas(gcf,[dires 'errorSSS_SST_D_' num2str(min(it)) '_' num2str(max(it))],'png')
    saveas(gcf,[dires 'errorSSS_SST_D_' num2str(min(it)) '_' num2str(max(it))],'fig')
    
    [Nr,xr,yr,C] = densityplot(SSTD,dSSS1isas,limxy);
    figure
    subplot(2,1,1)
    hold on
    title('D, for - ISAS')
    imagesc(xr,yr,Nr')
    plot(SST0,sigSSS1,'k-','Linewidth',2)
    plot(SST0,diffSSS1,'g-','Linewidth',2)
    plot(SST0,sig_theo,'r--','Linewidth',2)
    axis([-2 30 -4 4]); caxis([0 3e4]);
    grid on
    xlabel('SST')
    ylabel('diffSSS & sigdiff')
    legend('std','mean','theory with \Delta TB ~ 0.45K')
    hold off
    [Nr,xr,yr,C] = densityplot(SSTD,dSSS2isas,limxy);
    subplot(2,1,2)
    hold on
    title('D, aft - ISAS')
    imagesc(xr,yr,Nr')
    plot(SST0,sigSSS2,'k-','Linewidth',2)
    plot(SST0,diffSSS2,'g-','Linewidth',2)
    plot(SST0,sig_theo,'r--','Linewidth',2)
    axis([-2 30 -4 4]); caxis([0 3e4]);
    grid on
    xlabel('SST')
    ylabel('diffSSS & sigdiff')
    hold off
    
    saveas(gcf,[dires 'error_biasSSS_ISAS_SST_D_' num2str(min(it)) '_' num2str(max(it))],'png')
    saveas(gcf,[dires 'error_biasSSS_ISAS_SST_D_' num2str(min(it)) '_' num2str(max(it))],'fig')
  
end