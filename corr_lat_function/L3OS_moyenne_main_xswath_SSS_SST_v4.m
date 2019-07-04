% program for computing SMOS SSS monthly fields at different xswath
% positions for latitudinal correction
% input     : L2 SMOS files (from file_mat_full_SST)
% output    : mat files
% date : 06/2019 (CCI+SSS year 1 project)
% author : JLV, ACRI-ST


clear

% selection des classes dans une table de bits
% bit 1 : Fg_SSS_non_valid  == 0
% bit 2 : SSS & SST gradient spatial eleve
% bit 3 : SSS gradient spatial eleve & SST pas de gradient spatial eleve
% bit 4 : SSS distrib boite_i seuil_j
% bit 5 : SSS ecart-type eleve pour echelle 1
% bit 6 : SSS ecart-type eleve pour echelle 2
% bit 7 : SSS ecart-type eleve pour echelle 3
% bit 8 : high WS
% bit 9 : low WS
% bit 10 : high WS 48h
% bit 11 : low WS 48h
% bit 12 : high SST
% bit 13 : low SST
% bit 14 : high SST 48h
% bit 15 : low SST 48h
% bit 16 : SSS distrib boite_1 seuil_3
% bit 17 : WS gradient temporel eleve 48h
% bit 18 : SST gradient temporel eleve 48h
% bit 19 : param gradient temporel eleve
% bit 20 : Fg_sc_low_wave_height1
% bit 21 : Fg_sc_low_wave_height2
% bit 22 : Fg_sc_low_wave_height3
% bit 23 : Fg_sc_moderate_wave_height4
% bit 24 : Fg_sc_moderate_wave_height5
% bit 25 : Fg_sc_extreme_wave_height6
% bit 26 : Fg_param_retr
% bit 27 : Fg_low_wind_48 & Fg_low_wind
% bit 28 : Fg_SSS_non_valid  == 1
% bit 29 : x_swath

% lecture du masque dmin
load('G:\dataSMOS\CATDS\repro_2015\compare_full_st1_dual\maskdmin_ease2');
dmin=squeeze(reshape(dmin,1388*584,1));
dmaxmasque=500;
ind=find(dmin<dmaxmasque);
masquecote=dmin*0;
masquecote(ind)=1;  % contamination cotiere si == 1

process_SMOS=1;
process_SMAP=0;
process_AQUA=0;

% xswath_tab=[-400 -350 -300 -250 -200 -150 -100 -50 0 50 100 150 200 250 300 350 400];
% xswath_tab=[-400 -350 -300 -250 -200 -150 -100 -50 0 50 100 150 200 250 300 350 400];
% xswath_tab=[-450 -400 -350 -300 -250 -200 -150 -100 -50 0 50 100 150 200 250 300 350 400] + 25;
%xswath_tab=[-550 550];
% le pas en dwell est défini tous les 25 km entre -xswathmax et +xswathmax
xswathmax=487.5;
pasxswath=25;
xswath_tab=-xswathmax:pasxswath:xswathmax;

dxsw=5;

%indxswath=floor((xswathSSS+xswathmax)/pasxswath)+1;
tabbit0 = [];
booltabbit = [];

% lecture de la grille fixe
load('G:\dataSMOS\CATDS\repro_2015\ADF\easegrid_new.mat')
NlatDGG=length(lat_fixgrid);
NlonDGG=length(lon_fixgrid);

nombreGP=NlatDGG*NlonDGG;
latDGG=unique(lat_fixgrid);
lonDGG=unique(lon_fixgrid);

[lat0 lon0]=meshgrid(latDGG, lonDGG);

smapexemple='SMAP_L3_SSS_20170107_8DAYS_V4.0.nc';
infout=ncinfo(smapexemple);
lat_smap=ncread(smapexemple,'latitude');
lon_smap=ncread(smapexemple,'longitude');
Nlat_smap=length(lat_smap);
Nlon_smap=length(lon_smap);

aquaexemple='sss20130103.v4.0cap.nc';
infout=ncinfo(aquaexemple);
lat_aqua=ncread(aquaexemple,'lat');
lon_aqua=ncread(aquaexemple,'lon');
Nlat_aqua=length(lat_aqua);
Nlon_aqua=length(lon_aqua);

% chargement d'isas pour la temperature
load('../isas_CATDS')

% lecture des fichier L2P

for iorb=1:2
    if iorb==1
        orb='A';
    else
        orb='D';
    end
    for iyear=1:8
        yeartot=num2str(2010+iyear);
        
        dirmat='J:\CATDS\RE05\file_mat_full_SST\'; %smosA_20100112
        
        fileSMAP=['G:\dataSMOS\CATDS\SMAP\L3_v4\JPL_v4\8days\' yeartot '\'];
        fileAQUA=['I:\Aquarius_data\L3_capv4_JPL\' yeartot '\'];
        
        dirSMAP=dir(fileSMAP);
        dirAQUA=dir(fileAQUA);
        
        for imo=1:12
            if process_SMOS==1
                
                mapSSSt=NaN(31,NlonDGG,NlatDGG);
                mapSSTt=NaN(31,NlonDGG,NlatDGG);
                xswatht=NaN(31,NlonDGG,NlatDGG);
                
                if imo<10
                    monc=['0' num2str(imo)];
                else
                    monc=num2str(imo);
                end
                datename=['201' num2str(iyear)  monc]
                
                k=0;
                for ij=1:31
                    dayc=num2str(ij);
                    if length(dayc)<2; dayc=['0' dayc]; end;
                    namem=[datename dayc '.mat'];
                    namet=[dirmat 'smos' orb '_' namem];
                    
                    if exist(namet)
                        load(namet);
                        xswath0=xswath;
                        if dualfull=='full'
                            k=k+1;
                            % filtrage SSS et Acard attention Acard smos
                            % dispo seulement sur la période RE05
                            indA=find(abs(Acard -Acard_mod)>3 | eSSS0>5 | SSS0<5 | SSS0>42);
                            
                            SSS0(indA)=NaN;
                            SST0(indA)=NaN;
                            idwSSS0(indA)=NaN;
                            
                            mapSSSt(k,:,:)=SSS0;
                            mapSSTt(k,:,:)=SST0;
                            xswatht(k,:,:)=idwSSS0;
                            
                            %   figure; hold on; imagesc(eSSS0'); axis xy; caxis([0 5]); colorbar; hold off
                            %   figure; hold on; imagesc(abs(Acard -Acard_mod)'); axis xy; caxis([0 3]); colorbar; hold off
                            %   figure; hold on; imagesc(SSS0'); axis xy; caxis([32 42]); colorbar; hold off
                            
                        end
                    end
                end
                disp('save')
                
                for ifilt=1:(length(xswath_tab)-1)
                    % tabbit0 = [1, 29];
                    % tabbit0 = [1];
                    % booltabbit = [1];
                    % keyboard
                    ixsw_sel=xswath_tab(ifilt);
                    ixsw_sel=find(abs(xswath_tab(ifilt)-xswath0)<0.1);
                    
                    if length(ixsw_sel)>0
                        
                        % dirsave=['plots_sans_filtre_' num2str(abs(xswathmin)) '_' num2str(abs(xswathmax)) '/'];
                        dirsave=['plots_avec_filtre_SST/plots_filtreAcard_' num2str(abs(xswath_tab(ifilt))) '_' num2str(abs(xswath_tab(ifilt+1))) '/'];
                        % dirsave=['plots_avec_filtre2_asc_' num2str(abs(xswathmin)) '_' num2str(abs(xswathmax)) '/'];
                        %  xswathmin=-400; xswathmax=400; dirsave='plots_filtre_400_400/'
                        if exist(dirsave)==0;
                            mkdir(dirsave);
                        end
                        % distance pour la moyenne
                        namecommand=[];
                        namefile='SSS_dist_50';
                        mapSSS=NaN(NlonDGG,NlatDGG);
                        mapSST=NaN(NlonDGG,NlatDGG);
                        for ik=1:k
                           % namecommand='find(xswath<xswathmax & xswath>xswathmin & SSS>5)';  % on prend tout
                            SSS=squeeze(mapSSSt(ik,:,:));
                            SST=squeeze(mapSSTt(ik,:,:));
                            xswath=squeeze(xswatht(ik,:,:));
                            ind=find(xswath==ixsw_sel | xswath==ixsw_sel+1);
                            mapSSS(ind)=SSS(ind);
                            mapSST(ind)=SST(ind);
                        end
                        meanSSSmap=mapSSS;
                        meanSSTmap=mapSST;
                        % sauvegarde en fonction des flags
                        save([dirsave namefile '_orb_' orb '_date_' datename],'meanSSSmap','meanSSTmap')
                        
                      %  keyboard
                    end
                end
            end
            
            % on traite aussi SMAP
            if process_SMAP==1 & length(dirSMAP)>3 & iorb==1
                mapSSSt=NaN(31,NlonDGG,NlatDGG);
                mapSSTt=NaN(31,NlonDGG,NlatDGG);
                
                if imo<10
                    monc=['0' num2str(imo)];
                else
                    monc=num2str(imo);
                end
                datename=['201' num2str(iyear)  monc]
                
                k=0;
                for ij=1:365
                    strjour=num2str(ij);
                    if ij < 10
                        strjour=['00' num2str(ij)];
                    elseif ij < 100
                        strjour=['0' num2str(ij)];
                    end
                    
                    fL3=[fileSMAP strjour];
                    dirsel=dir(fL3);
                    
                    if length(dirsel)>2
                        monthf=str2num(dirsel(3).name(17:18));
                        yearf=str2num(dirsel(3).name(16));
                        
                        if monthf==imo & yearf==iyear
                            k=k+1;
                            filesmap=[fL3 '\' dirsel(3).name]
                            
                            smap_sss=ncread(filesmap,'smap_sss');
                            anc_sst=ncread(filesmap,'anc_sst');
                            
                            smap_sss_ease=interp2(lon_smap, lat_smap, smap_sss',lon0,lat0);
                            anc_sst_ease=interp2(lon_smap, lat_smap, anc_sst',lon0,lat0);
                            
                            mapSSSt(k,:,:)=smap_sss_ease;
                            mapSSTt(k,:,:)=anc_sst_ease;
                            % keyboard
                            
                        end
                    end
                end
                
                dirsave=['plots_avec_sans_filtre_SST/plots_sans_filtre_smap/'];
                if exist(dirsave)==0;
                    mkdir(dirsave);
                end
                
                namefile='SMAP_SSS_dist_50';
                mapSSS=NaN(NlonDGG,NlatDGG);
                mapSST=NaN(NlonDGG,NlatDGG);
                
                meanSSSmap=squeeze(nanmedian(mapSSSt));
                meanSSTmap=squeeze(nanmedian(mapSSTt));
                % sauvegarde en fonction des flags
                save([dirsave namefile '_date_' datename],'meanSSSmap','meanSSTmap')
            end
            
            if process_AQUA==1 & length(dirAQUA)>3 & iorb==1
                mapSSSt=NaN(31,NlonDGG,NlatDGG);
                
                indisas=find(datemois_isas(:,1)==imo & datemois_isas(:,2)==(10+iyear));
                temp=squeeze(isasTEMP(indisas,:,:));
                
                if imo<10
                    monc=['0' num2str(imo)];
                else
                    monc=num2str(imo);
                end
                datename=['201' num2str(iyear)  monc]
                
                k=0;
                for ij=1:365
                    strjour=num2str(ij);
                    if ij < 10
                        strjour=['00' num2str(ij)];
                    elseif ij < 100
                        strjour=['0' num2str(ij)];
                    end
                    
                    fL3=[fileAQUA strjour];
                    dirsel=dir(fL3);
                    
                    if length(dirsel)>2
                        monthf=str2num(dirsel(3).name(17:18));
                        yearf=str2num(dirsel(3).name(16));
                        if monthf==imo & yearf==iyear
                            k=k+1;
                            fileaqua=[fL3 '\' dirsel(3).name]
                            aqua_sss=ncread(fileaqua,'smap_sss');
                            aqua_sss_ease=interp2(lon_aqua, lat_aqua, aqua_sss',lon0,lat0);
                            mapSSSt(k,:,:)=aqua_sss_ease;
                            % keyboard
                        end
                    end
                end
                
                dirsave=['plots_avec_sans_filtre_SST/plots_sans_filtre_aqua/'];
                if exist(dirsave)==0;
                    mkdir(dirsave);
                end
                
                namefile='AQUA_SSS_dist_50';
                mapSSS=NaN(NlonDGG,NlatDGG);
                mapSST=NaN(NlonDGG,NlatDGG);
                
                meanSSSmap=squeeze(nanmedian(mapSSSt));
                meanSSTmap=temp;
                % sauvegarde en fonction des flags
                save([dirsave namefile '_date_' datename],'meanSSSmap','meanSSTmap')
                
            end
        end
    end
end


