% essayer d'estimer l'erreur sur les produits L3 Aquarius de manière
% empirique
% tests selon la distance à la cote
% validation du modele d'erreur proposé

clear

load('G:\dataSMOS\CATDS\repro_2017\isas_CATDS');

[lat0, lon0]=meshgrid(lat_fixgrid,lon_fixgrid);

dirdataaqua='I:\Aquarius_data\RSS\L3\file_mat\';
diraq=dir(dirdataaqua);

% chargement dmin EASE
load('G:\dataSMOS\CATDS\repro_2017\maskdmin_ease2.mat');
indcoast=find(dmin<1000);

nameaqua='aquaA_20100701.mat'   % on pose A même si ce sont des A+D

% on doit procéder à un sous-echantillonnage spatial pour calculer l'erreur
% individuelle car Aquarius est lissé spatialement

% latmin=-60; latmax=60;
% lonmin=-160; lonmax=-120;
% indlat=find(lat_fixgrid<latmax & lat_fixgrid>latmin);
% indlon=find(lon_fixgrid<lonmax & lon_fixgrid>lonmin);

indlat=1:3:length(lat_fixgrid);
indlon=1:3:length(lon_fixgrid);

lat1=lat0(indlon,indlat);

SSSt=nan(length(diraq)-2,length(indlon),length(indlat));
eSSSt=nan(length(diraq)-2,length(indlon),length(indlat));
SSTt=nan(length(diraq)-2,length(indlon),length(indlat));
SSSisas=nan(length(diraq)-2,length(indlon),length(indlat));
latt=nan(length(diraq)-2,length(indlon),length(indlat));
tt=nan(length(diraq)-2,1);

% chargement des donnees Aquarius
k=0;
for ifi=3:length(diraq)
    k=k+1
    % erreur estimee Aquarius : 2 passes (asc et desc) sur 7 jours ->
    % on divise par un facteur sqrt(2)
    % un bruit radiometrique equivalent par acquisition de 0.2K
    % dependance en cos(lat)
    % on considère un sous-echantillonnage d'un facteur 2 (1 sur 4) :
    % on multiplie par sqrt(2) : cela annule l'effet du sqrt(2) lie aux
    % 2 passes.
    % sig_theo=(0.2/sqrt(2))./(0.015.*SST1+0.25);
    % sig_theo=0.2.*sqrt(cosd(abs(lat0)))./(0.015.*SST1+0.25);
    
    indisas=find(str2num(diraq(ifi).name(7:10))-2000==datemois_isas(:,2) & str2num(diraq(ifi).name(11:12))==datemois_isas(:,1));
    
    load([dirdataaqua diraq(ifi).name]); % ,'SSS1','tSSS1','eSSS1','SST1');
    
    SSSt(k,:,:)=SSS1(indlon,indlat);
    eSSSt(k,:,:)=eSSS1(indlon,indlat);
    SSTt(k,:,:)=SST1(indlon,indlat);
    SSSisas(k,:,:)=isasSSS(indisas,indlon,indlat);
    %keyboard
    latt(k,:,:)=lat1;
    ind=find(isnan(tSSS1)==0);
    
    dat=datenum(str2num(diraq(ifi).name(7:10)),str2num(diraq(ifi).name(11:12)),str2num(diraq(ifi).name(13:14)),0,0,0);
    tt(k)=dat;
    
end

%save('SSSpac','tt','SSSisas','SSSt','SSTt','eSSSt','indlat','indlon','lat_fixgrid','lon_fixgrid','-v7.3');

SSSt(:,indcoast)=NaN;

keyboard

% choix d'une période min-max
timemin=datenum(2011,6,1);
timemax=datenum(2015,6,31);
yyy=(2011:2016)';
mmm=1+0*yyy;
ddd=1+0*yyy;
ttt=[yyy,mmm,ddd];
timeplot=datenum(ttt);

% tous les 6 mois pour les dates
% datesel=[ datevec(timemin); datevec(round((timemin+timemax)/2)); datevec(round(timemax))];
datesel=datevec(timeplot);
datenumsel=datenum(datesel);

% pour le zoom sur un an
yyy=[2013;2013;2013];
mmm=[1;3;6];
ddd=1+0*yyy;
ttt=[yyy,mmm,ddd];
timeplot2=datenum(ttt);
datesel_zoom=datevec(timeplot2);
datenumsel_zoom=datenum(datesel_zoom);

% pour le zoom sur un an
yyy=[2012;2012;2012];
mmm=[3;6;9];
ddd=1+0*yyy;
ttt=[yyy,mmm,ddd];
timeplot2=datenum(ttt);
datesel_zoom=datevec(timeplot2);
datenumsel_zoom=datenum(datesel_zoom);


ilo=10;
ila=50;

SSSGP=squeeze(SSSt(:,ilo,ila));
eSSSGP=squeeze(eSSSt(:,ilo,ila));

nday_aqua=3;

figure
subplot(3,1,1); hold on
title(['SSS time series, lon=' num2str(lon_fixgrid(indlon(ilo))) '°, lat=' num2str(lat_fixgrid(indlat(ila))) '°'])
plot(tt,SSSGP,'.')
axis([min(tt), max(tt), min(SSSGP), max(SSSGP)]);
set(gca,'XTick',datenumsel); datetick('x','mm/yy','keepticks')
grid on; hold off
subplot(3,1,2)
hold on
title('zoom')
plot(tt,SSSGP,'.')
axis([min(timeplot2), max(timeplot2), min(SSSGP), max(SSSGP)]);
set(gca,'XTick',datenumsel_zoom); datetick('x','mm/yy','keepticks')
grid on
hold off
subplot(3,1,3)
hold on
title('zoom selection CCI')
plot(tt(1:nday_aqua:end),SSSGP(1:nday_aqua:end),'.')
axis([min(timeplot2), max(timeplot2), min(SSSGP), max(SSSGP)]);
set(gca,'XTick',datenumsel_zoom)
datetick('x','mm/yy','keepticks')
grid on
hold off

% calcul de l'erreur sur la base d'un écrémage de 7 jours
% std sur nday_std

load('G:\dataSMOS\CATDS\repro_2017\maskdmin_ease2');
dmin0=dmin;

dmin0=dmin0(indlon,indlat);
indcoast=find(dmin0<800);
indocean=find(dmin0>800);

nlat=length(indlat);
nlon=length(indlon);

% Attention, la SSS isas est constante sur 1 mois
% pour comparer la std ISAS GP par GP, l faut étendre la période sur
% plusieurs mois. Donc std(Aqua-Isas) mois par mois et GP par GP =
% std(Aqua)
nday_aqua=3;
nday_std=30;
nday_std=60;

ntt=(length(tt));
nttsel=length(1:nday_std:ntt);

stdSSSsel=nan(nttsel,nlon,nlat);
SSTsel=nan(nttsel,nlon,nlat);
eSSSsel=nan(nttsel,nlon,nlat);
SSSisassel=nan(nttsel,nlon,nlat);
SSSsel=nan(nttsel,nlon,nlat);
latsel=nan(nttsel,nlon,nlat);
eSSSisas=nan(nttsel,nlon,nlat);
varisas=nan(nttsel,nlon,nlat);
ttk=nan(nttsel,1);

k=0;
% on calcul l'erreur tous les nday_std sur l'ensemble de la période
for iti=1:nday_std:ntt
    k=k+1;
    tt0=tt(iti);
    ttk(k)=tt0;
    daten=datestr(datevec(tt0),30);
    
    indt=find(tt<tt0+nday_std/2 & tt>tt0-nday_std/2);
    stdSSSsel0=squeeze(nanstd(SSSt(indt(1:nday_aqua:end),:,:)));
    stdSSSsel(k,:,:)=stdSSSsel0;
    SSTsel(k,:,:)=squeeze(SSTt(iti,:,:));
    eSSSsel(k,:,:)=squeeze(eSSSt(iti,:,:));
    SSSisassel(k,:,:)=squeeze(SSSisas(iti,:,:));
    dSSS=SSSt(indt(1:nday_aqua:end),:,:)-SSSisas(indt(1:nday_aqua:end),:,:);  % pas vraiment de sens car SSSisas ne bouge pas sur 1 mois (sauf si on étend la période sur 2 ou 3 mois).
    eSSSisas0=squeeze(nanstd(dSSS));
    vSSSi=squeeze(nanstd(SSSisas(indt(1:nday_aqua:end),:,:)));
    varisas(k,:,:)=vSSSi;
    eSSSisas(k,:,:)=eSSSisas0;
    SSSsel1=squeeze(SSSt(iti,:,:));
    SSSsel(k,:,:)=SSSsel1;
    latsel(k,:,:)=latt(iti,:,:);
    
    figure;
    subplot(2,3,1)
    hold on; title([daten(1:8), ' empirical std']); imagesc(stdSSSsel0'); axis tight; caxis([0 0.5]); colorbar; hold off;
    subplot(2,3,2)
    hold on; title([daten(1:8), ' std from ISAS']); imagesc(eSSSisas0'); axis tight; caxis([0 0.5]); colorbar; hold off;
    subplot(2,3,3)
    hold on; title([daten(1:8), ' std from L2']); imagesc(squeeze(eSSSt(iti,:,:))'); axis tight; caxis([0 0.5]); colorbar; hold off;
    subplot(2,3,4)
    hold on; title([daten(1:8), ' std emp - std isas']); imagesc(stdSSSsel0'-eSSSisas0'); axis tight; caxis([-0.1 0.1]); colorbar; hold off;
    subplot(2,3,5)
    hold on; title([daten(1:8), ' std var isas']); imagesc(vSSSi'); axis tight; caxis([0 0.5]); colorbar; hold off;
    subplot(2,3,6)
    hold on; title([daten(1:8), ' var emp - var isas']); imagesc((eSSSisas0.^2-vSSSi.^2)'); axis tight; caxis([0 0.5]); colorbar; hold off;
    
    saveas(gcf,['plot\' daten(1:8)],'png')
    
    %     if k==13; keyboard;
    %     imagesc(squeeze(nanstd(dSSS(:,:,:)))'); caxis([0 0.25])
    %     imagesc(squeeze(stdSSSsel0(:,:,:))'); caxis([0 0.25])
    %     end;
    
    close all
end

stdSSSmap=sqrt(nanmedian(stdSSSsel.^2));

itim=13;
daten=datestr(datevec(ttk(itim)),30);
figure;
hold on
title(['ISAS-Aquarius,' daten])
imagesc(squeeze(SSSisas(itim,:,:))'-squeeze(SSSsel(itim,:,:))')
caxis([-0.5 0.5]); axis tight; colorbar;
hold off

keyboard

for icase=1:2
    
    if icase==1
        inds=indcoast;
        titl='dcoast<800km';
    elseif icase==2';
        inds=indocean;
        titl='dcoast>800km';
    end
    
    %     latsel=reshape(latsel,size(latsel,1)*size(latsel,2),1);
    %     stdSSSsel=reshape(stdSSSsel,size(stdSSSsel,1)*size(stdSSSsel,2),1);
    %     eSSSsel=reshape(eSSSsel,size(eSSSsel,1)*size(eSSSsel,2),1);
    %     SSTsel=reshape(SSTsel,size(SSTsel,1)*size(SSTsel,2),1);
    %     SSSisassel=reshape(SSSisassel,size(SSSisassel,1)*size(SSSisassel,2),1);
    %     SSSsel=reshape(SSSsel,size(SSSsel,1)*size(SSSsel,2),1);
    
    
    stdSSSsel1=stdSSSsel.*NaN;
    eSSSsel1=eSSSsel;
    SSTsel1=SSTsel;
    SSSisassel1=SSSisassel;
    SSSsel1=SSSsel;
    latsel1=latsel;
    
    for ik=1:k
        stdSSSsel1(ik,inds)=stdSSSsel(ik,inds);
    end
    
    indno0=find(stdSSSsel1~=0 & ~isnan(stdSSSsel1));
    stdSSSsel1=stdSSSsel1(indno0);
    eSSSsel1=eSSSsel1(indno0);
    SSTsel1=SSTsel1(indno0);
    SSSisassel1=SSSisassel1(indno0);
    SSSsel1=SSSsel1(indno0);
    latsel1=latsel1(indno0);
    
    figure
    hold on; plot(stdSSSsel1,eSSSsel1,'.'); hold off
    
    figure
    hold on; plot(SSTsel1,stdSSSsel1,'.'); hold off
    
    % erreur selon la SST
    SSTtab=0:35;
    dSST=0.5;
    for isst=1:length(SSTtab)
        sst=SSTtab(isst);
        inda=find(SSTsel1<sst+dSST & SSTsel1>sst-dSST);
        eSSSm(isst)=sqrt(nanmean(stdSSSsel1(inda).^2));
        eSSSest(isst)=sqrt(nanmean(eSSSsel1(inda).^2));
        erreurSSSisas(isst)=nanstd(SSSsel1(inda)-SSSisassel1(inda));
        ndat(isst)=length(inda);
        sig_theo(isst)=median((0.2.*sqrt(cosd(abs(latsel1(inda)))))./(0.015.*SSTsel1(inda)+0.25));
        % sig_theo=0.2.*sqrt(cosd(abs(lat0)))./(0.015.*SST1+0.25);
    end
    
    figure
    hold on
    title(['SSS L3 Aquarius error estimation, ' titl])
    plot(SSTtab,eSSSm,'-')
    plot(SSTtab,eSSSest,'r-')
    plot(SSTtab,erreurSSSisas,'g-')
    axis([0 30 0 1])
    xlabel('SST'); ylabel('Aquarius L3 SSS error'); grid on;
    legend('error from time window','error estimated from L2 (2019)','error from ISAS')
    plot(SSTtab,sig_theo,'r--')
    hold off
    
    figure
    hold on
    title(['SSS L3 Aquarius vs SSSisas, ' titl])
    plot(SSSsel1,SSSisassel1,'.')
    axis([25 40 25 40])
    xlabel('L3 SSS aqua'); ylabel('SSS isas'); grid on
    hold off
    
end



