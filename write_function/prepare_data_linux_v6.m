% netcdf L4 product generation
% input     : mat files from compute_biais_CCI.m
% output    : L4 products in netcdf format
% date : 06/2019 (CCI+SSS year 1 project)
% author : JLV, ACRI-ST


clear
addpath ../
set(groot,'DefaultFigureColormap',jet)

load('..\latlon_ease.mat');
lat_fixgrid=lat_ease;
lon_fixgrid=lon_ease;
nla=length(lat_fixgrid);

load('..\mask_smos.mat')

% zones
minlontab=[-181  -165  -150  -135  -120  -105   -90   -75   -60   -45   -30   -15    0    15    30    45    60    75    90   105   120   135   150   165];
maxlontab=[-165  -150  -135  -120  -105   -90   -75   -60   -45   -30   -15     0   15    30    45    60    75    90   105   120   135   150   165   181];
minlattab=[ -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90  -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90];
maxlattab=[  90    90    90    90    90    90    90    90    90    90    90    90   90    90    90    90    90    90    90    90    90    90    90    90];

minlon=min(minlontab);
maxlon=max(maxlontab);
minlat=min(minlattab);
maxlat= max(maxlattab);

nzone=length(minlontab);

iquant=5;   % 5 pour la médiane, 8 pour le quantile à 80%
no_quant=0; % ==1 : pas de correction quantile.

load coast
lonc=long;
latc=lat;
tabrmax=[30, 55];

days19700101=datenum(1970,1,1,0,0,0);

% dirdwell='I:\dataSMOS\CATDS\SSTres\inversion_sigvar_corrlat_quant95\';
dirdwell='.\';

dir0='v2019_5\mediane\';

dires=['CCI\'];
if exist(dires)==0
    mkdir(dires)
end

vv='5';
product_version=['01.' vv];


savemap=0;      % sauvegarde des cartes moyennees
n0=['CCI\' dir0];
for icas=1:2
    icas
    if icas==1
        mens=1;
        window='mens';
    elseif icas==2
        mens=0;
        window='hebd';
    end
    if mens==0
        name_gen=[n0 '7days\'];
    else
        name_gen=[n0 '30days\'];
    end
    if exist(name_gen) == 0; mkdir(name_gen); end
    
    if mens==1
        name_gen=[name_gen 'ESACCI-SSS-L4-SSS-MERGED-OI-Monthly-CENTRED-15Day-25km-'];
    else
        name_gen=[name_gen 'ESACCI-SSS-L4-SSS-MERGED-OI-7DAY-RUNNINGMEAN-DAILY-25km-'];
    end
    
    namezone=['res_smos_smap_aqua_zone' num2str(7) '\'];
    namesave=[namezone 'dwell_centrale_' window '.mat'];
    load([dirdwell namesave])
    
    nday=length(tt);
    
    k=0;
    nb=2;
    for itim=1:nday
        %  SSSmens_map=squeeze(SSSmens(:,:,itim));
        %  SSShebd_map=squeeze(SSShebd(:,:,itim));
        %   if itim==50; figure; hold on; imagesc(lon,lat,SSSmens_map'); axis tight; caxis([32 38]); colorbar hold off; end
        ttt=tt(itim);
        vecd=datevec(ttt);
        datenom=datestr(ttt,30);
        if mens == 1 & (vecd(3)==1 | vecd(3)==15)
            k=k+1;
            name(k).nametot=[name_gen datenom(1:8) '-fv1.0.nc'];
            indtime(k)=itim;
            if exist([name_gen datenom(1:8) '-fv1.0.nc'])~=0
                delete([name_gen datenom(1:8) '-fv1.0.nc'])
            end
        elseif mens == 0
            k=k+1;
            name(k).nametot=[name_gen datenom(1:8) '-fv1.0.nc'];
            indtime(k)=itim;
            if exist([name_gen datenom(1:8) '-fv1.0.nc'])~=0
                delete([name_gen datenom(1:8) '-fv1.0.nc'])
            end
        end
    end
    
    nday=length(indtime);
    
    for itim=1:nday
        ttt=tt(indtime(itim));
        nametot=name(itim).nametot;
        nccreate(nametot,'lat','Dimensions',{'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'fillValue',NaN);
        ncwrite(nametot,'lat',lat_fixgrid);
        % ncwriteatt(nametot,'lat','FillValue',fillval);
        ncwriteatt(nametot,'lat','long_name','latitude');
        ncwriteatt(nametot,'lat','units','degrees_north');
        ncwriteatt(nametot,'lat','standard_name','latitude');
        ncwriteatt(nametot,'lat','valid_range','-90.f, 90.f');
        
        nccreate(nametot,'lon','Dimensions',{'lon' size(lon_fixgrid,1)},'Datatype','single','DeflateLevel',6,'fillValue',NaN);
        ncwrite(nametot,'lon',lon_fixgrid);
        ncwriteatt(nametot,'lon','long_name','longitude');
        ncwriteatt(nametot,'lon','units','degrees_east');
        ncwriteatt(nametot,'lon','standard_name','longitude');
        ncwriteatt(nametot,'lon','valid_range','-180.f, 180.f');
        
        ncwriteatt(nametot,'/','creation_time',datestr(now));
        
        Value= 'ESA SMOS CCI Sea Surface Salinity Product';
        ncwriteatt(nametot,'/','title',Value);
        
        Value= 'ACRI-ST; LOCEAN';
        ncwriteatt(nametot,'/','institution',Value);
        
        % fichier entree (origine des L2OS)
        Value= ['SMOS ESAL2OSv622/CATDS RE05, SMAP L2 RSS v3.0, Aquarius L3 v5.0'];
        ncwriteatt(nametot,'/','source',Value);
        
        Value= 'CCI processing';
        ncwriteatt(nametot,'/','history',Value);
        
        Value= 'http://cci.esa.int/salinity';
        ncwriteatt(nametot,'/','references',Value);
        
        Value =  product_version;
        ncwriteatt(nametot,'/','product_version',Value);
        
        Value =  'CF-1.7';
        ncwriteatt(nametot,'/','Conventions',Value);
        
        Value =  'ESA CCI Sea Surface Salinity';
        ncwriteatt(nametot,'/','Summary',Value);
        
        Value =  'Ocean, Ocean Salinity, Sea Surface Salinity, Satellite';
        ncwriteatt(nametot,'/','keywords',Value);
        
        Value =  'European Space Agency - ESA Climate Office';
        ncwriteatt(nametot,'/','naming_authority',Value);
        
        Value =  'NASA Global Change Master Directory (GCMD) Science Keywords';
        ncwriteatt(nametot,'/','keywords_vocabulary',Value);
        
        Value =  'Grid';
        ncwriteatt(nametot,'/','cdm_data_type',Value);
        
        if mens==1
            Value= 'Data are based on a monthly running mean objectively interpolated';
        else
            Value= 'Data are based on a 7-day running mean objectively interpolated';
        end
        
        ncwriteatt(nametot,'/','comment',Value);
        
        Value= 'ACRI-ST; LOCEAN';
        ncwriteatt(nametot,'/','creator_name',Value);
        
        Value= 'TBD';
        ncwriteatt(nametot,'/','creator_email',Value);
        
        Value= 'http://cci.esa.int/salinity';
        ncwriteatt(nametot,'/','creator_url',Value);
        
        Value= 'Climate Change Initiative - European Space Agency';
        ncwriteatt(nametot,'/','project',Value);
        
        Value= '-90.0';
        ncwriteatt(nametot,'/','geospatial_lat_min',Value);
        
        Value= '90.0';
        ncwriteatt(nametot,'/','geospatial_lat_max',Value);
        
        Value= '-180.0';
        ncwriteatt(nametot,'/','geospatial_lon_min',Value);
        
        Value= '180.0';
        ncwriteatt(nametot,'/','geospatial_lon_max',Value);
        
        Value= 'ESA CCI Data Policy: free and open access';
        ncwriteatt(nametot,'/','license',Value);
        
        Value= 'NetCDF Climate and Forecast (CF) Metadata Convention version 1.7';
        ncwriteatt(nametot,'/','standard_name_vocabulary',Value);
        
        Value= 'PROTEUS; SAC-D; SMAP';
        ncwriteatt(nametot,'/','platform',Value);
        
        Value= 'SMOS/MIRAS; Aquarius; SMAP';
        ncwriteatt(nametot,'/','sensor',Value);
        
        Value= '50km';
        ncwriteatt(nametot,'/','spatial_resolution',Value);
        
        Value= 'degrees_north';
        ncwriteatt(nametot,'/','geospatial_lat_units',Value);
        
        Value= 'degrees_east';
        ncwriteatt(nametot,'/','geospatial_lon_units',Value);
        
        Value= '0.5 at equator';
        ncwriteatt(nametot,'/','geospatial_lat_resolution',Value);
        
        Value= '0.5 at equator';
        ncwriteatt(nametot,'/','geospatial_lon_resolution',Value);
        
        Value= datestr(now,30);
        ncwriteatt(nametot,'/','date_created',Value);
        
        Value= '';
        ncwriteatt(nametot,'/','date_modified',Value);
        
        if mens==0
            ttt_init=ttt-3;
            ttt_end=ttt+3;
        else
            ttt_init=ttt-15;
            ttt_end=ttt+15;
        end
        
        Value= datestr(ttt_init,30);
        ncwriteatt(nametot,'/','time_coverage_start',Value);
        
        Value= datestr(ttt_end,30);
        ncwriteatt(nametot,'/','time_coverage_stop',Value);
        
            if mens==0
        Value= 'P7D';
    else
        Value= 'P1M';
    end

        ncwriteatt(nametot,'/','time_coverage_duration',Value);
        
        Value= '-';
        ncwriteatt(nametot,'/','time_coverage_resolution',Value);
        
        [path,fname,extension]=fileparts(nametot);
        
        Value= [fname extension];
        ncwriteatt(nametot,'/','id',Value);
        
        UUID = java.util.UUID.randomUUID;
        Value= char(UUID);
        ncwriteatt(nametot,'/','tracking_id',Value);    % uid : librairie  getuid
        
        ttt0=ttt-days19700101;
        
        nccreate(nametot,'time','Dimensions',{'time' 1},'Datatype','single','DeflateLevel',6,'fillValue',NaN);
        ncwrite(nametot,'time',single(ttt0));
        ncwriteatt(nametot,'time','long_name','time');
        ncwriteatt(nametot,'time','units','days since 1970-01-01 00:00:00 UTC');
        ncwriteatt(nametot,'time','standard_name','time');
        
        nccreate(nametot,'sss','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        ncwrite(nametot,'sss',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'sss','long_name','Unbiased merged Sea Surface Salinity');
        ncwriteatt(nametot,'sss','units','pss');
        ncwriteatt(nametot,'sss','standard_name','sea_surface_salinity');
        ncwriteatt(nametot,'sss','valid_min',0);
        ncwriteatt(nametot,'sss','valid_max',50);
        ncwriteatt(nametot,'sss','valid_range','0.f, 50.f');
        ncwriteatt(nametot,'sss','scale_factor',1);
        ncwriteatt(nametot,'sss','add_offset',0);
        
        nccreate(nametot,'sss_random_error','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        ncwrite(nametot,'sss_random_error',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'sss_random_error','long_name','Sea Surface Salinity Random Error');
        ncwriteatt(nametot,'sss_random_error','units','pss');
        ncwriteatt(nametot,'sss_random_error','standard_name','sea_surface_salinity_random_error');
        ncwriteatt(nametot,'sss_random_error','valid_min',0);
        ncwriteatt(nametot,'sss_random_error','valid_max',100);
        ncwriteatt(nametot,'sss_random_error','valid_range','0.f, 100.f');
        ncwriteatt(nametot,'sss_random_error','scale_factor',1);
        ncwriteatt(nametot,'sss_random_error','add_offset',0);
        
        nccreate(nametot,'noutliers','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','int16','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        ncwrite(nametot,'noutliers',int16(11+ceil(10*rand(size(lon_fixgrid,1),size(lat_fixgrid,1)))));
        ncwriteatt(nametot,'noutliers','long_name','Count of the Number of Outliers within this bin cell');
        ncwriteatt(nametot,'noutliers','units','NA');
        ncwriteatt(nametot,'noutliers','standard_name','number_of_outliers');
        ncwriteatt(nametot,'noutliers','valid_min',0);
        ncwriteatt(nametot,'noutliers','valid_max',10000);
        ncwriteatt(nametot,'noutliers','valid_range','0.f, 10000.f');
        ncwriteatt(nametot,'noutliers','scale_factor',1);
        ncwriteatt(nametot,'noutliers','add_offset',0);
        
        nccreate(nametot,'total_nobs','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','int16','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        ncwrite(nametot,'total_nobs',int16(11+ceil(10*rand(size(lon_fixgrid,1),size(lat_fixgrid,1)))));
        ncwriteatt(nametot,'total_nobs','long_name','Number of SSS in the time interval');
        ncwriteatt(nametot,'total_nobs','units','NA');
        ncwriteatt(nametot,'total_nobs','standard_name','Ndata');
        ncwriteatt(nametot,'total_nobs','valid_min',0);
        ncwriteatt(nametot,'total_nobs','valid_max',10000);
        ncwriteatt(nametot,'total_nobs','valid_range','0.f, 10000.f');
        ncwriteatt(nametot,'total_nobs','scale_factor',1);
        ncwriteatt(nametot,'total_nobs','add_offset',0);
        
        nccreate(nametot,'sss_bias_std','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        ncwrite(nametot,'sss_bias_std',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'sss_bias_std','long_name','Standard Deviation of the Bias in Sea Surface Salinity');
        ncwriteatt(nametot,'sss_bias_std','units','pss');
        ncwriteatt(nametot,'sss_bias_std','standard_name','sea_surface_salinity_bias_std');
        ncwriteatt(nametot,'sss_bias_std','valid_min',0);
        ncwriteatt(nametot,'sss_bias_std','valid_max',100);
        ncwriteatt(nametot,'sss_bias_std','valid_range','0.f, 100.f');
        ncwriteatt(nametot,'sss_bias_std','scale_factor',1);
        ncwriteatt(nametot,'sss_bias_std','add_offset',0);
        
        nccreate(nametot,'sss_bias','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        ncwrite(nametot,'sss_bias',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'sss_bias','long_name','Bias in Sea Surface Salinity');
        ncwriteatt(nametot,'sss_bias','units','pss');
        ncwriteatt(nametot,'sss_bias','standard_name','sea_surface_salinity_bias');
        ncwriteatt(nametot,'sss_bias','valid_min',-100);
        ncwriteatt(nametot,'sss_bias','valid_max',100);
        ncwriteatt(nametot,'sss_bias','valid_range','-100.f, 100.f');
        ncwriteatt(nametot,'sss_bias','scale_factor',1);
        ncwriteatt(nametot,'sss_bias','add_offset',0);
        
        nccreate(nametot,'pct_var','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        ncwrite(nametot,'pct_var',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'pct_var','long_name','Percentage of Explained Sea Surface Salinity Variance by the Sea Surface Salinity Standard Error');
        ncwriteatt(nametot,'pct_var','units','%');
        ncwriteatt(nametot,'pct_var','standard_name','percentage_variance');
        ncwriteatt(nametot,'pct_var','valid_min',0);
        ncwriteatt(nametot,'pct_var','valid_max',100);
        ncwriteatt(nametot,'pct_var','valid_range','0.f, 100.f');
        ncwriteatt(nametot,'pct_var','scale_factor',1);
        ncwriteatt(nametot,'pct_var','add_offset',0);
        
        nccreate(nametot,'sss_qc','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','int16','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        ncwrite(nametot,'sss_qc',int16(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'sss_qc','long_name','Sea Surface Salinity Quality, 1=Good; 0=Bad');
        ncwriteatt(nametot,'sss_qc','units','NA');
        ncwriteatt(nametot,'sss_qc','standard_name','flag');
        ncwriteatt(nametot,'sss_qc','valid_min',0);
        ncwriteatt(nametot,'sss_qc','valid_max',1);
        
    end
    
    %  for izone=1:nzone
    for izone=1:nzone
        % configuration
        izone
        minlon=minlontab(izone);
        maxlon=maxlontab(izone);
        minlat=minlattab(izone);
        maxlat= maxlattab(izone);
        minlon=minlontab(izone);
        maxlon=maxlontab(izone);
        indlonsel=find(lon<=maxlon & lon>minlon);
        nlon=length(indlonsel);
        namezone=['res_smos_smap_aqua_zone' num2str(izone) '\'];
        namesave=[namezone 'dwell_centrale_' window '.mat'];
        load([dirdwell namesave])
        
        if mens==0
            indNaN=find(SSSest_3sigma_hebd<8);
            SSSest_3sigma_hebd(indNaN)=NaN;
        end
        
        nok0=nok.*0+NaN;
        ind=find(nok > 0);
        nok0(ind)=1;
        iinit=indlonsel(1);
        ifin=indlonsel(end);
        
        if no_quant==0
            biais0_3sigma_iquant=squeeze(meanSMOS_quant(:,:,iquant)-meanISAS_quant(:,:,iquant));
        else
            biais0_3sigma_iquant=squeeze(meanSMOS_quant(:,:,iquant)).*0;
        end
       
        
        % calcul du quantile selon l'erreur de representativite
%         errtotsel=errtot(iinit:ifin,:);
%         iq=round((1.5*errtotsel-0.4)*10);
%         indlow=find(errtotsel<=0.6);
%         iq(indlow)=5;
%         indhigh=find(errtotsel>=0.8);
%         iq(indhigh)=8;
%         indNaN=find(isnan(iq));   % terre
%         iq(indNaN)=5;
%         for ilo=1:nlon
%             for ila=1:nla
%                 iquant=iq(ilo,ila);
%                 biais0_3sigma_iquant(ilo,ila)=meanSMOS_quant(ilo,ila,iquant)-meanISAS_quant(ilo,ila,iquant);
%             end
%         end

        for iti=1:nday;
            nametot=name(iti).nametot;
            indtime0=indtime(iti);
            if mens==1
                SSS0=squeeze(SSSest_3sigma_mens(:,:,indtime0)).*mask(indlonsel,:);
                corrSMOS0=SSS0-biais0_3sigma_iquant;
                corrSMOS1=corrSMOS0.*nok0;
            else
                SSS0=squeeze(SSSest_3sigma_hebd(:,:,indtime0)).*mask(indlonsel,:);
                corrSMOS0=SSS0-biais0_3sigma_iquant;
                corrSMOS1=corrSMOS0.*nok0;
            end
          %  toto=ncread(nametot,'sss');
          %  toto(iinit:ifin,:)=corrSMOS1;
          %  ncwrite(nametot,'sss',single(toto));
            ncwrite(nametot,'sss',single(corrSMOS1),[indlonsel(1), 1]);
        end
    end
    
    % for izone=1:nzone
    for izone=1:nzone
        
        % configuration
        izone
        minlon=minlontab(izone);
        maxlon=maxlontab(izone);
        minlat=minlattab(izone);
        maxlat= maxlattab(izone);
        minlon=minlontab(izone);
        maxlon=maxlontab(izone);
        indlonsel=find(lon<=maxlon & lon>minlon);
        namezone=['res_smos_smap_aqua_zone' num2str(izone) '\'];
        namesave=[namezone 'dwell_centrale_ind_' window '.mat'];
        load([dirdwell namesave])
        iinit=indlonsel(1);
        ifin=indlonsel(end);
        
        nok0=nok.*0;
        ind=find(nok > 0);
        nok0(ind)=1;
        for iti=1:nday;
            nametot=name(iti).nametot;
            indtime0=indtime(iti)
            
            if mens==1
                corrSMOS1=single(squeeze(errSSSest_mens(:,:,indtime0)).*mask(indlonsel,:));
            else
                corrSMOS1=single(squeeze(errSSSest_hebd(:,:,indtime0)).*mask(indlonsel,:));
            end
           % toto=ncread(nametot,'sss_random_error');
           % toto(iinit:ifin,:)=corrSMOS1;
           % ncwrite(nametot,'sss_random_error',single(toto));
            ncwrite(nametot,'sss_random_error',single(corrSMOS1),[indlonsel(1), 1]);

            % ncwrite(nametot,'random_error',corrSMOS1,[indlonsel(1), 1]);
            % eSSS
            %             'tt','lonregion','latregion','datemois','nok', ...
            %             'outlier_mens','errSSSest_mens','ndata_mens','stb_bias_mens','mean_bias_mens','pctvar_mens',  ...
            %             'biais_est_mens','quantil','meanSMOS_quant','meanISAS_quant','conf'
            %
            if mens==1
                corrSMOS1=int16(squeeze(outlier_mens(:,:,indtime0)).*mask(indlonsel,:));
            else
                corrSMOS1=int16(squeeze(outlier_hebd(:,:,indtime0)).*mask(indlonsel,:));
            end
           % toto=ncread(nametot,'noutliers');
           % toto(iinit:ifin,:)=corrSMOS1;
           % ncwrite(nametot,'noutliers',int16(toto));
            ncwrite(nametot,'noutliers',int16(corrSMOS1),[indlonsel(1), 1]);
            
            %ncwrite(nametot,'noutlier',corrSMOS1,[indlonsel(1), 1]);
            %
            if mens==1
                corrSMOS1=int16(squeeze(ndata_mens(:,:,indtime0)).*mask(indlonsel,:));
            else
                corrSMOS1=int16(squeeze(ndata_hebd(:,:,indtime0)).*mask(indlonsel,:));
            end
            indnogood=find(corrSMOS1==0);
           % toto=ncread(nametot,'total_nobs');
           % toto(iinit:ifin,:)=corrSMOS1;
           % ncwrite(nametot,'total_nobs',int16(toto));
            ncwrite(nametot,'total_nobs',int16(corrSMOS1),[indlonsel(1), 1]);
            
            if mens==1
                corrSMOS1=squeeze(mean_bias_mens(:,:,indtime0)).*mask(indlonsel,:);
            else
                corrSMOS1=squeeze(mean_bias_hebd(:,:,indtime0)).*mask(indlonsel,:);
            end
           % toto=ncread(nametot,'sss_bias');
           % toto(iinit:ifin,:)=corrSMOS1;
           % ncwrite(nametot,'sss_bias',single(toto));
            ncwrite(nametot,'sss_bias',single(corrSMOS1),[indlonsel(1), 1]);
            
            if mens==1
                corrSMOS1=squeeze(stb_bias_mens(:,:,indtime0)).*mask(indlonsel,:);
            else
                corrSMOS1=squeeze(stb_bias_hebd(:,:,indtime0)).*mask(indlonsel,:);
            end
           % toto=ncread(nametot,'sss_bias_std');
           % toto(iinit:ifin,:)=corrSMOS1;
           % ncwrite(nametot,'sss_bias_std',single(toto));
            ncwrite(nametot,'sss_bias_std',single(corrSMOS1),[indlonsel(1), 1]);
         
            if mens==1
                corrSMOS1=100*squeeze(pctvar_mens(:,:,indtime0)).*mask(indlonsel,:);
            else
                corrSMOS1=100*squeeze(pctvar_hebd(:,:,indtime0)).*mask(indlonsel,:);
            end
            %toto=ncread(nametot,'pct_var');
            %toto(iinit:ifin,:)=corrSMOS1;
            %ncwrite(nametot,'pct_var',single(toto));
            ncwrite(nametot,'pct_var',single(corrSMOS1),[indlonsel(1), 1]);
            
           % toto=ncread(nametot,'sss_qc');
            corrSMOS1(:,:)=1;
            corrSMOS1(indnogood)=0;
           % toto(iinit:ifin,:)=corrSMOS1;
           % ncwrite(nametot,'sss_qc',int16(toto));
            ncwrite(nametot,'sss_qc',int16(corrSMOS1),[indlonsel(1), 1]);
            
        end
    end
end

% on relit et reecrit les donnees pour mieux les compresser
n0=['CCI\' dir0];

icas=1;

if icas==1
    mens=1;
    window='mens';
elseif icas==2
    mens=0;
    window='hebd';
end
if mens==0
    name_gen=[n0 '7days\'];
else
    name_gen=[n0 '30days\'];
end
if exist(name_gen) == 0; mkdir(name_gen); end

dirname=dir(name_gen);

for itim=3:length(dirname)
    itim
    namefile=[name_gen dirname(itim).name];
    
    delete('toto')
    nametot='toto';
    
    nccreate(nametot,'lat','Dimensions',{'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'fillValue',NaN);
    ncwrite(nametot,'lat',lat_fixgrid);
    % ncwriteatt(nametot,'lat','FillValue',fillval);
    ncwriteatt(nametot,'lat','long_name','latitude');
    ncwriteatt(nametot,'lat','units','degrees_north');
    ncwriteatt(nametot,'lat','standard_name','latitude');
    ncwriteatt(nametot,'lat','valid_range','-90.f, 90.f');
    
    nccreate(nametot,'lon','Dimensions',{'lon' size(lon_fixgrid,1)},'Datatype','single','DeflateLevel',6,'fillValue',NaN);
    ncwrite(nametot,'lon',lon_fixgrid);
    ncwriteatt(nametot,'lon','long_name','longitude');
    ncwriteatt(nametot,'lon','units','degrees_east');
    ncwriteatt(nametot,'lon','standard_name','longitude');
    ncwriteatt(nametot,'lon','valid_range','-180.f, 180.f');
    
    ncwriteatt(nametot,'/','creation_time',datestr(now));
    
    Value= 'ESA SMOS CCI Sea Surface Salinity Product';
    ncwriteatt(nametot,'/','title',Value);
    
    Value= 'ACRI-ST; LOCEAN';
    ncwriteatt(nametot,'/','institution',Value);
    
    % fichier entree (origine des L2OS)
    Value= ['SMOS ESAL2OSv622/CATDS RE05, SMAP L2 RSS v3.0, Aquarius L3 v5.0'];
    ncwriteatt(nametot,'/','source',Value);
    
    Value= 'CCI processing';
    ncwriteatt(nametot,'/','history',Value);
    
    Value= 'http://cci.esa.int/salinity';
    ncwriteatt(nametot,'/','references',Value);
    
    Value =  product_version;
    ncwriteatt(nametot,'/','product_version',Value);
    
    Value =  'CF-1.7';
    ncwriteatt(nametot,'/','Conventions',Value);
    
    Value =  'ESA CCI Sea Surface Salinity';
    ncwriteatt(nametot,'/','Summary',Value);
    
    Value =  'Ocean, Ocean Salinity, Sea Surface Salinity, Satellite';
    ncwriteatt(nametot,'/','keywords',Value);
    
    Value =  'European Space Agency - ESA Climate Office';
    ncwriteatt(nametot,'/','naming_authority',Value);
    
    Value =  'NASA Global Change Master Directory (GCMD) Science Keywords';
    ncwriteatt(nametot,'/','keywords_vocabulary',Value);
    
    Value =  'Grid';
    ncwriteatt(nametot,'/','cdm_data_type',Value);
    
    if mens==1
        Value= 'Data are based on a monthly running mean objectively interpolated';
    else
        Value= 'Data are based on a 7-day running mean objectively interpolated';
    end
    
    ncwriteatt(nametot,'/','comment',Value);
    
    Value= 'ACRI-ST; LOCEAN';
    ncwriteatt(nametot,'/','creator_name',Value);
    
    Value= 'TBD';
    ncwriteatt(nametot,'/','creator_email',Value);
    
    Value= 'http://cci.esa.int/salinity';
    ncwriteatt(nametot,'/','creator_url',Value);
    
    Value= 'Climate Change Initiative - European Space Agency';
    ncwriteatt(nametot,'/','project',Value);
    
    Value= '-90.0';
    ncwriteatt(nametot,'/','geospatial_lat_min',Value);
    
    Value= '90.0';
    ncwriteatt(nametot,'/','geospatial_lat_max',Value);
    
    Value= '-180.0';
    ncwriteatt(nametot,'/','geospatial_lon_min',Value);
    
    Value= '180.0';
    ncwriteatt(nametot,'/','geospatial_lon_max',Value);
    
    Value= 'ESA CCI Data Policy: free and open access';
    ncwriteatt(nametot,'/','license',Value);
    
    Value= 'NetCDF Climate and Forecast (CF) Metadata Convention version 1.7';
    ncwriteatt(nametot,'/','standard_name_vocabulary',Value);
    
    Value= 'PROTEUS; SAC-D; SMAP';
    ncwriteatt(nametot,'/','platform',Value);
    
    Value= 'SMOS/MIRAS; Aquarius; SMAP';
    ncwriteatt(nametot,'/','sensor',Value);
    
    Value= '50km';
    ncwriteatt(nametot,'/','spatial_resolution',Value);
    
    Value= 'degrees_north';
    ncwriteatt(nametot,'/','geospatial_lat_units',Value);
    
    Value= 'degrees_east';
    ncwriteatt(nametot,'/','geospatial_lon_units',Value);
    
    Value= '0.5 at equator';
    ncwriteatt(nametot,'/','geospatial_lat_resolution',Value);
    
    Value= '0.5 at equator';
    ncwriteatt(nametot,'/','geospatial_lon_resolution',Value);
    
    Value= datestr(now,30);
    ncwriteatt(nametot,'/','date_created',Value);
    
    Value= '';
    ncwriteatt(nametot,'/','date_modified',Value);
    
    Value= ncreadatt(namefile,'/','time_coverage_start');
    ncwriteatt(nametot,'/','time_coverage_start',Value);
    
    Value= ncreadatt(namefile,'/','time_coverage_stop');
    ncwriteatt(nametot,'/','time_coverage_stop',Value);
    
        if mens==0
        Value= 'P7D';
    else
        Value= 'P1M';
    end

    ncwriteatt(nametot,'/','time_coverage_duration',Value);
    
    Value= '-';
    ncwriteatt(nametot,'/','time_coverage_resolution',Value);
    
    [path,fname,extension]=fileparts(nametot);
    
    Value= [fname extension];
    ncwriteatt(nametot,'/','id',Value);
    
    UUID = java.util.UUID.randomUUID;
    Value= char(UUID);
    ncwriteatt(nametot,'/','tracking_id',Value);    % uid : librairie  getuid
    
    ttt0=ncread(namefile,'time');
    ttt0=ttt0(1);
    nccreate(nametot,'time','Dimensions',{'time' 1},'Datatype','single','DeflateLevel',6,'fillValue',NaN);
    ncwrite(nametot,'time',single(ttt0));
    ncwriteatt(nametot,'time','long_name','time');
    ncwriteatt(nametot,'time','units','days since 1970-01-01 00:00:00 UTC');
    ncwriteatt(nametot,'time','standard_name','time');
    
    SSS=ncread(namefile,'sss');
    ndata=ncread(namefile,'total_nobs');
    ind=find(isnan(SSS) | SSS<=0 | ndata==0 | isnan(ndata));
    SSS(ind)=NaN;
    random_error=ncread(namefile,'sss_random_error');
    random_error(ind)=NaN;
    noutlier=ncread(namefile,'noutliers');
    noutlier(ind)=NaN;
    ndata(ind)=NaN;
    std_bias=ncread(namefile,'sss_bias_std');
    std_bias(ind)=NaN;
    systematic_error=ncread(namefile,'sss_bias');
    systematic_error(ind)=NaN;
    pctvar=ncread(namefile,'pct_var');
    pctvar(ind)=NaN;
    sss_qc=ncread(namefile,'sss_qc');
    sss_qc(ind)=NaN;
    
    nccreate(nametot,'sss','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
    ncwrite(nametot,'sss',single(SSS));
    ncwriteatt(nametot,'sss','long_name','Unbiased merged Sea Surface Salinity');
    ncwriteatt(nametot,'sss','units','pss');
    ncwriteatt(nametot,'sss','standard_name','sea_surface_salinity');
    ncwriteatt(nametot,'sss','valid_min',0);
    ncwriteatt(nametot,'sss','valid_max',50);
    ncwriteatt(nametot,'sss','valid_range','0.f, 50.f');
    ncwriteatt(nametot,'sss','scale_factor',1);
    ncwriteatt(nametot,'sss','add_offset',0);
    
    nccreate(nametot,'sss_random_error','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
    ncwrite(nametot,'sss_random_error',single(random_error));
    ncwriteatt(nametot,'sss_random_error','long_name','Sea Surface Salinity Random Error');
    ncwriteatt(nametot,'sss_random_error','units','pss');
    ncwriteatt(nametot,'sss_random_error','standard_name','sea_surface_salinity_random_error');
    ncwriteatt(nametot,'sss_random_error','valid_min',0);
    ncwriteatt(nametot,'sss_random_error','valid_max',100);
    ncwriteatt(nametot,'sss_random_error','valid_range','0.f, 100.f');
    ncwriteatt(nametot,'sss_random_error','scale_factor',1);
    ncwriteatt(nametot,'sss_random_error','add_offset',0);
    
    nccreate(nametot,'noutliers','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','int16','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
    ncwrite(nametot,'noutliers',int16(noutlier));
    ncwriteatt(nametot,'noutliers','long_name','Count of the Number of Outliers within this bin cell');
    ncwriteatt(nametot,'noutliers','units','NA');
    ncwriteatt(nametot,'noutliers','standard_name','number_of_outliers');
    ncwriteatt(nametot,'noutliers','valid_min',0);
    ncwriteatt(nametot,'noutliers','valid_max',10000);
    ncwriteatt(nametot,'noutliers','valid_range','0.f, 10000.f');
    ncwriteatt(nametot,'noutliers','scale_factor',1);
    ncwriteatt(nametot,'noutliers','add_offset',0);
    
    nccreate(nametot,'total_nobs','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','int16','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
    ncwrite(nametot,'total_nobs',int16(ndata));
    ncwriteatt(nametot,'total_nobs','long_name','Number of SSS in the time interval');
    ncwriteatt(nametot,'total_nobs','units','NA');
    ncwriteatt(nametot,'total_nobs','standard_name','Ndata');
    ncwriteatt(nametot,'total_nobs','valid_min',0);
    ncwriteatt(nametot,'total_nobs','valid_max',10000);
    ncwriteatt(nametot,'total_nobs','valid_range','0.f, 10000.f');
    ncwriteatt(nametot,'total_nobs','scale_factor',1);
    ncwriteatt(nametot,'total_nobs','add_offset',0);
    
    nccreate(nametot,'sss_bias_std','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
    ncwrite(nametot,'sss_bias_std',single(std_bias));
    ncwriteatt(nametot,'sss_bias_std','long_name','Standard Deviation of the Bias in Sea Surface Salinity');
    ncwriteatt(nametot,'sss_bias_std','units','pss');
    ncwriteatt(nametot,'sss_bias_std','standard_name','sea_surface_salinity_bias_std');
    ncwriteatt(nametot,'sss_bias_std','valid_min',0);
    ncwriteatt(nametot,'sss_bias_std','valid_max',100);
    ncwriteatt(nametot,'sss_bias_std','valid_range','0.f, 100.f');
    ncwriteatt(nametot,'sss_bias_std','scale_factor',1);
    ncwriteatt(nametot,'sss_bias_std','add_offset',0);
    
    nccreate(nametot,'sss_bias','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
    ncwrite(nametot,'sss_bias',single(systematic_error));
    ncwriteatt(nametot,'sss_bias','long_name','Bias in Sea Surface Salinity');
    ncwriteatt(nametot,'sss_bias','units','pss');
    ncwriteatt(nametot,'sss_bias','standard_name','sea_surface_salinity_bias');
    ncwriteatt(nametot,'sss_bias','valid_min',-100);
    ncwriteatt(nametot,'sss_bias','valid_max',100);
    ncwriteatt(nametot,'sss_bias','valid_range','-100.f, 100.f');
    ncwriteatt(nametot,'sss_bias','scale_factor',1);
    ncwriteatt(nametot,'sss_bias','add_offset',0);
    
    nccreate(nametot,'pct_var','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
    ncwrite(nametot,'pct_var',single(pctvar));
    ncwriteatt(nametot,'pct_var','long_name','Percentage of Explained Sea Surface Salinity Variance by the Sea Surface Salinity Standard Error');
    ncwriteatt(nametot,'pct_var','units','%');
    ncwriteatt(nametot,'pct_var','standard_name','percentage_variance');
    ncwriteatt(nametot,'pct_var','valid_min',0);
    ncwriteatt(nametot,'pct_var','valid_max',100);
    ncwriteatt(nametot,'pct_var','valid_range','0.f, 100.f');
    ncwriteatt(nametot,'pct_var','scale_factor',1);
    ncwriteatt(nametot,'pct_var','add_offset',0);
    
    nccreate(nametot,'sss_qc','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1)},'Datatype','int16','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
    ncwrite(nametot,'sss_qc',int16(sss_qc));
    ncwriteatt(nametot,'sss_qc','long_name','Sea Surface Salinity Quality, 1=Good; 0=Bad');
    ncwriteatt(nametot,'sss_qc','units','NA');
    ncwriteatt(nametot,'sss_qc','standard_name','flag');
    ncwriteatt(nametot,'sss_qc','valid_min',0);
    ncwriteatt(nametot,'sss_qc','valid_max',1);
    
    movefile('toto',namefile,'f')
    
end
