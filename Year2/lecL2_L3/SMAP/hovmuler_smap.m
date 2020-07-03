% comparaison asc-desc et for-aft
clear

SMAPvers='v4';  % v3 ou v4

set(groot,'DefaultFigureColormap',jet)

plot_fig=1;

year0=[2016, 2017];

    datesel=[2016,1,15; 2016,7,15; 2017,1,15; 2017,7,15 ; 2018,1,15];
    
    datenumsel=datenum(datesel);

yearc=num2str(year0);
% dires
dires=[['plot_HOVM_vocean_L2C_' SMAPvers '\']];
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
pathfile=['I:\SMAP_data\RSS\L2C_' SMAPvers '\file_mat_40km\'];   % L2C_v2\file_mat1 respecte asc/desc pour SMAP (signature opposee a SMOS car le satellite tourne dans l'autre sens)
dirfile=dir(pathfile);

[lat00,lon00]=meshgrid(lat0,lon0);
nnk=round(length(dirfile)/3.8);

mapSSS1A=NaN(nnk,nlon,nlat);
mapSSS1D=NaN(nnk,nlon,nlat);
mapSSS2A=NaN(nnk,nlon,nlat);
mapSSS2D=NaN(nnk,nlon,nlat);

kA=0; kD=0;
for ifi=3:length(dirfile)
    ifi
    namefile=dirfile(ifi).name;
    yearn=str2num(namefile(7:10));
    if yearn==year0(1) | yearn==year0(2)
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
            yeaA(kA)=yearn;
        else
            kD=kD+1;
            SSS1(indcoast)=NaN;
            SSS2(indcoast)=NaN;
            mapSSS1D(kD,:,:)=SSS1;
            mapSSS2D(kD,:,:)=SSS2;
            dayD(kD)=str2num(namefile(13:14));
            monD(kD)=str2num(namefile(11:12));
            yeaD(kD)=yearn;
        end
    end
end
kA
kD
mapSSS1A=mapSSS1A(1:kA,:,:);
mapSSS2A=mapSSS2A(1:kA,:,:);
mapSSS1D=mapSSS1D(1:kD,:,:);
mapSSS2D=mapSSS2D(1:kD,:,:);

% keyboard

% ISAS
mapISASreg=squeeze(isasSSS(1,:,:));
latSSS1A=NaN(365*2,size(mapISASreg,2));
latSSS2A=NaN(365*2,size(mapISASreg,2));
latSSS1D=NaN(365*2,size(mapISASreg,2));
latSSS2D=NaN(365*2,size(mapISASreg,2));

jultab=NaN(365*2,1);

ikA=0;
ikD=0;
jjinit=datenum(year0(1),1,1,0,0,0);
jjfin=datenum(year0(2),12,31,0,0,0);


for iday=1:(jjfin-jjinit)
    iday
    jultab(iday)=jjinit+iday-1;
    datev=datevec(jultab(iday));
    yeav=datev(1);
    monv=datev(2);
    dayv=datev(3);
    indISAS=find(yearisas==(yeav-2000) & moisisas==monv);
    mapISASreg=squeeze(isasSSS(indISAS,:,:));

    indA=find(monA==monv & yeaA==yeav & dayA==dayv);
    if length(indA)==1
    latSSS1A(iday,:)=squeeze(nanmean(squeeze(mapSSS1A(indA,:,:))-mapISASreg,1));
    latSSS2A(iday,:)=squeeze(nanmean(squeeze(mapSSS2A(indA,:,:))-mapISASreg,1));
    end
    
    indD=find(monD==monv & yeaD==yeav & dayD==dayv);
    if length(indD)==1
    latSSS1D(iday,:)=squeeze(nanmean(squeeze(mapSSS1D(indD,:,:))-mapISASreg,1));
    latSSS2D(iday,:)=squeeze(nanmean(squeeze(mapSSS2D(indD,:,:))-mapISASreg,1));
    end
end

latreg=-80:0.25:80;
[latreg0, jultab0]=meshgrid(latreg,jultab);

latSSS1A=interp2(jultab,lat_fixgrid,latSSS1A',jultab0,latreg0);
latSSS2A=interp2(jultab,lat_fixgrid,latSSS2A',jultab0,latreg0);
latSSS1D=interp2(jultab,lat_fixgrid,latSSS1D',jultab0,latreg0);
latSSS2D=interp2(jultab,lat_fixgrid,latSSS2D',jultab0,latreg0);


figure
subplot(2,2,1)
hold on
title('A, fore')
imagesc(jultab,latreg,latSSS1A')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off
subplot(2,2,2)
hold on
title('A, afte')
imagesc(jultab,latreg,latSSS2A')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off
subplot(2,2,3)
hold on
title('D, fore')
imagesc(jultab,latreg,latSSS1D')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off
subplot(2,2,4)
hold on
title('D, afte')
imagesc(jultab,latreg,latSSS2D')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off

saveas(gcf,[dires 'hovemuler_SMAP'],'png')


