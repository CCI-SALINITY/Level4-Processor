% lecture des produits SMAP L2C RSS
% preparation des fichiers
% fichier journalier
% separation asc/desc et forward/afterward


% CORRECTION car confusion asc/desc  (lignes 270 & 272)

clear

set(groot,'DefaultFigureColormap',jet)

% chargement de la grille EASE
load('F:\vergely\SMOS\CCI\matlab\common\latlon_ease.mat');

[late lone]=meshgrid(lat_ease,lon_ease);

for year0=2020:2020;
    
    dateyear0=datenum(year0,1,1,0,0,0);
    
    start_time_day_of_year=zeros(366,1);
    nameprod=struct([]);
    fileday=struct([]);
    
    k=0;
    for imonth=1:12
        monthc=num2str(imonth);
        if imonth<10; monthc=['0' monthc]; end;
        
        pathname=['I:\SMAP_data\RSS\L2C_v4\' num2str(year0) '\' monthc '\'];
        
        pathsave='I:\SMAP_data\RSS\L2C_v4\file_mat_40km\';
        if exist(pathsave)==0; mkdir(pathsave); end
        dirname=dir(pathname);
        
        % on fait un premier tri des fichiers
        for ii=3:length(dirname)
            % k=k+1;
            prodname=[pathname dirname(ii).name];
            if prodname(end)~='5' & dirname(ii).name(1)~='.'
                try
                    k=k+1;
                    infout=ncinfo(prodname);
                    start_time_day_of_year(k)=double(infout.Attributes(79).Value);
                    nameprod(k).path=prodname;
                catch
                end
            end
            if k==1;
                prodname=[pathname dirname(4).name];
                if prodname(end)~='5'
                    infout=ncinfo(prodname);
                else
                    prodname=[pathname dirname(5).name];
                    infout=ncinfo(prodname);
                end
                cellat=ncread(prodname,'cellat');
            end
        end
        
    end
    
    for ii=1:366
        ind=find(start_time_day_of_year==ii);
        fileday(ii).indfile=ind;
    end
    
    disp('lecture attribut time OK')
    
    
    nlo=size(cellat,2);
    nla=size(cellat,3);
    ilo1=1:nlo;
    ila1=1:nla;
    
    [ila0, ilo0]=meshgrid(ila1, ilo1);
    
    % contenu d'un produit SMAP L2
    % time, cellat, cellon
    % gland, gice, sss_smap
    % surtep, winspd, sss_ref
    % iqc_flag, zang, alpha, eaa, eia, pra
    % sunglt, monglt, gallat, gallon, sun_beta, sun_alpha
    % ta_ant_filtered, ta_ant_calibrated, ta_earth
    % tb_toi, tb_toa, tb_toa_lc, tb_sur, tb_sur0
    % temp_ant, dtemp_ant
    % ta_sun_dir, ta_sun_ref, ta_gal_dir, ta_gal_ref, tb_consistency, ta_ant_exp
    % pratot_exp
    % tran, tbup, tbdw
    % windir, rain, solar_flux
    
    dll=0.25;
    lat0=-90.001:dll:90.001;     % limite des cases. Le centre des case définit la grille -> à utiliser pour l'interpolation
    mlat0=round(min(lat0*4))-1;
    lon0=-180.001:dll:180.001;   % limite des cases. Le centre des case définit la grille -> à utiliser pour l'interpolation
    mlon0=round(min(lon0*4))-1;
    
    % les noeuds de grille associés
    lonc=lon0(1:end-1)+dll/2;
    latc=lat0(1:end-1)+dll/2;
    nlon=length(lonc);
    nlat=length(latc);
    
    % map1=NaN(length(dirname),nlon,nlat);
    % map2=NaN(length(dirname),nlon,nlat);
    SSS1A=NaN(nlon,nlat);
    SSS2A=NaN(nlon,nlat);
    SSS1D=NaN(nlon,nlat);
    SSS2D=NaN(nlon,nlat);
    tSSS1A=NaN(nlon,nlat);
    tSSS2A=NaN(nlon,nlat);
    tSSS1D=NaN(nlon,nlat);
    tSSS2D=NaN(nlon,nlat);
    SST1A=NaN(nlon,nlat);
    SST2A=NaN(nlon,nlat);
    SST1D=NaN(nlon,nlat);
    SST2D=NaN(nlon,nlat);
    WS1A=NaN(nlon,nlat);
    WS2A=NaN(nlon,nlat);
    WS1D=NaN(nlon,nlat);
    WS2D=NaN(nlon,nlat);
    rain1A=NaN(nlon,nlat);
    rain2A=NaN(nlon,nlat);
    rain1D=NaN(nlon,nlat);
    rain2D=NaN(nlon,nlat);
    tb_consistency1A=NaN(nlon,nlat);
    tb_consistency2A=NaN(nlon,nlat);
    tb_consistency1D=NaN(nlon,nlat);
    tb_consistency2D=NaN(nlon,nlat);
    
    date0=datenum(2000,1,1,0,0,0);
    
    
    for iday=1:366 %length(dirname)
        iday
        tt0=dateyear0+iday-1;
        
        nfil=length(fileday(iday).indfile);
        vectt=datevec(tt0);
        yearc=num2str(vectt(1));
        monthc=num2str(vectt(2));
        if length(monthc)==1; monthc=['0' monthc]; end;
        dayc=num2str(vectt(3));
        if length(dayc)==1; dayc=['0' dayc]; end;
        filenamesave=[pathsave 'smapA_' yearc monthc dayc];
        
        if exist([filenamesave '.mat'])==0
            filenamesave
            for ii=1:nfil
                
                ifil=fileday(iday).indfile(ii);
                %   prodname=[pathname dirname(ifil).name];
                prodname=nameprod(ifil).path;
                
                try
                    tt=ncread(prodname,'time');  % en secondes depuis le 01/01/2000 à 0h00mn00s
                    gland=double(ncread(prodname,'gland'));
                    %figure; hold on; imagesc(squeeze(gland(1,:,:))'); caxis([0 1]); colorbar; hold off
                    gland=squeeze(reshape(gland,2*nla*nlo,1,1));
                    gice=double(ncread(prodname,'gice'));
                    gice0=NaN(2,size(gice,1),size(gice,2));
                    gice0(1,:,:)=gice;
                    gice0(2,:,:)=gice;
                    gice=squeeze(reshape(gice0,2*nla*nlo,1,1));
                    % sss_smap0=double(ncread(prodname,'sss_smap'));
                    sss_smap0=double(ncread(prodname,'sss_smap_40km'));
                    sss_smap=sss_smap0+NaN;
                    winspd=double(ncread(prodname,'winspd'));
                    surtep=double(ncread(prodname,'surtep'))-273.15;
                    rain=double(ncread(prodname,'rain'));
                    tb_consistency=double(ncread(prodname,'tb_consistency'));
                    iqc_flag=ncread(prodname,'iqc_flag');
                    
                    iqc=dec2bin(iqc_flag,32);
                    indok=find(iqc(:,32)=='0' & iqc(:,31)=='0' & iqc(:,30)=='0' & iqc(:,29)=='0' & ...
                        iqc(:,28)=='0' & iqc(:,27)=='0' & iqc(:,26)=='0' & iqc(:,25)=='0' & ...
                        iqc(:,22)=='0' & gland<0.01 & gice<0.001);
                    iqc_flag_ok=iqc_flag(indok);
                    iqc_flag=NaN+double(iqc_flag);
                    iqc_flag(indok)=iqc_flag_ok;
                    
                    sss_smap(indok)=sss_smap0(indok);
                    
                    selOKA=NaN+sss_smap;
                    selOKD=NaN+sss_smap;
                    selOKA(indok)=1;
                    selOKA(:,1:780,:)=NaN;
                    selOKD(indok)=1;
                    selOKD(:,781:1560,:)=NaN;
                    
                    % en jour
                    ttj=double(tt)/86400+date0;
                    
                    cellat=ncread(prodname,'cellat');
                    cellon=ncread(prodname,'cellon');
                    
                    for iorb=1:2
                        if iorb==1; selOK=selOKA; else; selOK=selOKD; end;
                        
                        for iaf=1:2
                            cellat0=squeeze(cellat(iaf,:,:));
                            cellon0=squeeze(cellon(iaf,:,:));
                            indcel=find(cellon0 >= 180);
                            cellon0(indcel)=cellon0(indcel)-360;
                            selOK0=squeeze(selOK(iaf,:,:));
                            sss_smap0=squeeze(sss_smap(iaf,:,:));
                            tb_consistency0=squeeze(tb_consistency(iaf,:,:));
                            ttt0=squeeze(ttj(iaf,:,:));
                            ind0=find(selOK0==1);
                            ngp=length(ind0);
                            
                            ilat=floor(cellat0(ind0)*4)-mlat0;  % indices sur la nouvelle grille à 0.25°
                            ilon=floor(cellon0(ind0)*4)-mlon0;
                            ilos=ilo0(ind0); % ancienne grille
                            ilas=ila0(ind0);
                            
                            if iaf==1;
                                if iorb==1
                                    for igp=1:ngp
                                        SSS1A(ilon(igp),ilat(igp))=sss_smap0(ilos(igp),ilas(igp));
                                        tSSS1A(ilon(igp),ilat(igp))=ttt0(ilos(igp),ilas(igp));
                                        WS1A(ilon(igp),ilat(igp))=winspd(ilos(igp),ilas(igp));
                                        SST1A(ilon(igp),ilat(igp))=surtep(ilos(igp),ilas(igp));
                                        rain1A(ilon(igp),ilat(igp))=rain(ilos(igp),ilas(igp));
                                        tb_consistency1A(ilon(igp),ilat(igp))=tb_consistency0(ilos(igp),ilas(igp));
                                    end
                                else
                                    for igp=1:ngp
                                        SSS1D(ilon(igp),ilat(igp))=sss_smap0(ilos(igp),ilas(igp));
                                        tSSS1D(ilon(igp),ilat(igp))=ttt0(ilos(igp),ilas(igp));
                                        WS1D(ilon(igp),ilat(igp))=winspd(ilos(igp),ilas(igp));
                                        SST1D(ilon(igp),ilat(igp))=surtep(ilos(igp),ilas(igp));
                                        rain1D(ilon(igp),ilat(igp))=rain(ilos(igp),ilas(igp));
                                        tb_consistency1D(ilon(igp),ilat(igp))=tb_consistency0(ilos(igp),ilas(igp));
                                    end
                                    % keyboard
                                end
                            else
                                if iorb==1
                                    for igp=1:ngp
                                        SSS2A(ilon(igp),ilat(igp))=sss_smap0(ilos(igp),ilas(igp));
                                        tSSS2A(ilon(igp),ilat(igp))=ttt0(ilos(igp),ilas(igp));
                                        WS2A(ilon(igp),ilat(igp))=winspd(ilos(igp),ilas(igp));
                                        SST2A(ilon(igp),ilat(igp))=surtep(ilos(igp),ilas(igp));
                                        rain2A(ilon(igp),ilat(igp))=rain(ilos(igp),ilas(igp));
                                        tb_consistency2A(ilon(igp),ilat(igp))=tb_consistency0(ilos(igp),ilas(igp));
                                    end
                                else
                                    for igp=1:ngp
                                        SSS2D(ilon(igp),ilat(igp))=sss_smap0(ilos(igp),ilas(igp));
                                        tSSS2D(ilon(igp),ilat(igp))=ttt0(ilos(igp),ilas(igp));
                                        WS2D(ilon(igp),ilat(igp))=winspd(ilos(igp),ilas(igp));
                                        SST2D(ilon(igp),ilat(igp))=surtep(ilos(igp),ilas(igp));
                                        rain2D(ilon(igp),ilat(igp))=rain(ilos(igp),ilas(igp));
                                        tb_consistency2D(ilon(igp),ilat(igp))=tb_consistency0(ilos(igp),ilas(igp));
                                    end
                                end
                            end
                        end
                    end
                catch
                end
            end
            
            % keyboard
            % interpolation sur la grille EASE
            SSS1A=interp2(lonc,latc,SSS1A',lone,late,'nearest');
            SSS2A=interp2(lonc,latc,SSS2A',lone,late,'nearest');
            tSSS1A=interp2(lonc,latc,tSSS1A',lone,late,'nearest');
            tSSS2A=interp2(lonc,latc,tSSS2A',lone,late,'nearest');
            WS1A=interp2(lonc,latc,WS1A',lone,late,'nearest');
            WS2A=interp2(lonc,latc,WS2A',lone,late,'nearest');
            rain1A=interp2(lonc,latc,rain1A',lone,late,'nearest');
            rain2A=interp2(lonc,latc,rain2A',lone,late,'nearest');
            SST1A=interp2(lonc,latc,SST1A',lone,late,'nearest');
            SST2A=interp2(lonc,latc,SST2A',lone,late,'nearest');
            tb_consistency1A=interp2(lonc,latc,tb_consistency1A',lone,late,'nearest');
            tb_consistency2A=interp2(lonc,latc,tb_consistency2A',lone,late,'nearest');
            
            SSS1D=interp2(lonc,latc,SSS1D',lone,late,'nearest');
            SSS2D=interp2(lonc,latc,SSS2D',lone,late,'nearest');
            tSSS1D=interp2(lonc,latc,tSSS1D',lone,late,'nearest');
            tSSS2D=interp2(lonc,latc,tSSS2D',lone,late,'nearest');
            WS1D=interp2(lonc,latc,WS1D',lone,late,'nearest');
            WS2D=interp2(lonc,latc,WS2D',lone,late,'nearest');
            rain1D=interp2(lonc,latc,rain1D',lone,late,'nearest');
            rain2D=interp2(lonc,latc,rain2D',lone,late,'nearest');
            SST1D=interp2(lonc,latc,SST1D',lone,late,'nearest');
            SST2D=interp2(lonc,latc,SST2D',lone,late,'nearest');
            tb_consistency1D=interp2(lonc,latc,tb_consistency1D',lone,late,'nearest');
            tb_consistency2D=interp2(lonc,latc,tb_consistency2D',lone,late,'nearest');
            
            % ecriture
            if nfil > 1
                SSS1=SSS1A; SSS2=SSS2A;tSSS1=tSSS1A;tSSS2=tSSS2A;WS1=WS1A;WS2=WS2A;rain1=rain1A;rain2=rain2A;SST1=SST1A;SST2=SST2A;tb_consistency1=tb_consistency1A;tb_consistency2=tb_consistency2A;
                save([pathsave 'smapD_' yearc monthc dayc],'SSS1','SSS2','tSSS1','tSSS2','WS1','WS2','rain1','rain2','SST1','SST2','tb_consistency1','tb_consistency2')
                SSS1=SSS1D; SSS2=SSS2D;tSSS1=tSSS1D;tSSS2=tSSS2D;WS1=WS1D;WS2=WS2D;rain1=rain1D;rain2=rain2D;SST1=SST1D;SST2=SST2D;tb_consistency1=tb_consistency1D;tb_consistency2=tb_consistency2D;
                save([pathsave 'smapA_' yearc monthc dayc],'SSS1','SSS2','tSSS1','tSSS2','WS1','WS2','rain1','rain2','SST1','SST2','tb_consistency1','tb_consistency2')
            end
            % initialisation des tableaux
            SSS1A=NaN(nlon,nlat); SSS2A=NaN(nlon,nlat); SSS1D=NaN(nlon,nlat); SSS2D=NaN(nlon,nlat);
            tSSS1A=NaN(nlon,nlat); tSSS2A=NaN(nlon,nlat); tSSS1D=NaN(nlon,nlat); tSSS2D=NaN(nlon,nlat);
            SST1A=NaN(nlon,nlat); SST1D=NaN(nlon,nlat); SST2A=NaN(nlon,nlat); SST2D=NaN(nlon,nlat);
            WS1A=NaN(nlon,nlat); WS2A=NaN(nlon,nlat); WS1D=NaN(nlon,nlat); WS2D=NaN(nlon,nlat);
            rain1A=NaN(nlon,nlat); rain2A=NaN(nlon,nlat); rain1D=NaN(nlon,nlat); rain2D=NaN(nlon,nlat);
            tb_consistency1A=NaN(nlon,nlat); tb_consistency2A=NaN(nlon,nlat);
            tb_consistency1D=NaN(nlon,nlat); tb_consistency2D=NaN(nlon,nlat);
        end
        
        % keyboard
        
    end
end


