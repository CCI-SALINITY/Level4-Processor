% function nfil=writeL4_OPER_002_010(conf_file)

conf_file='CCI_CNF_writeL4_001_004_1_week.xml'
% netcdf L4 product generation
% input     : mat files from compute_biais_CCI.m
% output    : L4 products in netcdf format
% date : 06/2019 (CCI+SSS year 1 project)
% author : JLV, ACRI-ST
% from prepare_data_linux_v8.m
% date : 02/2020 (CCI+SSS year 2 project)
% flag adding
% attributs correction
% new absolute correction added
% Ice mask from Acard (20/02/2020)
% optimization with time slices
% changement du title  16/04/2020
% changement calcul des flags
% application de mask_smos pour les flags land sea
% ordre des dimensions passe en (lon,lat,time) pour convention produits
% ajout ancillary pour les key variables


time0=cputime;
nom_proc1='writeL4';
conf0=xml_read(conf_file);

pathlog=conf0.OUTPUT_FILE.log_path.CONTENT;
datecreate=datestr(clock,30);


logname=[pathlog 'jobtrace_' datecreate '.out'];
ftrace=fopen(logname,'a+t');

dir_product_mat=conf0.INPUT_FILE.dir_product_mat.CONTENT;

if exist(conf0.AUX_FILE.latlon_ease.CONTENT)
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] AUX File   : ' conf0.AUX_FILE.latlon_ease.CONTENT 10]);
else
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [W] AUX File   : ' conf0.AUX_FILE.latlon_ease.CONTENT ' NOT FOUND' 10]);
    fclose(ftrace);
    return
end
load(conf0.AUX_FILE.latlon_ease.CONTENT);  %'lat_ease','lon_ease','nlat','nlon';

lat_fixgrid=lat_ease;
lon_fixgrid=lon_ease;
nla=length(lat_fixgrid);

if exist(conf0.AUX_FILE.mask_smos.CONTENT)
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] AUX File   : ' conf0.AUX_FILE.mask_smos.CONTENT 10]);
else
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [W] AUX File   : ' conf0.AUX_FILE.mask_smos.CONTENT ' NOT FOUND' 10]);
    fclose(ftrace);
    return
end
load(conf0.AUX_FILE.mask_smos.CONTENT);


if exist(conf0.AUX_FILE.dmin.CONTENT)
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] AUX File   : ' conf0.AUX_FILE.dmin.CONTENT 10]);
else
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [W] AUX File   : ' conf0.AUX_FILE.dmin.CONTENT ' NOT FOUND' 10]);
    fclose(ftrace);
    return
end
load(conf0.AUX_FILE.dmin.CONTENT);

if exist(conf0.AUX_FILE.err_rep.CONTENT)
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] AUX File   : ' conf0.AUX_FILE.err_rep.CONTENT 10]);
else
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [W] AUX File   : ' conf0.AUX_FILE.err_rep.CONTENT ' NOT FOUND' 10]);
    fclose(ftrace);
    return
end
load(conf0.AUX_FILE.err_rep.CONTENT);
errtot=sqrt(mean(errrepres.*errrepres,3));

if exist(conf0.AUX_FILE.Acard_mat.CONTENT)
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] AUX File   : ' conf0.AUX_FILE.Acard_mat.CONTENT 10]);
else
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [W] AUX File   : ' conf0.AUX_FILE.Acard_mat.CONTENT ' NOT FOUND' 10]);
    fclose(ftrace);
    return
end
rep_Acard=conf0.AUX_FILE.Acard_mat.CONTENT;

nfil=0;

% mise a jour d'un existant ou non
update_netcdf=conf0.param.update_netcdf.CONTENT;

% limites des differentes zones
minlon=conf0.INPUT_FILE.zones.minlon.CONTENT;
maxlon=conf0.INPUT_FILE.zones.maxlon.CONTENT;
minlat=conf0.INPUT_FILE.zones.minlat.CONTENT;
maxlat=conf0.INPUT_FILE.zones.maxlat.CONTENT;

nzone=length(minlon);

iquant=conf0.param.iquant.CONTENT;   % 5 pour la m�diane, 8 pour le quantile � 80%
no_quant=conf0.param.no_quant.CONTENT; % ==1 : pas de correction quantile.
outmax=conf0.param.outmax.CONTENT;   % flag fraction outlier
distmax=conf0.param.distmax.CONTENT;  % flag cotier
icemax=conf0.param.icemax.CONTENT;   % flag ice

days19700101=datenum(1970,1,1,0,0,0);

window0=conf0.INPUT_FILE.product_type;
if strcmp(window0,'mens')
    dires=conf0.OUTPUT_FILE.output_path_mens.CONTENT;
    name_gen=conf0.OUTPUT_FILE.name_generic_mens;
else
    dires=conf0.OUTPUT_FILE.output_path_hebd.CONTENT;
    name_gen=conf0.OUTPUT_FILE.name_generic_hebd;
end

datemin=datenum(conf0.OUTPUT_FILE.datemin);
datemax=datenum(conf0.OUTPUT_FILE.datemax);

if exist(dires)==0; mkdir(dires); end

vv=[num2str(conf0.INPUT_FILE.product_version)];  % year3 : on retire le '0'

namesave=['prod_Lm_' num2str(abs(minlon(1))) '_LM_' num2str(abs(maxlon(1))) '_lm_' num2str(abs(minlat(1))) '_lM_' num2str(abs(maxlat(1))) '_' window0 '.mat'];
load([dir_product_mat namesave],'tt')

nday0=length(tt);

% construction des noms des fichiers de sortie selon le cas mens ou hebd
k=0;
indtime0=[];
for itim=1:nday0
    %  SSSmens_map=squeeze(SSSmens(:,:,itim));
    %  SSShebd_map=squeeze(SSShebd(:,:,itim));
    %   if itim==50; figure; hold on; imagesc(lon,lat,SSSmens_map'); axis tight; caxis([32 38]); colorbar hold off; end
    ttt=tt(itim);
    vecd=datevec(ttt);
    yearc=num2str(vecd(1));
    vecd=datevec(ttt);
    datenom=datestr(ttt,30);
    % cas mensuel
    if window0 == 'mens' & (vecd(3)==1 | vecd(3)==15) & ttt<datemax & ttt>datemin  % conditions sur les produits mensuels uniquement
        k=k+1;
        name(k).nametot=[dires yearc filesep name_gen datenom(1:8) '-fv' vv '.nc'];
        indtime0(k)=itim;   % selection des jours dans le cas mensuel (le 1er et le 15 du mois)
        
        if exist(name(k).nametot)==0 & update_netcdf==1
            fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [W] UPDATE mode not possible for : ' name(k).nametot ' NOT FOUND' 10]);
            fclose(ftrace);
            return
        end
        
        if exist(name(k).nametot)~=0 & update_netcdf==0  % si le fichier existe et qu'on ne veut pas le mettre a jour, on le detruit
            delete(name(k).nametot)
        end
    elseif window0 == 'hebd' & ttt<datemax & ttt>datemin
        k=k+1;
        name(k).nametot=[dires yearc filesep name_gen datenom(1:8) '-fv' vv '.nc'];
        indtime0(k)=itim;   % selection des jours dans le cas hebdo : tous les jours
        
        if exist(name(k).nametot)==0 & update_netcdf==1
            fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [W] UPDATE mode not possible for : ' name(k).nametot ' NOT FOUND' 10]);
            fclose(ftrace);
            return
        end
        
        if exist(name(k).nametot)~=0 & update_netcdf==0  % si le fichier existe et qu'on ne veut pas le mettre a jour, on le detruit
            delete(name(k).nametot)
        end
    end
end

nday0=length(indtime0);  % nombre de produits

indtime=indtime0;        % indtime est initialise a indtime0 mais est ensuite utilise tranche par tranche temporelle

% decoupe en ntr tranche temporelle si nday0 > 1000
nslice=300;   % nombre de jours � traiter par tranche
% initialisation (en cas d'une seule tranche)
ntr=1;
inds(1)=1;
inds(2)=nday0;
% si plusieurs tranches
if nday0 > nslice
    ntr=floor(nday0/nslice);   % nombre de tranches temporelles
    inds=1:nslice:nday0;       % indices de d�but et de fin de tranche
    if ntr*nslice < nday0; inds(end+1)=nday0; ntr=ntr+1; end;  % traitement de la derniere ttranche
end

% connstruction des fichiers
% on ne fait pas de tranches temporelles pour construire les fichiers
tt235959=(23*3600+59*60+59)/24/3600;  % 23h59mn59s en jour
if update_netcdf==0    % on cr�e le fichier, on ne le met pas � jour
    for itim=1:nday0
        ttt=tt(indtime0(itim));
        vecd=datevec(ttt);
        yearc=num2str(vecd(1));
        if exist([dires yearc]) == 0; mkdir([dires yearc]); end;
        
        nametot=name(itim).nametot;
        
        nccreate(nametot,'lat','Dimensions',{'lat' size(lat_fixgrid,1)},'Datatype','single','DeflateLevel',6,'fillValue',NaN);
        ncwrite(nametot,'lat',lat_fixgrid);
        % ncwriteatt(nametot,'lat','FillValue',fillval);
        ncwriteatt(nametot,'lat','long_name','latitude');
        ncwriteatt(nametot,'lat','units','degrees_north');
        ncwriteatt(nametot,'lat','standard_name','latitude');
        ncwriteatt(nametot,'lat','valid_min',-90); % correction 24/03/2020
        ncwriteatt(nametot,'lat','valid_max',90); % correction 24/03/2020
        % ncwriteatt(nametot,'lat','valid_range','-90.f, 90.f'); % correction 24/03/2020
        
        nccreate(nametot,'lon','Dimensions',{'lon' size(lon_fixgrid,1)},'Datatype','single','DeflateLevel',6,'fillValue',NaN);
        ncwrite(nametot,'lon',lon_fixgrid);
        ncwriteatt(nametot,'lon','long_name','longitude');
        ncwriteatt(nametot,'lon','units','degrees_east');
        ncwriteatt(nametot,'lon','standard_name','longitude');
        ncwriteatt(nametot,'lon','valid_min',-180); % correction 24/03/2020
        ncwriteatt(nametot,'lon','valid_max',180); % correction 24/03/2020
        % ncwriteatt(nametot,'lon','valid_range','-180.f, 180.f'); % correction 24/03/2020
        
        ncwriteatt(nametot,'/','creation_time',datestr(now));
        
        if strcmp(window0,'mens')
            Value= 'ESA CCI Sea Surface Salinity ECV produced at a spatial resolution of 50 km and time resolution of 1 month and spatially resampled on 25 km EASE grid and 15 days of time sampling';  % year2 correction
        else
            Value= 'ESA CCI Sea Surface Salinity ECV produced at a spatial resolution of 50 km and time resolution of one week and spatially resampled on 25 km EASE grid and 1 day of time sampling';  % year2 correction
        end
        ncwriteatt(nametot,'/','title',Value);
        
        Value=['This third version of the CCI+SSS products is a preliminary version. ', ...     % year3 correction
            'This product has not been fully validated yet ', ...
            'and may contain flaws. In case you discover some, we ',...
            '(Mngt_CCI-Salinity@argans.co.uk) are very keen to get your feedback. ',...
            'In case you would like to use them in a presentation or publication, ',...
            'please contact us to get their correct reference (doi attribution in progress)'];
        ncwriteatt(nametot,'/','comment',Value);
        
        Value= 'ACRI-ST,LOCEAN'; % year3
        ncwriteatt(nametot,'/','institution',Value);
        
        % fichier entree (origine des L2OS)
        Value= ['SMOS CCI v3 L2OS reprocessing (ERA5,ref OTT SSS:ISAS, RFI filtering) from DPGS L1 v620, L2OS v662 modified as in DOI:10.1109/tgrs.2020.3030488, SMAP L2 RSS v4.0 - DOI:10.5067/SMP40-2SOCS, Aquarius L3 v5.0 - DOI:10.5067/AQR50-3SQCS'];   % year3 DOI SMAP complete
        ncwriteatt(nametot,'/','source',Value);
        
        Value= ' ';  % year2 correction
        ncwriteatt(nametot,'/','history',Value);
        
        Value= 'http://cci.esa.int/salinity - DOI:XXXXX';    % year2 DOI � compl�ter
        ncwriteatt(nametot,'/','references',Value);
        
        Value =  vv;  % year3
        ncwriteatt(nametot,'/','product_version',Value);
        
        Value = 'CCI Data Standards v2.2' ;  % year3
        ncwriteatt(nametot,'/','format_version',Value);
        
        Value =  'CF-1.8';   % year3 passage de la 1.7 a la 1.8
        ncwriteatt(nametot,'/','Conventions',Value);
        
        Value =  'ESA CCI Sea Surface Salinity';  % year2
        ncwriteatt(nametot,'/','summary',Value);   % correction year2 Summary -> summary
        
        Value =  'Ocean, Ocean Salinity, Sea Surface Salinity, Satellite';  % year2
        ncwriteatt(nametot,'/','keywords',Value);
        
        Value =  'sss,sss_random_error';  % year3
        ncwriteatt(nametot,'/','key_variables',Value);
        
        Value =  'European Space Agency - ESA Climate Office';  % year2
        ncwriteatt(nametot,'/','naming_authority',Value);
        
        Value =  'NASA Global Change Master Directory (GCMD) Science Keywords'; % year2
        ncwriteatt(nametot,'/','keywords_vocabulary',Value);
        
        Value =  'Grid';  % year2
        ncwriteatt(nametot,'/','cdm_data_type',Value);
        
        if strcmp(window0,'mens')
            Value= 'Data are based on a monthly running mean objectively interpolated';
        else
            Value= 'Data are based on a 7-day running mean objectively interpolated';
        end
        
        ncwriteatt(nametot,'/','comment',Value);
        
        Value= 'ACRI-ST,LOCEAN';  % year3
        ncwriteatt(nametot,'/','creator_name',Value);
        
        Value= 'jean-luc.vergely@acri-st.fr';  % year2
        ncwriteatt(nametot,'/','creator_email',Value);
        
        Value= 'http://cci.esa.int/salinity';  % year2
        ncwriteatt(nametot,'/','creator_url',Value);
        
        Value= 'Climate Change Initiative - European Space Agency';  % year2
        ncwriteatt(nametot,'/','project',Value);
        
        Value= lat_ease(1);  % year2 type ?
        ncwriteatt(nametot,'/','geospatial_lat_min',Value);
        
        Value= lat_ease(end);  % year2 type ?
        ncwriteatt(nametot,'/','geospatial_lat_max',Value);
        
        Value= lon_ease(1);  % year2 type ?
        ncwriteatt(nametot,'/','geospatial_lon_min',Value);
        
        Value= lon_ease(end); % year2 type ?
        ncwriteatt(nametot,'/','geospatial_lon_max',Value);
        
        Value= 'ESA CCI Data Policy: free and open access';  % year2
        ncwriteatt(nametot,'/','license',Value);
        
        Value= 'NetCDF Climate and Forecast (CF) Metadata Convention version 1.8';  % year3 passage de la 1.7 a la 1.8
        ncwriteatt(nametot,'/','standard_name_vocabulary',Value);
        
        Value= 'PROTEUS,SAC-D,SMAP';  % year3
        ncwriteatt(nametot,'/','platform',Value);
        
        Value= 'SMOS/MIRAS,Aquarius,SMAP';  % year3
        ncwriteatt(nametot,'/','sensor',Value);
        
        Value= '50km';  % year2
        ncwriteatt(nametot,'/','spatial_resolution',Value);
        
        Value= 'degrees_north';  % year2
        ncwriteatt(nametot,'/','geospatial_lat_units',Value);
        
        Value= 'degrees_east';  % year2
        ncwriteatt(nametot,'/','geospatial_lon_units',Value);
        
        %         Value= '0.1962 at equator';     % year2 correction (0.5 in year1)
        %         ncwriteatt(nametot,'/','geospatial_lat_resolution',Value);
        %
        %         Value= '0.2594';     % year2 correction (0.5 in year1)
        %         ncwriteatt(nametot,'/','geospatial_lon_resolution',Value);
        
        Value=0;   % year2 ajout
        ncwriteatt(nametot,'/','geospatial_vertical_min',Value);
        
        Value=0;   % year2 ajout
        ncwriteatt(nametot,'/','geospatial_vertical_max',Value);
        
        Value= [datestr(now,30) 'Z'];  % year2
        ncwriteatt(nametot,'/','date_created',Value);
        
        Value= ''; % year2
        ncwriteatt(nametot,'/','date_modified',Value);
        
        if strcmp(window0,'hebd')  % year2
            %  ttt_init=ttt-3.5;  % correction year2
            %  ttt_end=ttt+3.5;   % correction year2
            % demande de correction Fred R. year2
            ttt_init=ttt-4;  % correction year2
            ttt_end=ttt+3+tt235959 ;   % correction year2
        else
            ttt_init=ttt-14;    % correction year2
            ttt_end=ttt+15+tt235959;  % correction year2
        end
        
        Value= [datestr(ttt_init,30) 'Z'];  % year2
        ncwriteatt(nametot,'/','time_coverage_start',Value);
        
        Value= [datestr(ttt_end,30) 'Z'];   % year2
        ncwriteatt(nametot,'/','time_coverage_end',Value);  % correction time_coverage_stop -> time_coverage_end
        
        if strcmp(window0,'hebd')   % year2
            Value= 'P7D';
        else
            Value= 'P1M';
        end
        
        ncwriteatt(nametot,'/','time_coverage_duration',Value);
        
        if strcmp(window0,'hebd')   % year3
            Value= 'P1D';  % year3 correction
        else
            Value= 'P15D';  % year3 correction
        end
        ncwriteatt(nametot,'/','time_coverage_resolution',Value);
        
        [path,fname,extension]=fileparts(nametot);
        
        Value= [fname extension];  % year2
        ncwriteatt(nametot,'/','id',Value);
        
        UUID = java.util.UUID.randomUUID;
        Value= char(UUID);  % year2
        ncwriteatt(nametot,'/','tracking_id',Value);    % uid : librairie  getuid
        
        Value = '25km EASE 2 cylindrical grid';   % ajout year2 correction year 3
        ncwriteatt(nametot,'/','spatial_grid',Value);
        
        ttt0=ttt-days19700101;
        
        nccreate(nametot,'time','Dimensions',{'time' Inf},'Datatype','single','DeflateLevel',6,'fillValue',NaN);
        ncwrite(nametot,'time',single(ttt0));
        ncwriteatt(nametot,'time','long_name','time');
        ncwriteatt(nametot,'time','units','days since 1970-01-01 00:00:00 UTC');
        ncwriteatt(nametot,'time','standard_name','time');
        ncwriteatt(nametot,'time','calendar','standard');   % correction 24/03/2020
        
        nccreate(nametot,'sss','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        %  ncwrite(nametot,'sss',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'sss','long_name','Unbiased merged Sea Surface Salinity');
        % ncwriteatt(nametot,'sss','units','pss');   % correction 24/03/2020
        ncwriteatt(nametot,'sss','standard_name','sea_surface_salinity');
        ncwriteatt(nametot,'sss','valid_min',0);
        ncwriteatt(nametot,'sss','valid_max',50);
        ncwriteatt(nametot,'sss','ancilliary','noutliers total_nobs sss_qc');
        % ncwriteatt(nametot,'sss','valid_range','0.f, 50.f');  % correction 24/03/2020
        % ncwriteatt(nametot,'sss','scale_factor',1); % correction 24/03/2020
        % ncwriteatt(nametot,'sss','add_offset',0); % correction 24/03/2020
        
        
        nccreate(nametot,'sss_random_error','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        %  ncwrite(nametot,'sss_random_error',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'sss_random_error','long_name','Sea Surface Salinity Random Error');
        % ncwriteatt(nametot,'sss_random_error','units','pss');
        %  ncwriteatt(nametot,'sss_random_error','standard_name','sea_surface_salinity_random_error');   % correction 24/03/2020
        ncwriteatt(nametot,'sss_random_error','valid_min',0);
        ncwriteatt(nametot,'sss_random_error','valid_max',100);
        ncwriteatt(nametot,'sss_random_error','ancilliary','pct_var');
        % ncwriteatt(nametot,'sss_random_error','valid_range','0.f, 100.f'); % correction 24/03/2020
        %  ncwriteatt(nametot,'sss_random_error','scale_factor',1); % correction 24/03/2020
        % ncwriteatt(nametot,'sss_random_error','add_offset',0); % correction 24/03/2020
        
        nccreate(nametot,'noutliers','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','int16','DeflateLevel',6,'Shuffle',true);
        %  ncwrite(nametot,'noutliers',single(11+ceil(10*rand(size(lon_fixgrid,1),size(lat_fixgrid,1)))));
        ncwriteatt(nametot,'noutliers','long_name','Count of the Number of Outliers within this bin cell');
        % ncwriteatt(nametot,'noutliers','units','NA'); correction 24/03/2020
        %  ncwriteatt(nametot,'noutliers','standard_name','number_of_outliers');  % correction 24/03/2020
        ncwriteatt(nametot,'noutliers','valid_min',int16(0));
        ncwriteatt(nametot,'noutliers','valid_max',int16(10000));
        %  ncwriteatt(nametot,'noutliers','valid_range','0.f, 10000.f');  % correction 24/03/2020
        %  ncwriteatt(nametot,'noutliers','scale_factor',1); % correction 24/03/2020
        %  ncwriteatt(nametot,'noutliers','add_offset',0); % correction 24/03/2020
        
        nccreate(nametot,'total_nobs','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','int16','DeflateLevel',6,'Shuffle',true);
        %  ncwrite(nametot,'total_nobs',single(11+ceil(10*rand(size(lon_fixgrid,1),size(lat_fixgrid,1)))));
        ncwriteatt(nametot,'total_nobs','long_name','Number of SSS in the time interval');
        %  ncwriteatt(nametot,'total_nobs','units','NA'); correction 24/03/2020
        %  ncwriteatt(nametot,'total_nobs','standard_name','Ndata');   % correction 24/03/2020
        ncwriteatt(nametot,'total_nobs','valid_min',int16(0));
        ncwriteatt(nametot,'total_nobs','valid_max',int16(10000));
        % ncwriteatt(nametot,'total_nobs','valid_range','0.f, 10000.f'); % correction 24/03/2020
        % ncwriteatt(nametot,'total_nobs','scale_factor',1);  % correction 24/03/2020
        % ncwriteatt(nametot,'total_nobs','add_offset',0);  % correction 24/03/2020
        
        
        % retrait year3
        %         nccreate(nametot,'sss_bias_std','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        %         %  ncwrite(nametot,'sss_bias_std',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        %         ncwriteatt(nametot,'sss_bias_std','long_name','Standard Deviation of the Bias in Sea Surface Salinity');
        %       %  ncwriteatt(nametot,'sss_bias_std','units','pss');   % correction 24/03/2020
        %       %  ncwriteatt(nametot,'sss_bias_std','standard_name','sea_surface_salinity_bias_std');  % correction 24/03/2020
        %         ncwriteatt(nametot,'sss_bias_std','valid_min',0);
        %         ncwriteatt(nametot,'sss_bias_std','valid_max',100);
        %        % ncwriteatt(nametot,'sss_bias_std','valid_range','0.f, 100.f');  % correction 24/03/2020
        %        % ncwriteatt(nametot,'sss_bias_std','scale_factor',1);  % correction 24/03/2020
        %        % ncwriteatt(nametot,'sss_bias_std','add_offset',0);    % correction 24/03/2020
        %
        %         nccreate(nametot,'sss_bias','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        %         %  ncwrite(nametot,'sss_bias',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        %         ncwriteatt(nametot,'sss_bias','long_name','Bias in Sea Surface Salinity');
        %       %  ncwriteatt(nametot,'sss_bias','units','pss');   % correction 24/03/2020
        %        % ncwriteatt(nametot,'sss_bias','standard_name','sea_surface_salinity_bias');  % correction 24/03/2020
        %         ncwriteatt(nametot,'sss_bias','valid_min',-100);
        %         ncwriteatt(nametot,'sss_bias','valid_max',100);
        %        % ncwriteatt(nametot,'sss_bias','valid_range','-100.f, 100.f');  % correction 24/03/2020
        %        % ncwriteatt(nametot,'sss_bias','scale_factor',1);  % correction 24/03/2020
        %        % ncwriteatt(nametot,'sss_bias','add_offset',0);   % correction 24/03/2020
        
        nccreate(nametot,'pct_var','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','single','DeflateLevel',6,'Shuffle',true,'fillValue',NaN);
        %  ncwrite(nametot,'pct_var',single(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'pct_var','long_name','Percentage of SSS_variability that is expected to be not explained by the products');
        ncwriteatt(nametot,'pct_var','units','%');
        %  ncwriteatt(nametot,'pct_var','standard_name','percentage_variance');   % correction 24/03/2020
        ncwriteatt(nametot,'pct_var','valid_min',0);
        ncwriteatt(nametot,'pct_var','valid_max',100);
        %  ncwriteatt(nametot,'pct_var','valid_range','0.f, 100.f');  % correction 24/03/2020
        % ncwriteatt(nametot,'pct_var','scale_factor',1);  % correction 24/03/2020
        % ncwriteatt(nametot,'pct_var','add_offset',0);   % correction 24/03/2020
        
        nccreate(nametot,'sss_qc','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','int8','DeflateLevel',6,'Shuffle',true);
        %  ncwrite(nametot,'sss_qc',int8(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'sss_qc','long_name','Sea Surface Salinity Quality, 0=Good; 1=Bad');
        % ncwriteatt(nametot,'sss_qc','units','NA'); % correction 24/03/2020
        % ncwriteatt(nametot,'sss_qc','standard_name','flag');  % correction 24/03/2020
        ncwriteatt(nametot,'sss_qc','valid_min',int8(0));
        ncwriteatt(nametot,'sss_qc','valid_max',int8(1));
        
        nccreate(nametot,'lsc_qc','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','int8','DeflateLevel',6,'Shuffle',true);
        %  ncwrite(nametot,'lsc_qc',int8(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'lsc_qc','long_name','Land Sea Contamination Quality Check, 0=Good; 1=Bad');
        % ncwriteatt(nametot,'lsc_qc','units','NA'); % correction 24/03/2020
        % ncwriteatt(nametot,'lsc_qc','standard_name','flag');   % correction 24/03/2020
        ncwriteatt(nametot,'lsc_qc','valid_min',int8(0));
        ncwriteatt(nametot,'lsc_qc','valid_max',int8(1));
        
        nccreate(nametot,'isc_qc','Dimensions',{'lon' size(lon_fixgrid,1) 'lat' size(lat_fixgrid,1) 'time' 1},'Datatype','int8','DeflateLevel',6,'Shuffle',true);
        %  ncwrite(nametot,'isc_qc',int8(rand(size(lon_fixgrid,1),size(lat_fixgrid,1))));
        ncwriteatt(nametot,'isc_qc','long_name','Ice Sea Contamination Quality Check, 0=Good; 1=Bad');
        %  ncwriteatt(nametot,'isc_qc','units','NA'); correction 24/03/2020
        %  ncwriteatt(nametot,'isc_qc','standard_name','flag');   % correction 24/03/2020
        ncwriteatt(nametot,'isc_qc','valid_min',int8(0));
        ncwriteatt(nametot,'isc_qc','valid_max',int8(1));
        
    end
end

fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] Product Attributs OK, n= ' num2str(nday0)  10]);


fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] nslice temp tot= ' num2str(ntr)  10]);

% ecriture des fichiers tranche par tranche
for intr=1:ntr
    
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] nslice temp= ' num2str(intr)  10]);
    
    indtime=indtime0(inds(intr):(inds(intr+1)-1));  % indice temporelle journalier pour la tranche intr
    iitime=inds(intr):(inds(intr+1)-1);   % indices a appliquer dans la structure name
    if intr==ntr; indtime=indtime0(inds(intr):inds(intr+1)); iitime=inds(intr):inds(intr+1); end
    nday=length(indtime);
    
    biais0_3sigma_iquant0=[];
    SSSest_3sigma0=[];
    %   mean_bias_mens0=[];
    nok0=[];
    
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] Product SSS and bias START, n= ' num2str(nday)  10]);
    
    for izone=1:nzone
        % configuration
        izone
        
        fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] zone= ' num2str(izone)  10]);
        
        %  donnees mensuelles
        % 'tt','lonregion','latregion','datemois', ...
        % 'chi2_3sigma_mens','SSSoutlier_mens','nok','SSSest_3sigma_mens','SSSest_nocorr_mens', ...
        % 'biais_est_mens', 'biais0_3sigma_mens','biais0_3sigma_hebd', 'biais0_3sigma_quant90', 'biais0_3sigma_quant95', ...
        % 'isasSSSsel','ttisasday','minindtimeisas','maxindtimeisas', 'bsmos', 'esmos', ...
        % 'xswathsel','xswathlim','lon','lat','xswath','conf','SSTmoy','quantil','meanSMOS_quant','meanISAS_quant','meanISAS_quant_noise','-v7.3')
        
        %  donnees hebdos
        % 'tt','lonregion','latregion','datemois', ...
        % 'chi2_3sigma_hebd','SSSoutlier_hebd','nok','SSSest_3sigma_hebd','SSSest_nocorr_hebd', ...
        % 'biais_est_mens', 'biais0_3sigma_mens','biais0_3sigma_hebd', 'biais0_3sigma_quant90', 'biais0_3sigma_quant95', ...
        % 'isasSSSsel','ttisasday','minindtimeisas','maxindtimeisas','bsmos', 'esmos', ...
        % 'xswathsel','xswathlim','lon','lat','xswath','conf','SSTmoy','quantil','meanSMOS_quant','meanISAS_quant','meanISAS_quant_noise', '-v7.3')
        
        
        % les biais relatifs et absolus sont calcules a partir des donnees mensuelles
        % on repete donc le memes biais dans les donnees hebdo
        
        namesave=['prod_Lm_' num2str(abs(minlon(izone))) '_LM_' num2str(abs(maxlon(izone))) '_lm_' num2str(abs(minlat(izone))) '_lM_' num2str(abs(maxlat(izone))) '_mens.mat'];
        load([dir_product_mat namesave],'meanSMOS_quant','meanISAS_quant','bsmos','nok');
        
        indlonsel=find(lon_fixgrid<=maxlon(izone) & lon_fixgrid>minlon(izone));
        indlatsel=find(lat_fixgrid<=maxlat(izone) & lat_fixgrid>minlat(izone));
        nlon0=length(indlonsel);
        nla0=length(indlatsel);
        
        iinit=indlonsel(1);
        ifin=indlonsel(end);
        
        biais0_3sigma_iquant=nan(nlon0,nla0);
        if no_quant==0
            biais0_3sigma_iquant=squeeze(meanSMOS_quant(:,:,iquant)-meanISAS_quant(:,:,iquant));
        elseif no_quant==1
            biais0_3sigma_iquant=squeeze(meanSMOS_quant(:,:,iquant)).*0;
        elseif no_quant==2 % on module avec la variabilite (ATBD year 1)
            % calcul du quantile selon l'erreur de representativite
            errtotsel=errtot(iinit:ifin,:);
            iq=round((1.5*errtotsel-0.4)*10);  % num�ro du quantile qui est echantillonne tous les 10%
            indlow=find(errtotsel<=0.6);
            iq(indlow)=5;   % correspond au quantile � 50 %
            indhigh=find(errtotsel>=0.8);
            iq(indhigh)=8;   % correspond au quantile � 80 %
            indNaN=find(isnan(iq));   % terre
            iq(indNaN)=5;
            for ilo=1:nlon0
                for ila=1:nla0
                    iquant=iq(ilo,ila);
                    biais0_3sigma_iquant(ilo,ila)=meanSMOS_quant(ilo,ila,iquant)-meanISAS_quant(ilo,ila,iquant);
                end
            end
        elseif no_quant==3 % calcul de la correction absolue par ajustement des derniers quantiles (ATBD ajout year2)
            biais0_3sigma_iquant=bsmos;
        end
        
        namesave_ind=['prod_Lm_' num2str(abs(minlon(izone))) '_LM_' num2str(abs(maxlon(izone))) '_lm_' num2str(abs(minlat(izone))) '_lM_' num2str(abs(maxlat(izone))) '_ind_mens.mat'];
        load([dir_product_mat namesave_ind],'mean_bias_mens');
        mean_bias_mens=mean_bias_mens(:,:,indtime);
        namesave=['prod_Lm_' num2str(abs(minlon(izone))) '_LM_' num2str(abs(maxlon(izone))) '_lm_' num2str(abs(minlat(izone))) '_lM_' num2str(abs(maxlat(izone))) '_' window0 '.mat'];
        if strcmp(window0,'mens')
            load([dir_product_mat namesave],'SSSest_3sigma_mens');
            SSS0=squeeze(SSSest_3sigma_mens(:,:,indtime));
        else
            load([dir_product_mat namesave],'SSSest_3sigma_hebd');
            SSS0=squeeze(SSSest_3sigma_hebd(:,:,indtime));
        end
        
        biais0_3sigma_iquant0=[biais0_3sigma_iquant0; biais0_3sigma_iquant];
        SSSest_3sigma0=[SSSest_3sigma0; SSS0];
        %  mean_bias_mens0=[mean_bias_mens0; mean_bias_mens];
        
        nok1=nok.*0+NaN;
        ind=find(nok > 0);
        nok1(ind)=1;
        
        nok0=[nok0; nok1];  % attention, ce n'est pas un masque qui depend du temps
    end
    
    indnonphy=find(SSSest_3sigma0>40 | SSSest_3sigma0<0);  % ajout year3
    SSSest_3sigma0(indnonphy)=NaN;
    % maskSSS depend du temps (contrairement a nok0)
    maskSSS=SSSest_3sigma0./SSSest_3sigma0;   % maskSSS = NaN si SSS=NaN ou SSS>40 ou SSS<0 ou continent. Mettre fillvalue si ==NaN pour toutes les autres variables
    % on ajoute la contrainte nok0 a maskSSS pour n'avoir � g�rer qu'un
    % seul mask global
    for iti=1:nday;
        maskSSS(:,:,iti)=maskSSS(:,:,iti).*nok0;  % mask de NaN et de 1  Si NaN, fillvalue sur toute les variables
    end
    % application du masque SSS  year 3 : si SSS est NaN alors les autres
    % parametres aussi
    % on supprime le masque SMOS land-sea
    SSSest_3sigma0=SSSest_3sigma0.*maskSSS;
    % mean_bias_mens0=mean_bias_mens0.*maskSSS;
    
    % produits mensuels
    % 'tt','lonregion','latregion','datemois','nok','bsmos', 'esmos', ...
    % 'outlier_mens','errSSSest_mens','ndata_mens','stb_bias_mens','mean_bias_mens','pctvar_mens','ice_mens', ...
    % 'biais_est_mens','quantil','meanSMOS_quant','meanISAS_quant','meanISAS_quant_noise','conf','-v7.3')
    % produits hebdo
    % 'tt','lonregion','latregion','datemois','nok','bsmos', 'esmos', ...
    % 'outlier_hebd','errSSSest_hebd','ndata_hebd','stb_bias_hebd','mean_bias_hebd','pctvar_hebd','ice_hebd', ...
    % 'biais_est_mens','quantil','meanSMOS_quant','meanISAS_quant','meanISAS_quant_noise','conf','-v7.3')
    
    % ecriture des champs SSS et SSSbiais
    % POUR LE BIAIS, on prend l'info mensuelle uniquement
    
    corrSMOS1=nan(size(lon_fixgrid,1),size(lat_fixgrid,1),1);
    for iti=1:nday;
        nametot=name(iitime(iti)).nametot;
        corrSMOS0=SSSest_3sigma0(:,:,iti)-biais0_3sigma_iquant0(:,:);
        corrSMOS1(1:size(corrSMOS0,1),:,1)=corrSMOS0;
        %indnonphy=find(corrSMOS1>40 | corrSMOS1<0); % suppression year3
        %corrSMOS1(indnonphy)=NaN;                   % suppression year3
        ncwrite(nametot,'sss',single(corrSMOS1));
        %   corrSMOS2=squeeze(mean_bias_mens0(:,:,iti));     % suppression year3
        %   corrSMOS0=corrSMOS2-biais0_3sigma_iquant0;     % biais complet (relatif + absolu), year2 % suppression year3
        %   corrSMOS1(1,1:size(corrSMOS0,1),:)=corrSMOS0;    % suppression year3
        %   ncwrite(nametot,'sss_bias',single(corrSMOS1));  % suppression year3
    end
    
    
    clear SSSest_3sigma0 biais0_3sigma_iquant0
    
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] Product SSS and bias OK, n= ' num2str(nday)  10]);
    
    
    % erreur SSS, outliers, ndata
    corrSMOS0=[];
    outlier0=[];
    ndata0=[];
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] Product sssqc, lsc_qc, ssserror, noutlier, nobs START, n= ' num2str(nday)  10]);
    
    % for izone=1:nzone
    for izone=1:nzone
        % configuration
        izone
        
        fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] zone= ' num2str(izone)  10]);
        
        %save([namesave '_ind_hebd.mat'],'tt','lonregion','latregion','datemois','nok','bsmos', 'esmos', ...
        %'outlier_hebd','errSSSest_hebd','ndata_hebd','stb_bias_hebd','mean_bias_hebd','pctvar_hebd','ice_hebd', ...
        %'biais_est_mens','quantil','meanSMOS_quant','meanISAS_quant','meanISAS_quant_noise','conf','-v7.3')
        namesave=['prod_Lm_' num2str(abs(minlon(izone))) '_LM_' num2str(abs(maxlon(izone))) '_lm_' num2str(abs(minlat(izone))) '_lM_' num2str(abs(maxlat(izone))) '_ind_' window0 '.mat'];
        
        if strcmp(window0,'mens')
            load([dir_product_mat namesave],'errSSSest_mens','outlier_mens','ndata_mens');
            corrSMOS1=squeeze(errSSSest_mens(:,:,indtime));
            outlier1=squeeze(outlier_mens(:,:,indtime));
            ndata1=squeeze(ndata_mens(:,:,indtime));
            size(ndata1);
        else
            load([dir_product_mat namesave],'errSSSest_hebd','outlier_hebd','ndata_hebd');
            corrSMOS1=squeeze(errSSSest_hebd(:,:,indtime));
            outlier1=squeeze(outlier_hebd(:,:,indtime));
            ndata1=squeeze(ndata_hebd(:,:,indtime));
        end
        
        corrSMOS0=[corrSMOS0; corrSMOS1];
        outlier0=[outlier0;outlier1];
        ndata0=[ndata0; ndata1];
    end
    
    % on met a -1 si ce n'est pas renseigne
    indNaN=find(isnan(maskSSS));
    outlier0(indNaN)=-1;
    ndata0(indNaN)=-1;
    
    % application du masque SSS
    corrSMOS0=corrSMOS0.*maskSSS;
    outlier0=outlier0;
    ndata0=ndata0;
    
    % ecriture des produits
    corrSMOS1=nan(size(lon_fixgrid,1),size(lat_fixgrid,1),1);
    corrSMOS2=nan(size(lon_fixgrid,1),size(lat_fixgrid,1),1);
    corrSMOS3=nan(size(lon_fixgrid,1),size(lat_fixgrid,1),1);
    for iti=1:nday;
        % on met des -1 pour les flags si la SSS n'est pas estimee
        maskSSS0=zeros(length(lon_fixgrid),length(lat_fixgrid),1);
        maskSSS0(:,:,1)=maskSSS(:,:,iti);
        indNaN=find(isnan(maskSSS0));
        
        nametot=name(iitime(iti)).nametot;
        corrSMOS11=corrSMOS0(:,:,iti);
        corrSMOS1(1:size(corrSMOS0,1),:,1)=corrSMOS11.*nok0;
        corrSMOS22=outlier0(:,:,iti);
        corrSMOS2(1:size(corrSMOS0,1),:,1)=corrSMOS22;
        corrSMOS33=ndata0(:,:,iti);
        corrSMOS3(1:size(corrSMOS0,1),:,1)=corrSMOS33;
        
        ncwrite(nametot,'sss_random_error',single(corrSMOS1));
        
        ncwrite(nametot,'noutliers',int16(corrSMOS2));
        ncwrite(nametot,'total_nobs',int16(corrSMOS3));
        
        fracout=squeeze(corrSMOS22./corrSMOS33);
        ind_outlier=find(fracout>outmax);
        corrSMOS11=zeros(size(corrSMOS0,1),nlat);   % 0 est pris comme good data (changements v1.5 -> v1.6)
        corrSMOS11(ind_outlier)=1;
        corrSMOS1(1:size(corrSMOS0,1),:,1)=corrSMOS11;
        corrSMOS1(indNaN)=-1;
        ncwrite(nametot,'sss_qc',int8(corrSMOS1));
        
        dminsel=dmin(1:size(corrSMOS0,1),:);
        masksel=mask(1:size(corrSMOS0,1),:);
        ind_coast=find(dminsel<distmax | masksel==1);   % mask contient l'ancien masque SSS de la v1.8 et la v2.3 year3
        corrSMOS11(:,:)=zeros(size(corrSMOS0,1),nlat);      % 0 est pris comme good data (changements v1.5 -> v1.6)
        corrSMOS11(ind_coast)=1;
        corrSMOS1(1:size(corrSMOS0,1),:,1)=corrSMOS11;
        corrSMOS1(indNaN)=-1;
        ncwrite(nametot,'lsc_qc',int8(corrSMOS1));
    end
    
    clear corrSMOS0 outlier0 ndata0
    
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] Product sssqc, lsc_qc, ssserror, noutlier, nobs OK, n= ' num2str(nday)  10]);
    
    % std bias, ice flag, pctvar0;
    corrSMOS0=[];
    ice0=[];
    pctvar0=[];
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] Product std bias, ice flag, pctvar START, n= ' num2str(nday)  10]);
    
    for izone=1:nzone
        %for izone=4:4
        % configuration
        izone
        
        fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] zone= ' num2str(izone)  10]);
        
        namesave=['prod_Lm_' num2str(abs(minlon(izone))) '_LM_' num2str(abs(maxlon(izone))) '_lm_' num2str(abs(minlat(izone))) '_lM_' num2str(abs(maxlat(izone))) '_ind_' window0 '.mat'];
        if strcmp(window0,'mens')
            load([dir_product_mat namesave],'stb_bias_mens','ice_mens','pctvar_mens');
            %  corrSMOS1=squeeze(stb_bias_mens(:,:,indtime));
            %  ice=squeeze(ice_mens(:,:,indtime));
            pctvar=squeeze(pctvar_mens(:,:,indtime));
        else
            load([dir_product_mat namesave],'stb_bias_hebd','ice_hebd','pctvar_hebd');
            %  corrSMOS1=squeeze(stb_bias_hebd(:,:,indtime));
            %  ice=squeeze(ice_hebd(:,:,indtime));
            pctvar=squeeze(pctvar_hebd(:,:,indtime));
        end
        
        % corrSMOS0=[corrSMOS0; corrSMOS1];
        % ice0=[ice0; ice];
        pctvar0=[pctvar0; pctvar];
    end
    
    % masque SSS (si la SSS est NaN, on met les autres parametres a NaN
    %  corrSMOS0=corrSMOS0.*maskSSS;
    pctvar0=pctvar0.*maskSSS;
    
    % ecriture des produits
    % corrSMOS1=nan(1,size(lon_fixgrid,1),size(lat_fixgrid,1));
    corrSMOS3=nan(size(lon_fixgrid,1),size(lat_fixgrid,1),1);
    for iti=1:nday;
        nametot=name(iitime(iti)).nametot;
        %  corrSMOS11=corrSMOS0(:,:,iti);
        % corrSMOS1(1,1:size(corrSMOS0,1),:)=corrSMOS11;
        %         corrSMOS2=ice0(:,:,iti);
        %         corrSMOS2=corrSMOS2.*nok0;
        %         ind=find(corrSMOS2>0.01);
        %         corrSMOS2(ind)=1;
        corrSMOS33=pctvar0(:,:,iti);
        corrSMOS3(1:size(pctvar0,1),:,1)=100*corrSMOS33;
        
        %  ncwrite(nametot,'sss_bias_std',single(corrSMOS1));  % suppression year3
        %  ncwrite(nametot,'isc_qc',int8(corrSMOS2));  % suppression year3
        ncwrite(nametot,'pct_var',single(corrSMOS3));
    end
    clear corrSMOS0 ice0 pctvar0
    fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] Product std bias, ice flag, pctvar OK, n= ' num2str(nday)  10]);
end

fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] Ice mask START, n= ' num2str(nday)  10]);

% ajout du masque glace uniquement sur un critere Acard (year3)
SSTseuil=8;  % seuil sur la SST en-dessous duquel on peut lever le flag glace
for itim=1:nday0
    itim
    ttt=tt(indtime0(itim));
    datenom=datestr(ttt,30);
    nameAcard=[rep_Acard filesep 'Acard_' datenom(1:8) '.mat'];
    if exist(nameAcard)>0   % pas de produits si pas de masque Acard
        load(nameAcard);
        % ind_ice=find(Acard_mean<40);
        ind_ice=find((propsup1>0.2 & SST_mean<=SSTseuil) | ndata<5);
        
        mask1=zeros(length(lon_fixgrid),length(lat_fixgrid),1)-1;  % d'abord sur l'ensemble de la carte initialisation du flag ice a 0
        maskSSS0=zeros(length(lon_fixgrid),length(lat_fixgrid),1);
        mask_ice=zeros(size(Acard_mean,1),size(Acard_mean,2));
        mask_ice(ind_ice)=1;
        mask1(:,indlat,1)=mask_ice;
        nametot=name(itim).nametot;
        
        maskSSS0(:,:,1)=maskSSS(:,:,iti);
        indNaN=find(isnan(maskSSS0));
        mask1(indNaN)=-1;  % fill value a -1
        
        ncwrite(nametot,'isc_qc',int8(mask1));  % year 3
        % mask_ice=zeros(size(Acard_mean,1),size(Acard_mean,2))+1;  % suppression year3
        % mask_ice(ind_ice)=NaN;               % suppression year3
        % mask1(:,indlat)=mask_ice;            % suppression year3
        % nametot=name(itim).nametot;          % suppression year3
        % sss0=ncread(nametot,'sss');          % suppression year3
        % sss0=sss0.*mask1;                    % suppression year3
        % sss0=ncread(nametot,'sss');          % suppression year3
        % sss0=sss0.*mask1;                    % suppression year3
        % ncwrite(nametot,'sss',single(sss0)); % suppression year3
        % keyboard
    end
end


fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] Ice mask OK, n= ' num2str(nday)  10]);

t1=cputime-time0;

fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [I] CPU TIME (s)  : ' num2str(t1)  10]);

% fin du logfile
fwrite(ftrace,[datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ' ' nom_proc1 ': [A] [100_END_100]' 10]);
fclose(ftrace);
