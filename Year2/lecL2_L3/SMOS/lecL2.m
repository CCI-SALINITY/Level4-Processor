% lecture des donnees L2p du CATDS
% preparation et conditionnement pour traitement
% production de fichier .mat dans file_mat à traiter par le programme compute_biais.m
% 25/02/2019 ajout de la lecture des flags Fg_ctrl_poor_geophysical et
% Fg_ctrl_many_outliers

% repertoire des donnees CATDS
dirdata='J:\CATDS\RE05\RE05\MIR_CSF2P';
dirdataUDP='J:\CATDS\RE05\RE05\MIR_CSF2U';

dateref=datenum(2000,1,1);  % reference SMOS 1/1/2000
% le pas en dwell est défini tous les 25 km entre -xswathmax et +xswathmax
xswathmax=662.5;
pasxswath=25;
xswath=-xswathmax:pasxswath:xswathmax;

% lecture lat/lon dans un fichier quelconque
lat_ease=ncread('L2Pref.nc','lat');
lon_ease=ncread('L2Pref.nc','lon');
nlon=length(lon_ease);
nlat=length(lat_ease);

save('latlon_ease','lat_ease','lon_ease','nlat','nlon');

% base pour le nom des fichiers
name='smosA_20100701.nc';

year=['10'; '11'; '12'; '13'; '14'; '15'; '16'; '17'; '18'; '19']   % annees
nyear=10;

% lecture des produits .nc ou chargement des produits .mat
SSSsel=[];
eSSSsel=[];
tSSSsel=[];
nSsel=[];
tabNaNind=[];

for iad=1:2  % boucle asc-desc
    if iad==1
        orb='A'
    end
    if iad==2
        orb='D'
    end
    dirascdesc=[dirdata orb '/'];
    dirascdescUDP=[dirdataUDP orb '/'];
    %   for ifi=3:length(dirt)   % boucle annee
    for ia=nyear:nyear  % boucle sur les annees
        ia
        ia1=ia;
        ia2=ia;
        diryear=[dirascdesc '20' year(ia1,:) '/'];
        dirt=dir(diryear);
        diryearUDP=[dirascdescUDP '20' year(ia1,:) '/'];
        
       % for jday=172:length(dirt)
        for jday=189:length(dirt)   
            jour=dirt(jday).name
            
            % L2P
            dir1=dir([diryear dirt(jday).name]);
            filepath=[diryear dirt(jday).name '/' dir1(3).name]
            name1=[dir1(3).name(1:end-4) '.HDR'];
            name2=[dir1(3).name(1:end-4) '.DBL'];
            
            % UDP
            dir1UDP=dir([diryearUDP dirt(jday).name]);
            filepathUDP=[diryearUDP dirt(jday).name '/' dir1UDP(3).name]
            name1UDP=[dir1UDP(3).name(1:end-4) '.HDR'];
            name2UDP=[dir1UDP(3).name(1:end-4) '.DBL'];
            
            if (exist(filepathUDP) ~= 0 & exist(filepath) ~= 0)
                
                untar(filepath)
                
                if exist(name2)==0;
                    name2=[dir1(3).name(1:end-4) '.DBL.nc'];
                end
                
                %  infout=ncinfo(name2);
                tSSS=ncread(name2,'Mean_Acq_Time');
                tSSS=tSSS+dateref;
                vecd=datevec(max(max(tSSS)));
                xswathSSS=ncread(name2,'X_Swath');
                
                SSS=ncread(name2,'Sea_Surface_Salinity_Model1_Value');
                eSSS=ncread(name2,'Sea_Surface_Salinity_Model1_Error');
                cSSS=ncread(name2,'Sea_Surface_Salinity_Model1_Classes');
                
                %  cSSSbin=dec2bin(cSSS,32);
                %  valdSSS=str2num(cSSSbin(:,32));
                %  valdSSS=reshape(valdSSS,nlon,nlat);
                
                % indice du xswath sur la gamme xswathsel : varie de 1 à length(xswathsel)-1
                indxswath=floor((xswathSSS+xswathmax)/pasxswath)+1;
                delete(name1);
                delete(name2);
                
                imonth=vecd(2);
                if imonth < 10; imonc=['0' num2str(imonth)]; else imonc=num2str(imonth); end;
                iday=vecd(3);
                if iday < 10; idayc=['0' num2str(iday)]; else; idayc=num2str(iday); end;
                
                % on selectionne au plus une SSS par GP, par dwell et par jour
                ind0=find(SSS<0 | isnan(SSS));
                
                SSS0=SSS;
                eSSS0=eSSS;
                idwSSS0=indxswath;
                tSSS0=tSSS;
                % classSSS0=valdSSS;
                SSS0(ind0)=NaN;
                eSSS0(ind0)=NaN;
                tSSS0(ind0)=NaN;
                idwSSS0(ind0)=NaN;
                % classSSS0(ind0)=NaN;
                
                untar(filepathUDP)
                
                filepathUDP
                filepath
                
                Dg_chi2_1=ncread(name2UDP,'Dg_chi2_1')./100;
                Acard=ncread(name2UDP,'Acard');
                
                ind=find(Dg_chi2_1<=0);
                Dg_chi2_1(ind)=999;
                Dg_chi2_1=sqrt(Dg_chi2_1);
                chiSSS0=Dg_chi2_1;
                dualfull='full';
                
                SST0=ncread(name2UDP,'SST')-273.15;
                WS0=ncread(name2UDP,'WS');
                Dg_Suspect_ice0=ncread(name2UDP,'Dg_Suspect_ice');
                
                % SSTest=ncread(name2UDP,'Param2_M1');
                Dg_chi2_Acard=ncread(name2UDP,'Dg_chi2_Acard');
                
                keyboard

                Ctrl_flags_1=ncread(name2UDP,'Ctrl_flags_1');
                ind=find(Ctrl_flags_1<0);
                Ctrl_flags_1(ind)=0;
                cSSSbin=dec2bin(Ctrl_flags_1,32);
                
                
                % poor geophy = 25
                ifl=double(cSSSbin(:,32-25+1));
                ifl=floor(ifl./49);
                ifl1=reshape(ifl,nlon,nlat);
                 % many outlier = 14
                ifl=double(cSSSbin(:,32-14+1));
                ifl=floor(ifl./49);
                ifl2=reshape(ifl,nlon,nlat);
                
                   % max iter = 11
                ifl=double(cSSSbin(:,32-11+1));
                ifl=floor(ifl./49);
                ifl3=reshape(ifl,nlon,nlat);
                
                % poor retrieval = 26
                ifl=double(cSSSbin(:,32-26+1));
                ifl=floor(ifl./49);
                ifl4=reshape(ifl,nlon,nlat);
              
              
                figure; subplot(2,2,1); hold on; title(['poor geophy,' namemat],'Interpreter','none'); imagesc(ifl1'); axis tight; colorbar; hold off;
                subplot(2,2,2); hold on; title('many outlier'); imagesc(ifl2'); axis tight; colorbar; hold off;
                subplot(2,2,3); hold on; title('max iter'); imagesc(ifl3'); axis tight; colorbar; hold off;
                subplot(2,2,4); hold on; title('poor retriev'); imagesc(ifl4'); axis tight; colorbar; hold off;
             
                
                 % 16 roughness appliquee partout en principe (pour test)
%                 ifl=double(cSSSbin(:,32-16+1));
%                 ifl=floor(ifl./49);
%                 ifl=reshape(ifl,nlon,nlat);
%                 imagesc(ifl'); colorbar
               
                
                
                % keyboard
                delete(name1UDP);
                delete(name2UDP);
                
                name_ok=name;
                name_ok(5)=orb;
                name_ok(9:10)=year(ia1,:);
                name_ok(11:12)=imonc;
                name_ok(13:14)=idayc;
                namemat=name_ok(1:14);
                [epsr]=KS(SST0,SSS0);
                Acard_mod=eps2acard(epsr);

                save(['J:\CATDS\RE05\file_mat_full\' namemat],'Dg_Suspect_ice0','WS0','SST0','SSS0','eSSS0','idwSSS0','chiSSS0','tSSS0','xswath','dualfull','Acard','Acard_mod','Dg_chi2_Acard')
            end
        end
    end
end

