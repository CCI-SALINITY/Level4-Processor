% comparaison asc-desc et for-aft
clear

set(groot,'DefaultFigureColormap',jet)

plot_fig=1;

year0=[2012, 2013];
jjinit=datenum(year0(1),1,1,0,0,0);
jjfin=datenum(year0(2),12,31,0,0,0);

ndtot=jjfin-jjinit+1;

datesel=[2012,1,15; 2012,7,15; 2013,1,15; 2013,7,15 ; 2014,1,15];

datenumsel=datenum(datesel);

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
pasday=3;
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
    if yearn==year0(1) | yearn==year0(2)
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

%keyboard

% ISAS
mapISASreg=squeeze(isasSSS(1,:,:));
latSSS1A=NaN(kA,size(mapISASreg,2));
latSSS2A=NaN(kA,size(mapISASreg,2));
latSSS3A=NaN(kA,size(mapISASreg,2));
latSSS1D=NaN(kD,size(mapISASreg,2));
latSSS2D=NaN(kD,size(mapISASreg,2));
latSSS3D=NaN(kD,size(mapISASreg,2));
juldayA=juldayA(1:kA);
juldayD=juldayD(1:kD);

jultab=NaN(nnk1,1);

ikA=0;
ikD=0;

kA=0; kD=0;
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
        kA=kA+1;
        latSSS1A(kA,:)=squeeze(nanmean(squeeze(mapSSS1A(indA,:,:))-mapISASreg,1));
        latSSS2A(kA,:)=squeeze(nanmean(squeeze(mapSSS2A(indA,:,:))-mapISASreg,1));
        latSSS3A(kA,:)=squeeze(nanmean(squeeze(mapSSS3A(indA,:,:))-mapISASreg,1));
    end
    
    indD=find(monD==monv & yeaD==yeav & dayD==dayv);
    if length(indD)==1
        kD=kD+1;
        latSSS1D(kD,:)=squeeze(nanmean(squeeze(mapSSS1D(indD,:,:))-mapISASreg,1));
        latSSS2D(kD,:)=squeeze(nanmean(squeeze(mapSSS2D(indD,:,:))-mapISASreg,1));
        latSSS3D(kD,:)=squeeze(nanmean(squeeze(mapSSS3D(indD,:,:))-mapISASreg,1));
    end
end

latreg=-80:0.25:80;
[latreg0, jultab0]=meshgrid(latreg,juldayA);
latSSS1A=interp2(juldayA,lat_fixgrid,latSSS1A',jultab0,latreg0);
latSSS2A=interp2(juldayA,lat_fixgrid,latSSS2A',jultab0,latreg0);
latSSS3A=interp2(juldayA,lat_fixgrid,latSSS3A',jultab0,latreg0);

[latreg0, jultab0]=meshgrid(latreg,juldayD);
latSSS1D=interp2(juldayD,lat_fixgrid,latSSS1D',jultab0,latreg0);
latSSS2D=interp2(juldayD,lat_fixgrid,latSSS2D',jultab0,latreg0);
latSSS3D=interp2(juldayD,lat_fixgrid,latSSS3D',jultab0,latreg0);

figure
subplot(2,3,1)
hold on
title('A, beam1')
imagesc(juldayA,latreg,latSSS1A')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off
subplot(2,3,2)
hold on
title('A, beam2')
imagesc(juldayA,latreg,latSSS2A')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off
subplot(2,3,3)
hold on
title('A, beam3')
imagesc(juldayA,latreg,latSSS3A')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off
subplot(2,3,4)
hold on
title('D, beam1')
imagesc(juldayD,latreg,latSSS1D')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off
subplot(2,3,5)
hold on
title('D, beam2')
imagesc(juldayD,latreg,latSSS2D')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off
subplot(2,3,6)
hold on
title('D, beam3')
imagesc(juldayD,latreg,latSSS3D')
axis tight
caxis([-0.5 0.5])
colorbar
set(gca,'XTick',datenumsel)
datetick('x','mm/yy','keepticks')
hold off



