% lecture des donnees Aquarius L2
% les donnees sont formees de 5 groupes :
% Aquarius Data
% Aquarius Flags
% Block Attributes
% Converted Telemetry
% Navigation

% Pour lire une variable appartenant a un groupe :
% ncread('namefile','/group/variable')
% exemple : sss=ncread('Q2012008012600.L2_SCI_V5.0','/Aquarius Data/SSS');


% PROBLEME L2C Aquarius : flag rain génère un filtrage systématique entre
% -0.5° et 0.5° de longitude.
% algo : passage sur une première grille à 0.5° régulière puis
% interpolation plus proche voisin sur la grille ease jusqu'à une distance
% de 100 km. Pour boucher les trous interbeam.

% CORRECTION car confusion asc/desc  (lignes 189 & 190)
% pas de bouche trou


clear

repsave='I:\Aquarius_data\RSS\L2\file_mat2\';

load coast
loncoast=long;
latcoast=lat;

set(groot,'DefaultFigureColormap',jet)
% chargement de la grille EASE
load('F:\vergely\SMOS\CCI\matlab\common\latlon_ease.mat');
nlat_ease=length(lat_ease);
nlon_ease=length(lon_ease);
[late lone]=meshgrid(lat_ease,lon_ease);

load('voisin1.mat');

% grille régulière : attention, plus on fait fin, plus la proba que le plus
% proche voisin de la grille ease soit un NaN est élevée.
dll=0.5;
nnn=round(1/dll);
lat0=-90.001:dll:90.001;     % limite des cases. Le centre des case définit la grille -> à utiliser pour l'interpolation
mlat0=round(min(lat0*nnn))-1;
lon0=-180.001:dll:180.001;   % limite des cases. Le centre des case définit la grille -> à utiliser pour l'interpolation
mlon0=round(min(lon0*nnn))-1;

% les noeuds de grille associés
lonc=lon0(1:end-1)+dll/2;
latc=lat0(1:end-1)+dll/2;
nlon=length(lonc);
nlat=length(latc);

for year0=2011:2015;
    
    dateyear0=datenum(year0,1,1,0,0,0);
    dateAqua=datenum(1980,1,6,0,0,0);
    
    pathname=fullfile('I:','Aquarius_data', 'RSS',  num2str(year0));
    dirname=dir(pathname);
    
    progzip=fullfile('7z.exe e ');
    
    % premier tri des fichiers
    nday=length(dirname);
    mm=zeros(12,1);
    day0=datenum(year0,1,1,0,0,0);
    for iday=3:nday
        daynum=str2num(dirname(iday).name);
        datecum=day0+daynum-0.5;
        datev=datevec(datecum);
        month1=datev(2);
        mm(month1)=mm(month1)+1;
        fileday(month1).day(mm(month1))=daynum;
    end
    
    nday=length(dirname);
    for imo=1:12
        imo
        %for imo=1:1
        monc=num2str(imo);
        while length(monc)<2; monc=['0' monc]; end
        for iday=1:length(fileday(imo).day)
            %for iday=24:length(fileday(imo).day)
            
            SSSA=NaN(nlon,nlat);
            SSTA=NaN(nlon,nlat);
            WSA=NaN(nlon,nlat);
            eSSSA=NaN(nlon,nlat);
            SSSargoA=NaN(nlon,nlat);
            SSSD=NaN(nlon,nlat);
            SSTD=NaN(nlon,nlat);
            WSD=NaN(nlon,nlat);
            eSSSD=NaN(nlon,nlat);
            SSSargoD=NaN(nlon,nlat);
            tSSSA=NaN(nlon,nlat);
            tSSSD=NaN(nlon,nlat);
            beamA=NaN(nlon,nlat);
            beamD=NaN(nlon,nlat);
            clonA=NaN(nlon,nlat);
            
            daynum=fileday(imo).day(iday);
            datecum=day0+daynum-1;
            datev=datevec(datecum);
            daymonth=num2str(datev(3));
            
            while length(daymonth)<2; daymonth=['0' daymonth]; end
            
            namefilemat=['aquaA_' num2str(year0) monc daymonth '.mat'];
            
            if exist([repsave namefilemat]); break; end

            
            numday=num2str(fileday(imo).day(iday));
            while length(numday)<3; numday=['0' numday]; end
            
            pathday=fullfile(pathname ,numday)
            dirday=dir(pathday);
            
            for itime=3:length(dirday)  % boucle pour les orbites d'un jour donne
                if dirday(itime).name(end-2:end) == 'bz2'
                    pathtotzip=fullfile(pathday,dirday(itime).name);
                    system(sprintf([progzip ' %s'],pathtotzip));
                    namefile=dirday(itime).name(1:end-4);
                    infout=ncinfo(namefile);
                    sss=ncread(namefile,'/Aquarius Data/SSS');
                    npos=size(sss,2);
                    SSSargo=ncread(namefile,'/Aquarius Data/SSS_matchup');
                    secGPS=ncread(namefile,'/Block Attributes/secGPS');
                    timeAqua=dateAqua+secGPS/86400;
                    radiometer_flags=ncread(namefile,'/Aquarius Flags/radiometer_flags');
                    flags=dec2bin(radiometer_flags,32);
                    % flag tableau 1 : 32-numflag (0->31)
                    % rain, numflag=2
                    fl2=str2num(flags(:,30));
                    fl2=reshape(fl2,4,3,npos);
                    % rain > 0.25 mm/h
                    flrain=squeeze(fl2(2,:,:));
                    % exemple landsea, numflag=3
                    fl3=str2num(flags(:,29));
                    fl3=reshape(fl3,4,3,npos);
                    % on selectionne la condition "severe" fract>0.01 flag==1
                    fland=squeeze(fl3(2,:,:));
                    % ice, numflag=4
                    fl4=str2num(flags(:,28));
                    fl4=reshape(fl4,4,3,npos);
                    % on selectionne la condition "severe" fract ice>0.01 flag==1
                    flice=squeeze(fl4(2,:,:));
                    % WS, numflag=5
                    fl5=str2num(flags(:,27));
                    fl5=reshape(fl5,4,3,npos);
                    % on selectionne la condition "severe" wind speed > 20 flag==1
                    flWS=squeeze(fl5(2,:,:));
                    % non nominal navigation : numflag=12
                    fl12=str2num(flags(:,20));
                    fl12=reshape(fl12,4,3,npos);
                    flrol=squeeze(fl12(1,:,:));
                    flpitch=squeeze(fl12(2,:,:));
                    flyaw=squeeze(fl12(3,:,:));
                    % roughness failure  : numflag=14
                    fl14=str2num(flags(:,18));
                    fl14=reshape(fl14,4,3,npos);
                    flrough=squeeze(fl14(1,:,:));
                    % gal/moon  : numflag=21
                    fl21=str2num(flags(:,11));
                    fl21=reshape(fl21,4,3,npos);
                    flmoon=squeeze(fl21(2,:,:));
                    flgal=squeeze(fl21(3,:,:));
                    flTa=squeeze(fl21(4,:,:));
                    % RFI  : numflag=23
                    fl23=str2num(flags(:,9));
                    fl23=reshape(fl23,4,3,npos);
                    flRFI=squeeze(fl23(1,:,:));
                    
                    %                 lat=beam_clat(1,:);
                    %                 lon=beam_clon(1,:);
                    %
                    %                 figure
                    %                 hold on
                    %                 scatter(lon,lat,3,squeeze(fl3(1,3,:)))  % fl1(flag,beam,position)
                    %                 plot(loncoast,latcoast,'-')
                    %                 caxis([-0.5 0.5])
                    %                 colorbar
                    %                 hold off
                    
                    SSS_unc=ncread(namefile,'/Aquarius Data/SSS_unc');   % erreur totale (syst+random)
                    beam_clat=ncread(namefile,'/Navigation/beam_clat');
                    beam_clon=ncread(namefile,'/Navigation/beam_clon');
                    anc_surface_temp=double(ncread(namefile,'/Aquarius Data/anc_surface_temp'))-273.15;
                    anc_wind_speed=ncread(namefile,'/Aquarius Data/anc_wind_speed');
                    
                    delete('Q2*.*')
                    
                    limasc_desc=floor(npos/2);   % limite Asc-Desc
                    
                    indA=1:limasc_desc;
                    indD=(limasc_desc+1):npos;
                    
                    %     sss1=sss(1,:);
                    %     lat=beam_clat(1,:);
                    %     lon=beam_clon(1,:);
                    %     figure
                    %     hold on
                    %     scatter(lon(1:limasc_desc),lat(1:limasc_desc),3,sss1(1:limasc_desc))
                    %     hold off
                    %     sss0=reshape(sss,size(sss,1)*size(sss,2),1);
                    %     beam_clat0=reshape(beam_clat,size(sss,1)*size(sss,2),1);
                    %     beam_clon0=reshape(beam_clon,size(sss,1)*size(sss,2),1);
                    
                    % orbite desc 1:limasc_desc
                    for iorb=1:2
                        if iorb==1; indsel=indA; else; indsel=indD; end;
                        
                        beam_clat0=beam_clat(:,indsel);
                        beam_clon0=beam_clon(:,indsel);
                        indlon0=find(abs(beam_clon0)<0.5);   % a cause du flag pluie toujours levé par erreur à lon=0
                        
                        sss0=sss(:,indsel);
                        SST0=anc_surface_temp(:,indsel);
                        WS0=anc_wind_speed(:,indsel);
                        timeAqua0=timeAqua(indsel);
                        SSSargo0=SSSargo(:,indsel);
                        eSSS0=SSS_unc(:,indsel);
                        
                        fland0=fland(:,indsel);
                        flice0=flice(:,indsel);
                        flrol0=flrol(:,indsel);
                        flpitch0=flpitch(:,indsel);
                        flyaw0=flyaw(:,indsel);
                        flrough0=flrough(:,indsel);
                        flmoon0=flmoon(:,indsel);
                        flgal0=flgal(:,indsel);
                        flTa0=flTa(:,indsel);
                        flRFI0=flRFI(:,indsel);
                        flrain0=flrain(:,indsel);
                        flrain0(indlon0)=0;                 % a cause du flag pluie toujours levé par erreur à lon=0
                        
                        ilat=floor(beam_clat0*nnn)-mlat0;  % indices sur la nouvelle grille à 0.25°
                        ilon=floor(beam_clon0*nnn)-mlon0;
                        %   combflg=(isnan(sss0)-1).*(fland0-1).*(flice0-1).*(flrol0-1).*(flpitch0-1).*(flyaw0-1).*(flrough0-1).*(flmoon0-1).*(flgal0-1).*(flTa0-1).*(flRFI0-1).*(flrain0-1);
                        combflg=(isnan(sss0)-1).*(fland0-1).*(flice0-1).*(flrol0-1).*(flpitch0-1).*(flyaw0-1).*(flrough0-1).*(flmoon0-1).*(flgal0-1).*(flTa0-1).*(flRFI0-1);  % le flag pluie est foireux.... cumul sur 24h
                        ind=find(combflg==0 | ilon > nlon);     % on ne prend pas si la combinaison de flag ("et") = 0
                        ilon(ind)=1;                            % on rejete tous les points en (1,1), coin de carte
                        ilat(ind)=1;
                        
                        for igp=1:limasc_desc
                            for ibeam=1:3
                                ilabeam0=ilat(ibeam,:);
                                ilobeam0=ilon(ibeam,:);
                                ilabeam=ilat(ibeam,igp);
                                ilobeam=ilon(ibeam,igp);
                                if ilabeam~=1
                                    isel=find(ilabeam==ilabeam0 & ilobeam==ilobeam0);
                                    nsel=length(isel);
                                    if iorb==1
                                        % il faut moyenner sur la taille du
                                        % beam car Aquarius est très
                                        % échantillonné selon la latitude.
                                        % ici on traite demi-orbite par
                                        % demi-orbite : ce qui a le même indice
                                        % de pixel en latitude appartient au
                                        % même pixel
                                        % on regarde pixel par pixel
                                        %    if nsel>3; keyboard; end
                                        tSSSA(ilobeam,ilabeam)=mean(timeAqua0(isel));
                                        SSSA(ilobeam,ilabeam)=median(sss0(ibeam,isel));
                                        SSTA(ilobeam,ilabeam)=mean(SST0(ibeam,isel));
                                        WSA(ilobeam,ilabeam)=mean(WS0(ibeam,isel));
                                        eSSSA(ilobeam,ilabeam)=sqrt(mean(eSSS0(ibeam,isel).*eSSS0(ibeam,isel))/nsel);
                                        SSSargoA(ilobeam,ilabeam)=median(SSSargo0(ibeam,isel));
                                        beamA(ilobeam,ilabeam)=ibeam;
                                    else
                                        %    if nsel>3; keyboard; end
                                        tSSSD(ilobeam,ilabeam)=mean(timeAqua0(isel));
                                        SSSD(ilobeam,ilabeam)=median(sss0(ibeam,isel));
                                        SSTD(ilobeam,ilabeam)=mean(SST0(ibeam,isel));
                                        WSD(ilobeam,ilabeam)=mean(WS0(ibeam,isel));
                                        eSSSD(ilobeam,ilabeam)=sqrt(mean(eSSS0(ibeam,isel).*eSSS0(ibeam,isel))/nsel);
                                        SSSargoD(ilobeam,ilabeam)=median(SSSargo0(ibeam,isel));
                                        beamD(ilobeam,ilabeam)=ibeam;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            %    delete('Q2*.*')
            
            %             plus proche voisin sur ease
            %             interpolation sur la grille EASE
            tSSSA=interp2(lonc,latc,tSSSA',lone,late,'nearest');
            SSSA=interp2(lonc,latc,SSSA',lone,late,'nearest');  %extremes bords de la grille EASE non couvert
            SSTA=interp2(lonc,latc,SSTA',lone,late,'nearest');
            WSA=interp2(lonc,latc,WSA',lone,late,'nearest');
            eSSSA=interp2(lonc,latc,eSSSA',lone,late,'nearest');
            SSSargoA=interp2(lonc,latc,SSSargoA',lone,late,'nearest');
            beamA=interp2(lonc,latc,beamA',lone,late,'nearest');
            
            tSSSD=interp2(lonc,latc,tSSSD',lone,late,'nearest');
            SSSD=interp2(lonc,latc,SSSD',lone,late,'nearest');
            SSTD=interp2(lonc,latc,SSTD',lone,late,'nearest');
            WSD=interp2(lonc,latc,WSD',lone,late,'nearest');
            eSSSD=interp2(lonc,latc,eSSSD',lone,late,'nearest');
            SSSargoD=interp2(lonc,latc,SSSargoD',lone,late,'nearest');
            beamD=interp2(lonc,latc,beamD',lone,late,'nearest');
            
            mattotA=NaN(size(lone,1),size(lone,2),7);
            mattotA(:,:,1)=tSSSA;
            mattotA(:,:,2)=SSSA;
            mattotA(:,:,3)=SSTA;
            mattotA(:,:,4)=WSA;
            mattotA(:,:,5)=eSSSA;
            mattotA(:,:,6)=SSSargoA;
            mattotA(:,:,7)=beamA;
            mattotA=squeeze(reshape(mattotA,1,length(lon_ease)*length(lat_ease),7));
            
            mattotD=NaN(size(lone,1),size(lone,2),7);
            mattotD(:,:,1)=tSSSD;
            mattotD(:,:,2)=SSSD;
            mattotD(:,:,3)=SSTD;
            mattotD(:,:,4)=WSD;
            mattotD(:,:,5)=eSSSD;
            mattotD(:,:,6)=SSSargoD;
            mattotD(:,:,7)=beamD;
            mattotD=squeeze(reshape(mattotD,1,length(lon_ease)*length(lat_ease),7));
            
            
            % save(['aquaA_' num2str(year0) monc],'SSS1A','SSS2A','SSS3A')
            % save([repsave 'aquaA_' num2str(year0) monc daymonth],'SSSA','SSTA','WSA','tSSSA','eSSSA','SSSargoA','beamA')
            % save([repsave 'aquaD_' num2str(year0) monc daymonth],'SSSD','SSTD','WSD','tSSSD','eSSSD','SSSargoD','beamD')
            mattot=mattotA;
            save([repsave namefilemat],'mattot')
            mattot=mattotD;
            save([repsave namefilemat],'mattot')
            
        end
    end
end
