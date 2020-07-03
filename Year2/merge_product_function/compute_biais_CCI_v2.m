% SMOS, SMAP and Aquarius merging program
% input     : files provided by lecL2_SMOS, lecL2_SMAP and lecL3_AQUARIUS
% output    : mat files
% date : 06/2019 (CCI+SSS year 1 project)
% author : JLV, ACRI-ST
% date : 02/2020 (CCI+SSS year 2 project)
% new parameter: WSmax, hebdo_factor 
% SMOS filtering (dAcard, WS)
% increase of weekly variability by a factor of hebdo_factor 
% complete computation of the bias from SSS (with or without correction)
% PCTVAR correction
% weekly SSS error correction

clear

zenith=1;   	% ==1 if the program is run on zenith station

isasREF=1;      % ==0 : Aquarius is used for absolute calibration

nday_aqua=3;    % Aquarius time oversampling  t=taqua(1:nday_aqua:end)

alldata=1;      % ==1 all dwells are taken for SSS reference computation

test_mode=0;    % ==1 test mode

time_ok=0;      % ==1 for detail cpu time display

save_prod_int=0;% ==1 for saving intermediate date as input

hebdo_factor=2; % facteur a appliquer sur la variabilité pour le passage mensuel->hebdo ajout year2

WSmax=16;   % ajout year2

err_repr_aqua=1;            % ==1 for applying representativity error on Aquarius
err_repr_hebd=1;            % ==1 for applying representativity error between monthly and weekly SSS fields

rep150km_50km='not used';
if err_repr_aqua==1
    if zenith==0
        rep150km_50km='ERR_REP_150km7d_50km30d_smooth';
        load(['F:\vergely\SMOS\CCI\matlab\representativiteMERCATOR\file_repres_tot_1_12degres\' rep150km_50km]);
        errrepres0=errrepres;
    end
    if zenith==1
        rep150km_50km='ERR_REP_150km7d_50km30d_smooth';
        load(['..' filesep rep150km_50km]);
        errrepres0=errrepres;
    end
end

repweek_month='not used';
if err_repr_hebd==1
    if zenith==0
        repweek_month='ERR_REP_50km1d_50km30d_smooth';
        load(['F:\vergely\SMOS\CCI\matlab\representativiteMERCATOR\file_repres_tot_1_12degres\' repweek_month]);
        errrepres1=hebdo_factor*errrepres;
    end
    if zenith==1
        repweek_month='ERR_REP_50km1d_50km30d_smooth';
        load(['..' filesep repweek_month]);
        errrepres1=hebdo_factor*errrepres;
    end
end

conf.rep150km_50km=rep150km_50km;
conf.rep50km_30km=repweek_month;
conf.hebdo_factor=hebdo_factor;
conf.WSmax=WSmax;


smos_ok=1;          % ==1 if SMOS used
smap_ok=1;          % ==1 if SMAP used
aqua_ok=1;          % ==1 if Aquarius used
readprod=1;         % ==0 for mat product loading, ==1 for mat product generation

rep_res='res';
nameplot=[];
if smos_ok == 1
    rep_res=[rep_res '_smos'];
    nameplot=', smos';
end
if smap_ok == 1
    rep_res=[rep_res '_smap'];
    nameplot=[nameplot ', smap'];
end
if aqua_ok == 1
    rep_res=[rep_res '_aqua'];
    nameplot=[nameplot ', aqua'];
end
rep_res0=rep_res;

if zenith==0
    dirdatasmos='J:\CATDS\RE05\file_mat_full_SST\';
    dirdatasmap='I:\SMAP_data\RSS\L2C_v3\file_mat\';
    dirdataaqua='I:\Aquarius_data\RSS\L3\file_mat\';
else
    dirdatasmos=['..' filesep 'smosfile' filesep 'file_mat_full_corr_SST' filesep'];
    dirdatasmap=['..' filesep 'smapfile' filesep 'file_mat' filesep];
    dirdataaqua=['..' filesep 'aquafile' filesep 'file_mat' filesep];
end

% test ajout year2
if smos_ok==1 & exist(dirdatasmos)==0; disp('SMOS not found'); keyboard; end;
if smap_ok==1 & exist(dirdatasmap)==0; disp('SMAP not found'); keyboard; end;
if aqua_ok==1 & exist(dirdataaqua)==0; disp('AQUA not found'); keyboard; end;

%%%% test
% dirdatasmos='J:/CATDS/RE05/file_mat_full/';
% minmax='G:\dataSMOS\CATDS\repro_2017\correction_biais\ADF\carte_min_max\SM_OPER_AUX_MINMAX_20050909T023037_20500101T000000_624_001_2.nc';
minmax=['..' filesep 'SM_OPER_AUX_MINMAX_20050909T023037_20500101T000000_624_001_2.nc'];
infout=ncinfo(minmax);
stdSSS=ncread(minmax,'stdSSS');

sigvar=1;
gauss=1;
boost_erreur=1;     % ==1 for multiplying the theoretical error by chi (SMOS case).
switch_hebdo=1;     % ==0 no hebdo processing
% correlation parameter
sigbiais2=4;
correlation_time_month=25;          % 30 day smoothing
correlation_time_hebdo=6;           % 7 day smoothing

nsig=3;     % nsigma filtering

sigSSS2=1;
sigSSS2hebd=0.25;

conf.isasREF=isasREF;
conf.smos_ok=smos_ok;
conf.smap_ok=smap_ok;
conf.aqua_ok=aqua_ok;
conf.dirdatasmos=dirdatasmos;
conf.dirdatasmap=dirdatasmap;
conf.dirdataaqua=dirdataaqua;
conf.boost_erreur=boost_erreur;
conf.sigbiais2=sigbiais2;
conf.sigSSS2=sigSSS2;
conf.sigSSS2hebd=sigSSS2hebd;
conf.correlation_time_month=correlation_time_month;
conf.correlation_time_hebdo=correlation_time_hebdo;
conf.nsig=nsig;
conf.sigvar=sigvar;
conf.err_repr_aqua=err_repr_aqua;
conf.err_repr_hebd=err_repr_hebd;


load coast
lonc=long;
latc=lat;

% dwell selection (SMOS data)
xswathlim=415;

% definition des zones (on ne peut pas tout traiter d'un coup a cause de la place
% memoire). Attention, il faut travailler avec des bandes de latitudes identiques
minlontab=[-181  -165  -150  -135  -120  -105   -90   -75   -60   -45   -30   -15    0    15    30    45    60    75    90   105   120   135   150   165];
maxlontab=[-165  -150  -135  -120  -105   -90   -75   -60   -45   -30   -15     0   15    30    45    60    75    90   105   120   135   150   165   181];
minlattab=[-90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90  -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90];
maxlattab=[ 90    90    90    90    90    90    90    90    90    90    90    90   90    90    90    90    90    90    90    90    90    90    90    90];

if test_mode==1;
    minlattab=[10];
    maxlattab=[11];
    minlontab=[-30];
    maxlontab=[-29];
end

nzone=length(minlontab);

load([dirdatasmos 'smosA_20140101.mat'])

load(['..' filesep 'latlon_ease.mat'])

lat=lat_ease;     % nouvelle grille ease2
lon=lon_ease;

indxswath=find(abs(xswath)<xswathlim);
ndwellsmos=length(indxswath);
xswathsel=xswath(indxswath);
idwref=floor(length(indxswath)/2)+1;
maxidw=max(indxswath);
minidw=min(indxswath);

itestorb=3;       % 1 pour asc seul; 2 pour desc seul; 3 pour asc et desc
ndwell=2*ndwellsmos+4+1;    % on ajoute 4 pour SMAP : asc + desc, afte + fore ET 1 pour Aquarius : L3 (pas de distinction asc + desc, beam1 + beam2 + beam3)
% les donnees selon idwell sont organisées de la façon suivante:
% donnees ascendantes SMOS + donnees ascendantes SMAP + donnees ascendantes Aqua + donnees descendantes SMOS + donnees descendantes SMAP + donnees descendantes Aqua
%     idw_smos_A=[1:ndwellsmos];                      % ndwellsmos pour smos asc
%     idw_smap_A=[ndwellsmos+1:ndwellsmos+2];         % aft et fore pour smap asc
%     idw_aqua_A=[ndwellsmos+3:ndwellsmos+5];         % beam1, 2 et 3 pour Aqua asc
%     idw_smos_D=[ndwellsmos+5+1:2*ndwellsmos+5];     % ndwellsmos pour smos desc
%     idw_smap_D=[2*ndwellsmos+6:2*ndwellsmos+7];     % aft et fore pour smap desc
%     idw_aqua_D=[2*ndwellsmos+8:2*ndwellsmos+10];    % ndwellsmos pour smos desc

% pour aquarius niveau 3 : pas de distinction asc-desc et beam1-2-3
% allocation des numéros de "dwell" (equivalence SMAP-Aquarius)
idw_smos_A=[1:ndwellsmos];                      % ndwellsmos pour smos asc
idw_smap_A=[ndwellsmos+1:ndwellsmos+2];         % aft et fore pour smap asc
idw_aqua=[ndwellsmos+3:ndwellsmos+3];           % Aqua
idw_smos_D=[ndwellsmos+3+1:2*ndwellsmos+3];     % ndwellsmos pour smos desc
idw_smap_D=[2*ndwellsmos+4:2*ndwellsmos+5];     % aft et fore pour smap desc

conf.ndwell=ndwell;
conf.minlattab=minlattab;
conf.maxlattab=maxlattab;
conf.minlontab=minlontab;
conf.maxlontab=maxlontab;

% selection (non appliquée pour la lecture des produits mais après coup)
idsel=[];
if itestorb==1                      % asc
    if smos_ok==1
        idsel=[idsel,idw_smos_A];
    end
    if smap_ok==1
        idsel=[idsel,idw_smap_A];
    end
elseif itestorb==2                  % desc
    if smos_ok==1
        idsel=[idsel,idw_smos_D];
    end
    if smap_ok==1
        idsel=[idsel,idw_smap_D];
    end
elseif itestorb==3                  % asc + desc
    if smos_ok==1
        idsel=[idsel,idw_smos_A,idw_smos_D];
    end
    if smap_ok==1
        idsel=[idsel,idw_smap_A,idw_smap_D];
    end
end

% Aquarius niveau 3 : pas de distinction asc-desc
if aqua_ok==1
    idsel=[idsel,idw_aqua];
end

conf.idsel=idsel;
conf.itestorb=itestorb;

% on traite les zones l'une apres l'autre
% ATTENTION : on lit TOUS les produits (asc,desc,smos,aqua,smap) et on fait
% un tri APRES avec idsel.
for izone=1:nzone
    itestorb
    izone
    
    rep_res=[rep_res0    '_zone' num2str(izone)];
    nameplot=[nameplot  '_zone' num2str(izone)];
    
    if exist(rep_res)==0; mkdir(rep_res); end;
    
    % caracterisation de la zone
    minlon=minlontab(izone);
    maxlon=maxlontab(izone);
    minlat=minlattab(izone);
    maxlat= maxlattab(izone);
    
    conf.latmin=minlat;
    conf.latmax=maxlat;
    conf.lonmin=minlon;
    conf.lonmax=maxlon;
    
    % configuration
    orbsel=itestorb;       % 1 pour asc; 2 pour desc; 3 pour asc+desc
    %  nameprod=['prod2_Lm_' num2str(abs(minlon)) '_LM_'  num2str(abs(maxlon)) '_lm_' num2str(abs(minlat)) '_lM_'  num2str(abs(maxlat)) '_xs_' num2str(xswathlim)];
    nameprod=['prod2_Lm_' num2str(abs(minlon)) '_LM_'  num2str(abs(maxlon)) '_lm_' num2str(abs(minlat)) '_lM_'  num2str(abs(maxlat)) '_xs_' num2str(xswathlim)  ];
    namesave=[rep_res filesep 'dwell_centrale'];
    
    indlonsel=find(lon<=maxlon & lon>minlon);
    indlatsel=find(lat<=maxlat & lat>=minlat);
    
    lonregion=lon(indlonsel);
    latregion=lat(indlatsel);
    nlonregion=length(lonregion);
    nlatregion=length(latregion);
    
    [lat0 lon0]=meshgrid(latregion, lonregion);
    
    stdSSSregion=max(0.3,stdSSS(indlonsel,indlatsel));
    
    
    if test_mode==1;
        
        year=['12';'13';'14';'15';'16';'17';'18']   % annees
        nyear=7;
        for iye=1:8
            yearstruct(iye).monthnumber=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        end
    else
        year=['10';'11';'12';'13';'14';'15';'16';'17';'18';'19']   % annees
        nyear=10;
        for iye=1:10
            yearstruct(iye).monthnumber=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        end
        % year=['12']
        % nyear=1;
        % yearstruct(1).monthnumber=[1, 2];
    end
    
    if readprod==1
        % lecture des produits .nc ou chargement des produits .mat
        SSSsel=[];
        SSTsel=[];
        eSSSsel=[];
        chisel=[];
        tSSSsel=[];
        nSsel=[];
        datesel=[];
        tabNaNind=[];
        data=[];
        
        name='smosA_20100701.nc';
        namesmap='smapA_20100701.nc';
        nameaqua='aquaA_20100701.nc'
        nS=zeros(ndwell,nlonregion*nlatregion);
        datemois=[];
        datemois_isas=[];
        nday=0;
        idwellaqua=[];
        for iorb=1:2  % boucle asc-desc
            if iorb==1
                orb='A';
                idwellsmos=idw_smos_A;
                idwellsmap=idw_smap_A;
                idwellaqua=idw_aqua;
            else
                orb='D';
                idwellsmos=idw_smos_D;
                idwellsmap=idw_smap_D;
                if length(idwellaqua)==0; idwellaqua=idw_aqua; else; idwellaqua=[]; end;   % si on a sélectionné que les descendants, on lit aquarius L3 qui est donné en asc+desc. Sinon on ne le lit qu'en ascendant
            end
            % boucle ascendant-descendant : les fichiers asc-desc sont sauvegardes
            % separement
            % on attend environ deux salinites par mois
            for ia=1:nyear  % boucle sur les annees
                ia
                ia1=ia;
                ia2=ia;
                % nmonth=nmonthyear(ia);
                monthnumber=yearstruct(ia).monthnumber;
                nmonth=length(monthnumber);
                yeartot=['20' year(ia,:)];
                datesmapinit=datenum(2015,01,01,0,0,0);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % lecture des fichiers SMAP    %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if smap_ok==1;
                    
                    disp('SMAP')
                    for imonth0=1:nmonth
                        imonth=monthnumber(imonth0)
                        if imonth < 10; imonc=['0' num2str(imonth)]; else imonc=num2str(imonth); end;
                        
                        for iday=1:31
                            if iday < 10; idayc=['0' num2str(iday)]; else; idayc=num2str(iday); end;
                            
                            name_ok=namesmap;
                            name_ok(5)=orb;
                            name_ok(9:10)=year(ia1,:);
                            name_ok(11:12)=imonc;
                            name_ok(13:14)=idayc;
                            namemat=name_ok(1:14);
                            if exist([dirdatasmap namemat '.mat'])~=0
                                
                                nday=nday+1;
                                datemois(nday,1)=str2num(imonc);
                                datemois(nday,2)=str2num(year(ia1,:));
                                datemois(nday,3)=iday;
                                dateJD=datenum([datemois(nday,2)+2000,datemois(nday,1), datemois(nday,3)]);
                                
                                load([dirdatasmap namemat])   % 'SSS1','SSS2','tSSS1','tSSS2','WS1','WS2','rain1','rain2','SST1','SST2','tb_consistency1','tb_consistency2'  1:fore; 2:afte
                                
                                % fore
                                SSSsel1=SSS1(indlonsel,indlatsel);
                                tSSSsel1=tSSS1(indlonsel,indlatsel);
                                SSTsel1=SST1(indlonsel,indlatsel);
                                eSSSsel1=0.45./(0.015.*SSTsel1+0.25);      % pas d'erreur dans SMAP RSS. Bruit correspondant à une erreur de 0.45K
                                % afte
                                SSSsel2=SSS2(indlonsel,indlatsel);
                                tSSSsel2=tSSS2(indlonsel,indlatsel);
                                SSTsel2=SST2(indlonsel,indlatsel);
                                eSSSsel2=0.45./(0.015.*SSTsel2+0.25);
                                
                                for igp=1:(nlonregion*nlatregion)
                                    SSS1=SSSsel1(igp);
                                    tSSS1=tSSSsel1(igp);
                                    SST1=SSTsel1(igp);
                                    chi1=1;
                                    eSSS1=eSSSsel1(igp);
                                    SSS2=SSSsel2(igp);
                                    tSSS2=tSSSsel2(igp);
                                    SST2=SSTsel2(igp);
                                    chi2=1;
                                    eSSS2=eSSSsel2(igp);
                                    
                                    if isnan(SSS1)==0;
                                        idw=idwellsmap(1);   % fore SMAP
                                        nSn=nS(idw,igp)+1;
                                        nS(idw,igp)=nSn;
                                        data(igp,idw).SSS(nSn)=SSS1;
                                        data(igp,idw).eSSS(nSn)=eSSS1;
                                        data(igp,idw).chi(nSn)=chi1;
                                        data(igp,idw).tSSS(nSn)=tSSS1;
                                        data(igp,idw).SST(nSn)=SST1;
                                        data(igp,idw).Dg_ice1(nSn)=0;  % ajout year2
                                    end
                                    
                                    if isnan(SSS2)==0;
                                        idw=idwellsmap(2);   % afte SMAP
                                        nSn=nS(idw,igp)+1;
                                        nS(idw,igp)=nSn;
                                        data(igp,idw).SSS(nSn)=SSS2;
                                        data(igp,idw).eSSS(nSn)=eSSS2;
                                        data(igp,idw).chi(nSn)=chi2;
                                        data(igp,idw).tSSS(nSn)=tSSS2;
                                        data(igp,idw).SST(nSn)=SST2;
                                        data(igp,idw).Dg_ice1(nSn)=0;  % ajout year2
                                    end
                                end
                            end
                        end
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % lecture des fichiers Aquarius    %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if aqua_ok==1 & length(idwellaqua) ~= 0;
                    disp('Aquarius')
                    for imonth0=1:nmonth
                        imonth=monthnumber(imonth0)
                        if imonth < 10; imonc=['0' num2str(imonth)]; else imonc=num2str(imonth); end;
                        
                        for iday=1:31
                            if iday < 10; idayc=['0' num2str(iday)]; else; idayc=num2str(iday); end;
                            name_ok=nameaqua;
                            name_ok(5)=orb;   % on ne lit aquarius qu'en orb=A
                            name_ok(9:10)=year(ia1,:);
                            name_ok(11:12)=imonc;
                            name_ok(13:14)=idayc;
                            namemat=name_ok(1:14);
                            
                            if exist([dirdataaqua namemat '.mat'])~=0
                                nday=nday+1;
                                datemois(nday,1)=str2num(imonc);
                                datemois(nday,2)=str2num(year(ia1,:));
                                datemois(nday,3)=iday;
                                dateJD=datenum([datemois(nday,2)+2000,datemois(nday,1), datemois(nday,3)]);
                                
                                load([dirdataaqua namemat])   % 'SSS1','SSS2','tSSS1','tSSS2','WS1','WS2','rain1','rain2','SST1','SST2','tb_consistency1','tb_consistency2'  1:fore; 2:afte
                                %                                     SSSsel1=mattot(indlonsel,indlatsel,2);
                                %                                     tSSSsel1=mattot(indlonsel,indlatsel,1);
                                %                                     SSTsel1=mattot(indlonsel,indlatsel,3);
                                %                                     eSSSsel1=mattot(indlonsel,indlatsel,5);
                                %beamsel1=mattot(indlonsel,indlatsel,7);
                                SSSsel1=SSS1(indlonsel,indlatsel);
                                tSSSsel1=tSSS1(indlonsel,indlatsel);
                                SSTsel1=SST1(indlonsel,indlatsel);
                                eSSSsel1=eSSS1(indlonsel,indlatsel);
                                
                                for igp=1:(nlonregion*nlatregion)
                                    SSS1=SSSsel1(igp);
                                    tSSS1=tSSSsel1(igp);
                                    SST1=SSTsel1(igp);
                                    chi1=1;
                                    eSSS1=eSSSsel1(igp);
                                    % ibeam=beamsel1(igp);
                                    if isnan(SSS1)==0;
                                        idw=idwellaqua;   % beam  % un seul beam bidon pour les niveau 3
                                        nSn=nS(idw,igp)+1;
                                        nS(idw,igp)=nSn;
                                        data(igp,idw).SSS(nSn)=SSS1;
                                        data(igp,idw).eSSS(nSn)=eSSS1;
                                        data(igp,idw).chi(nSn)=chi1;
                                        data(igp,idw).tSSS(nSn)=tSSS1;
                                        data(igp,idw).SST(nSn)=SST1;
                                        data(igp,idw).Dg_ice1(nSn)=0;  % ajout year2
                                    end
                                end
                            end
                        end
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % lecture des fichiers SMOS    %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if smos_ok==1
                    disp('SMOS')
                    for imonth0=1:nmonth
                        imonth=monthnumber(imonth0)
                        if imonth < 10; imonc=['0' num2str(imonth)]; else imonc=num2str(imonth); end;
                        
                        for iday=1:31
                            if iday < 10; idayc=['0' num2str(iday)]; else; idayc=num2str(iday); end;
                            
                            name_ok=name;
                            name_ok(5)=orb;
                            name_ok(9:10)=year(ia1,:);
                            name_ok(11:12)=imonc;
                            name_ok(13:14)=idayc;
                            namemat=name_ok(1:14);
                            
                            if exist([dirdatasmos namemat '.mat'])~=0
                                
                                nday=nday+1;
                                datemois(nday,1)=str2num(imonc);
                                datemois(nday,2)=str2num(year(ia1,:));
                                datemois(nday,3)=iday;
                                dateJD=datenum([datemois(nday,2)+2000,datemois(nday,1), datemois(nday,3)]);
                                
                                load([dirdatasmos namemat])   % 'SSS0','eSSS0','tSSS0','chiSSS0','idwSSS0','SST0', 'Acard'
                                
                                SSSsel1=SSS0(indlonsel,indlatsel);
                                tSSSsel1=tSSS0(indlonsel,indlatsel);
                                eSSSsel1=eSSS0(indlonsel,indlatsel);
                                idwSSSsel1=idwSSS0(indlonsel,indlatsel);
                                WSsel1=WS0(indlonsel,indlatsel);               % ajout year2
                                chi2Psel1=chiSSS0(indlonsel,indlatsel);
                                SSTsel1=SST0(indlonsel,indlatsel);
                                Acardsel1=Acard(indlonsel,indlatsel);
                                Acard_modsel1=Acard_mod(indlonsel,indlatsel);  % ajout year2
                                Dg_icesel1=Dg_Suspect_ice0(indlonsel,indlatsel); % ajout year2
                                
                                ind0=find(isnan(Acardsel1));   % ajout year2
                                Acardsel1(ind0)=Acard_modsel1(ind0);  % si Acard n'est pas calcule, on le force a Acard_mod % ajout year2
                                dAcardsel1=abs(Acardsel1-Acard_modsel1); % ajout year2
                                
                                for igp=1:(nlonregion*nlatregion)
                                    SSS1=SSSsel1(igp);
                                    tSSS1=tSSSsel1(igp);
                                    SST1=SSTsel1(igp);
                                    WS1=WSsel1(igp);  % ajout year2
                                    idw=idwSSSsel1(igp);
                                    chi=chi2Psel1(igp);
                                    eSSS1=eSSSsel1(igp);
                                    Acard1=Acardsel1(igp);
                                    dAcard1=dAcardsel1(igp);  % ajout year2
                                    Dg_ice1=Dg_icesel1(igp);  % ajout year2
                                    
                                    %                                     if isnan(Acard1)==1
                                    %                                         Acard1=100;
                                    %                                     end
                                    
                                    % if isnan(SSS1)==0 & idw <= maxidw &
                                    % idw >= minidw & chi<3. & eSSS1<3. &
                                    % Acard1>42. & SSS1>4. & SSS1<50.; year1
                                    if isnan(SSS1)==0 & idw <= maxidw & idw >= minidw & chi<3. & eSSS1<3. & Acard1>42. & SSS1>2. & SSS1<45. & WS1<WSmax & dAcard1<2;  % year2
                                        idw=idw-minidw+1;
                                        idw=idwellsmos(idw);
                                        nSn=nS(idw,igp)+1;
                                        nS(idw,igp)=nSn;
                                        data(igp,idw).SSS(nSn)=SSS1;
                                        data(igp,idw).eSSS(nSn)=eSSS1;
                                        data(igp,idw).chi(nSn)=chi;
                                        data(igp,idw).tSSS(nSn)=tSSS1;
                                        data(igp,idw).SST(nSn)=SST1;
                                        data(igp,idw).Dg_ice1(nSn)=Dg_ice1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            clear SSS eSSS
            % if iad==1  % on ne charge isas qu'a la premiï¿½re boucle
            %     load('isas');
            % end
        end
        
        if save_prod_int==1
            save([nameprod '.mat' ],'data','nS','datemois','xswathsel','-v7.3')
        end
    else
        % disp(['load data matfile orb ' orb ])
        disp(['load data matfile'])
        %load([nameprod '_' orb '.mat']);
        load([nameprod '.mat']);
    end
    
    % selection des donnees
    data=data(:,idsel);
    nS=nS(idsel,:);
    
    % sous-echantillonnage des donnees 7days running L3 Aquarius.
    if aqua_ok==1 & length(idw_aqua)==1  % on enleve des donnees aqua seulement si L3 (pas de "dwells" aqua)
        indaq=find(idsel==idw_aqua);
        ngp=size(data,1);
        for ii=1:ngp
            if length(data(ii,indaq).SSS)>0
                data(ii,indaq).SSS=data(ii,indaq).SSS(1:nday_aqua:end);
                data(ii,indaq).eSSS=data(ii,indaq).eSSS(1:nday_aqua:end);
                data(ii,indaq).chi=data(ii,indaq).chi(1:nday_aqua:end);
                data(ii,indaq).tSSS=data(ii,indaq).tSSS(1:nday_aqua:end);
                data(ii,indaq).SST=data(ii,indaq).SST(1:nday_aqua:end);
                nS(indaq,ii)=length(data(ii,indaq).SSS);
            end
        end
    end
    
    % on applique les erreurs de représentativité sur Aquarius
    % ne fonctionne que pour les L3 Aquarius (Aquarius est considéré
    % comme une "mono" dwell).
    if err_repr_aqua==1 & aqua_ok==1
        indaq=find(idsel==idw_aqua);
        errrepr=errrepres0(indlonsel,indlatsel,:);
        errrepr=reshape(errrepr,nlonregion*nlatregion,12);
        ngp=size(data,1);
        for ii=1:ngp
            if length(data(ii,indaq).SSS)>0
                errrepr2=squeeze(errrepr(ii,:));
                tSSS=data(ii,indaq).tSSS;
                dvec=datevec(tSSS);
                monthaqua=dvec(:,2);
                edatarep=errrepr2(monthaqua);
                eSSS=data(ii,indaq).eSSS;
                data(ii,indaq).eSSS=sqrt(eSSS.*eSSS+edatarep.*edatarep);
            end
        end
    end
    
    if err_repr_hebd==1
        stdhebd=errrepres1(indlonsel,indlatsel,:);
        stdhebd=reshape(stdhebd,nlonregion*nlatregion,12);
    else
        stdhebd=sqrt(sigSSS2hebd)*ones(nlonregion*nlatregion,12);
    end
    
    ndwell=length(idsel);
    
    % boost erreur
    if boost_erreur==1;
        for i1=1:size(data,1)
            for i2=1:size(data,2)
                eSSS=data(i1,i2).eSSS;
                chi=data(i1,i2).chi;
                data(i1,i2).eSSS=eSSS.*chi;
            end
        end
    end
    
    %%%%%%%%%%% chargement ISAS
    if isasREF==1
        load(['..' filesep 'isas_CATDS'])
    else
        load(['..' filesep 'aqua_month'])
        % on alloue les champs ISAS avec Aquarius pour simplifier la
        % programmation
        isasSSS=aquaSSS;
        datemois_isas=datemois_aqua;
    end
    
    sigpri=4;
    
    load(['..' filesep 'smos_isas_rmsd_ease_smooth'])    %'rmsdmerge' en plus
    
    tt0=tt(1:12)+0.5;
    % figure; hold on; imagesc(squeeze(stdsel(:,:,2))'); axis xy; colorbar; hold off
    
    %%%%%%%%%%%%%test
    %ilo0=1005
    %ila0=350
    %stdsel=squeeze(rmsdSSSmens(ilo0,ila0,:));
    
    % stdsel=rmsdSSSmens(indlonsel,indlatsel,:);
    stdsel0=rmsdmerge(indlonsel,indlatsel,:);
    
    % on complète les plus proches voisins
    % pour la variabilite mensuelle a partir de la variabilite SMOS
    stdsel=squeeze(reshape(stdsel0,length(indlonsel)*length(indlatsel),12,1));
    
    % 12 mois de l'annee
    tx1=cos(2*pi*tt0/12);
    ty1=sin(2*pi*tt0/12);
    
    [txx1 txx2]=meshgrid(tx1,tx1);
    [tyy1 tyy2]=meshgrid(ty1,ty1);
    xi_cov=.5;
    Cm0=sigpri*exp(-(txx1-txx2).*(txx1-txx2)/xi_cov/xi_cov-(tyy1-tyy2).*(tyy1-tyy2)/xi_cov/xi_cov);
    invH=inv(Cm0+eye(12,12)*0.1);
    vec2std=invH*stdsel';
    stdest=Cm0*vec2std;
    
    % pour la variabilite hebdomadaire a partir de la variabilite
    % MERCATOR 7 jours <-> 30 jours
    vec3std=invH*stdhebd';
    
    m1=yearstruct(1).monthnumber(1);
    m2=yearstruct(end).monthnumber(end);
    y1=str2num(year(1,:));
    y2=str2num(year(end,:));
    
    indtisas1=find(datemois_isas(:,1)==m1 & datemois_isas(:,2)==y1);
    indtisas2=find(datemois_isas(:,1)==m2 & datemois_isas(:,2)==y2);
    
    if length(indtisas1)==0 | length(indtisas2)==0 ;
        disp('REF non disponible sur toute la periode')
    end
    
    if length(indtisas1)==0; indtisas1=1; end;
    if length(indtisas2)==0; indtisas2=length(datemois_isas); end;
    
    datemois_isas=datemois_isas(indtisas1:indtisas2,:);
    
    % keyboard
    isasSSSsel=isasSSS(indtisas1:indtisas2,indlonsel,indlatsel);
    clear isasSSS
    
    t=cputime;
    
    % on regarde les GP en fonction du temps
    ilomin=indlonsel(1);
    ilamin=indlatsel(1);
    nilo=length(indlonsel);
    nila=length(indlatsel);
    % nilo=1;
    % nila=1;
    nok=zeros(nilo,nila,1);
    chi2_mens=zeros(nilo,nila,1);
    chi2_3sigma_mens=zeros(nilo,nila,1);
    SSSoutlier_mens=zeros(nilo,nila,1);
    biais_est_mens=zeros(nilo,nila,ndwell);
    SSTmoy=zeros(nilo,nila,1);
    err_biais_est_mens=zeros(nilo,nila,ndwell);
    
    chi2_hebd=zeros(nilo,nila,1);
    chi2_3sigma_hebd=zeros(nilo,nila,1);
    SSSoutlier_hebd=zeros(nilo,nila,1);
    biais_est_hebd=zeros(nilo,nila,ndwell);
    err_biais_est_hebd=zeros(nilo,nila,ndwell);
    
    % base temporelle sur laquelle on donne la salinite estimee non
    % biaisee
    % unite mensuelle
    % si hebdomadaire
    dyear1=str2num(year(1,:))+2000;
    dyear2=str2num(year(nyear,:))+2000;
    mmon1=yearstruct(1).monthnumber(1);
    mmon2=yearstruct(end).monthnumber(end);
    dday1=0;
    dday2=31;
    pasday=1;
    tinit=datenum(dyear1,mmon1,dday1);
    tmax=datenum(dyear2,mmon2,dday2)+1;
    tt=tinit:pasday:tmax;
    
    ttmonth=datevec(tt);
    ttmonth=ttmonth(:,2)+ttmonth(:,3)/31;  % on peut dépasser 12 car ensuite on circularise le probleme
    
    tx2=cos(2*pi*ttmonth/12);
    ty2=sin(2*pi*ttmonth/12);
    
    [txx1 txx2]=meshgrid(tx1,tx2);
    [tyy1 tyy2]=meshgrid(ty1,ty2);
    Cm1=sigpri*exp(-(txx1-txx2).*(txx1-txx2)/xi_cov/xi_cov-(tyy1-tyy2).*(tyy1-tyy2)/xi_cov/xi_cov);
    
    ntime=length(tt);
    [t1 t2]=meshgrid(tt,tt);
    
    % SSSest_mens=zeros(nilo,nila,ntime);
    SSSest_3sigma_mens=zeros(nilo,nila,ntime);
    SSSest_nocorr_mens=zeros(nilo,nila,ntime);  % ajout year2
    errSSSest_mens=zeros(nilo,nila,ntime);
    outlier_mens=zeros(nilo,nila,ntime);
    ice_mens=zeros(nilo,nila,ntime);   % ajout year2
    stb_bias_mens=zeros(nilo,nila,ntime);
    mean_bias_mens=zeros(nilo,nila,ntime);
    ndata_mens=zeros(nilo,nila,ntime);
    pctvar_mens=zeros(nilo,nila,ntime);
    
    SSSest_hebd=zeros(nilo,nila,ntime);
    SSSest_nocorr_mens=zeros(nilo,nila,ntime);   % ajout year2
    SSSest_3sigma_hebd=zeros(nilo,nila,ntime);
    errSSSest_hebd=zeros(nilo,nila,ntime);
    outlier_hebd=zeros(nilo,nila,ntime);
    ice_hebd=zeros(nilo,nila,ntime);   % ajout year2
    stb_bias_hebd=zeros(nilo,nila,ntime);
    mean_bias_hebd=zeros(nilo,nila,ntime);
    ndata_hebd=zeros(nilo,nila,ntime);
    pctvar_hebd=zeros(nilo,nila,ntime);
    
    % resolution du systeme : SSSsmos(dwell,time) = SSSmoy(time) - alpha(SST). DeltaB(dwell)
    % igp0=0;
    Cpb=eye(ndwell,ndwell)*sigbiais2;
    bprior=zeros(ndwell,1);
    
    NSSS=sum(nS,1);
    % covariance hebdo et mensuelle dans l'espace des paramètres
    % (echantillonnage 1 jour)
    matvarth=exp(-(t1-t2).*(t1-t2)./(correlation_time_hebdo*correlation_time_hebdo));
    matvartm=exp(-(t1-t2).*(t1-t2)./(correlation_time_month*correlation_time_month));
    
    
    %   keyboard
    for ila0=1:nila
        %for ila0=325:325
        % for ila0=1:10
        fprintf('%d,%d sur %d\n',izone,ila0,nila)
        
        for ilo0=1:nilo
            %for ilo0=48:48
            
            tim0=cputime;
            
            % igp0=igp0+1;
            igp=(ila0-1)*nilo+ilo0;
            
            % sprintf('%d %d %d, %d \n',ila0, ilo0, igp0, igp)
            %%%% test
            % sprintf('ilat=%d, ilo=%d, igp=%d', ila0, ilo0, igp)
            if NSSS(igp) > 300
                %              nSt=sum(nSsel(:,igp));
                SSSGP=[];
                SSTGP=[];
                eSSSGP=[];
                tSSSGP=[];
                idwell=[];
                DgIceGP=[];  % ajout year2
                
                % organisation des donnees en vecteur
                for idw=1:ndwell
                    SSS0=data(igp,idw).SSS;
                    if length(SSS0) > 0
                        SSSGP=[SSSGP data(igp,idw).SSS];
                        SSTGP=[SSTGP data(igp,idw).SST];
                        eSSSGP=[eSSSGP data(igp,idw).eSSS];
                        tSSSGP=[tSSSGP data(igp,idw).tSSS];
                        DgIceGP=[DgIceGP data(igp,idw).Dg_ice1];  % ajout year2
                        idwell=[idwell idw+0*(1:nS(idw,igp))];   % idwell ne contient PAS le numéro de dwell absolu.
                    end
                end
                
                ndata=length(SSSGP);
                npar=ndata+ndwell;
                bprior=zeros(ndwell,1);
                
                nok(ilo0,ila0)=ndata;
                
                if time_ok==1
                    tim00=cputime;
                    disp('organisation des donnees')
                    tim=tim00-tim0
                end
                
                sigp2=stdSSSregion(ilo0,ila0).*stdSSSregion(ilo0,ila0);
                if sigvar==1
                    % preparation de la covariance a priori
                    ttdata=datevec(tSSSGP);
                    ttdata=ttdata(:,2)+ttdata(:,3)/31;  % on peut dépasser 12 car ensuite on circularise le probleme
                    tx2=cos(2*pi*ttdata/12);
                    ty2=sin(2*pi*ttdata/12);
                    
                    [txx1 txx2]=meshgrid(tx1,tx2);
                    [tyy1 tyy2]=meshgrid(ty1,ty2);
                    Cm_data=sigpri*exp(-(txx1-txx2).*(txx1-txx2)/xi_cov/xi_cov-(tyy1-tyy2).*(tyy1-tyy2)/xi_cov/xi_cov);
                    vec3=vec2std(:,igp);
                    stdtt_data=Cm_data*vec3;
                    
                    % pour la SSS hebdo
                    vec4=vec3std(:,igp);
                    stdtt_datah=Cm_data*vec4;
                    
                    %stdtt_data2=stdtt_data.*stdtt_data;
                    if isnan(stdtt_data(1))
                        stdtt_data=ones(length(stdtt_data),1);
                    end
                    if isnan(stdtt_datah(1))
                        stdtt_datah=sqrt(sigSSS2hebd)*ones(length(stdtt_datah),1);
                    end
                end
                
                if time_ok==1
                    tim01=cputime;
                    disp('preparation cov')
                    tim=tim01-tim00
                end
                
                eSSSGP2=eSSSGP.*eSSSGP;
                meanSST=median(SSTGP);
                deltaSST=SSTGP-meanSST;
                GG2=[];
                for idw=1:ndwell
                    SST=data(igp,idw).SST';
                    dSST0=SST-meanSST;
                    nsssd=length(dSST0);
                    matdw=zeros(nsssd,ndwell);
                    % matdw(:,idw)=-1;  sans la prise en compte de la
                    if length(SST)>0
                        matdw(:,idw)=-1.0-0.015*dSST0./(-0.015.*SST-0.25);
                        GG2=[GG2; matdw];  % derivee du biais avec dependance SST
                    end
                end
                
                if time_ok==1
                    tim02=cputime;
                    disp('matrice des derivees')
                    tim=tim02-tim01
                end
                
                % coefSST=1+0*deltaSST;    sans la prise en compte de la SST
                coefSST=1+0.015*deltaSST./(-0.015.*SSTGP-0.25);
                
                GG1=eye(ndata,ndata);
                % pour le calcul du prior, on prend la dwell centrale
                SSSref=[];
                if smos_ok==1
                    if alldata==0
                        SSSref=data(igp,idwref).SSS;
                    else
                        SSSref=SSSGP;
                    end
                    
                end
                
                % si pas de dwells de ref presente dans les donnees, on
                % ne jette pas
                if length(SSSref)==0
                    ind=find(SSSGP~=0);
                    SSSref=median(SSSGP(ind));
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % estimation mensuelle de la salinite %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % on prend la valeur mediane de la dwell centrale pour caler le
                % biais relatif
                if length(SSSref) > 1
                    SSSmed=median(SSSref);
                else
                    SSSmed=SSSref;
                end
                SSSprior = tSSSGP.*0+SSSmed;
                
                % prior sur la base temporelle reguliere tt
                % commun avec ou sans SST
                % data X (grille t reguliere)
                SSSp = tt.*0+SSSmed;
                err_post = tt.*0;
                
                % on multiplie Cm par sa std2
                stdtt_day=Cm1*vec3;
                [st1 st2]=meshgrid(stdtt_day,stdtt_day);
                st0c=(st1.*st2);
                matvartm1=matvartm.*st0c;
                
                indtime=round(tSSSGP)-min(tt)+1;
                
                matvart=matvartm1(indtime,:);       % data X model (sans le biais)
                matvart2=matvart;                   % on stoke l'info pour le calcul de l'erreur hebdo  ajout year2
                Cp1=matvartm1(indtime,indtime);     % data X data
                
                if time_ok==1
                    tim03=cputime;
                    disp('matrice de correlation temporelle')
                    tim=tim03-tim02
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % chi2 d'ajustement avec SST %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % avec dependance SST
                % on separe en 2 : la partie SSS et la partie biais;
                
                % Cp1GG1=Cp1*GG1';          % GG1 est la matrice identite
                Cp2GG2=Cpb*GG2';
                
                % GG1Cp1GG1=GG1*Cp1GG1;         % data X data; GG1 est la matrice identite
                GG2Cp2GG2=GG2*Cp2GG2;           % biais X biais
                GCmGCd0=Cp1+GG2Cp2GG2;          % data X data  ajout year2
                GCmGCd=GCmGCd0+diag(eSSSGP2);   % data X data
                
                % CpGG=matvart'*GG1;            % GG1 est la matrice identite
                CpGG=matvart';                  % data X model (sans le biais)
                vec=SSSGP-SSSprior;
                vec2=GCmGCd\vec';
                
                SSSsol=SSSp'+CpGG*vec2;         % solution sur la grille reguliere temporelle SSSref
                xprior=[SSSprior'; bprior];
                SSSmod=SSSprior'+Cp1*vec2;      % dans l'espace des donnees
                biais=Cp2GG2*vec2;
                
                SSScorr=SSSmod-biais(idwell).*coefSST';
                
                chi2=sqrt((((SSScorr-SSSGP')./eSSSGP2')'*(SSScorr-SSSGP'))/(ndata));
                chitab=sqrt(((SSScorr-SSSGP')./eSSSGP2').*(SSScorr-SSSGP'));
                ind=find(chitab>nsig);
                noutlier=length(ind);
                
                if time_ok==1
                    tim04=cputime;
                    disp('solution 1')
                    tim=tim04-tim03
                end
                
                % initialisation
                chi2_3sigma=0;
                SSSsol_3sigma=SSSsol;
                if noutlier > 0
                    % eSSSGP2(ind)=((SSScorr(ind)-SSSGP(ind)')./eSSSGP2(ind)').*(SSScorr(ind)-SSSGP(ind)');   % old
                    % eSSSGP2(ind)=(SSScorr(ind)-SSSGP(ind)').*(SSScorr(ind)-SSSGP(ind)');   % changement aout 2015
                    eSSSGP2(ind)=1000;
                    % GCmGCd=GCmGCd+diag(eSSSGP2);  year1 : eSSSGP2 faux
                    GCmGCd=GCmGCd0+diag(eSSSGP2);   % correction/ajout year2
                    vec2=GCmGCd\vec';
                    SSSmod=SSSprior'+Cp1*vec2;    % SSS sur les data
                    biais=Cp2GG2*vec2;
                    SSScorr=SSSmod-biais(idwell).*coefSST';
                    chi2_3sigma=sqrt((((SSScorr-SSSGP')./eSSSGP2')'*(SSScorr-SSSGP'))/ndata);
                    SSSsol_3sigma=SSSp'+CpGG*vec2;
                end
                % sans correction de biais
                GCmGCd_nocorr=Cp1+diag(eSSSGP2);
                vec2_nocorr=GCmGCd_nocorr\vec';
                SSSsol_nocorr=SSSp'+CpGG*vec2_nocorr;  % solution sans correction relative de biais
                SSSmod_nocorr=SSSprior'+Cp1*vec2_nocorr;      % dans l'espace des donnees
                
                chi2_mens(ilo0,ila0)=chi2;
                chi2_3sigma_mens(ilo0,ila0)=chi2_3sigma;
                biais_est_mens(ilo0,ila0,:)=biais;
                % SSSest_mens(ilo0,ila0,:)=SSSsol;
                SSSest_3sigma_mens(ilo0,ila0,:)=SSSsol_3sigma;
                SSSest_nocorr_mens(ilo0,ila0,:)=SSSsol_nocorr;  % ajout year2
                SSSoutlier_mens(ilo0,ila0)=noutlier;
                
                if time_ok==1
                    tim05=cputime;
                    disp('solution sans outlier')
                    tim=tim05-tim04
                end
                
                % estimation de l'erreur
                dt=30; % on prend les données à +/- 7 jours
                sigSSS_mens=zeros(ntime,1);
                SSSest_gauss=zeros(ntime,1);
                ndat=zeros(ntime,1);
                nout=zeros(ntime,1);
                dchi=zeros(ntime,1);
                bdwellt=zeros(ntime,1);
                meanbdwellt=zeros(ntime,1);
                signatm=zeros(ntime,1);
                icecont=zeros(ntime,1); % ajout year2
                
                bdwell=biais(idwell);
                
                for it=1:ntime
                    t0=tt(it);
                    indt=find(tSSSGP<t0+dt & tSSSGP>t0-dt);
                    ttsel=tSSSGP(indt);
                    nSSS=length(indt);
                    ndat(it)=nSSS;
                    if nSSS >0
                        % estimation de l'erreur bayesienne sur un seul
                        % point en utilisant l'info locale avoisinante
                        GCmGCd1=GCmGCd(indt,indt);
                        CpGG1=CpGG(it,indt);
                        %CpGGb=Cp2GG2(:,indt);
                        %CpGG1b=[CpGG1;CpGGb];
                        % matvart1=matvart0(it,it);
                        invmat=CpGG1*(GCmGCd1\CpGG1');   % ne contient pas la variance du biais dans CpGG1
                        %invmat=CpGG1b*(GCmGCd1\CpGG1b');   % contient la
                        %variance du biais : resultat identique au
                        %precedent sur la propagation de l'erreur sur la
                        %SSS
                        sigSSS_mens(it)=sqrt(stdtt_day(it).*stdtt_day(it)-invmat(1,1));
                        bdwellt(it)=std(bdwell(indt));
                        meanbdwellt(it)=mean(bdwell(indt));
                        % calcul des outliers
                        eS1=eSSSGP(indt);
                        dchitab=chitab(indt);
                        ind=find(dchitab>3);
                        nout(it)=length(ind);
                        dchi(it)=sqrt(dchitab'*dchitab/nSSS);
                        icecont(it)=sum(DgIceGP(indt));
                    else
                        bdwellt(it)=0;
                        dchi(it)=0;
                        nout(it)=0;
                        icecont(it)=0;
                        sigSSS_mens(it)=stdtt_day(it);
                    end
                    % PCTVAR
                    signatm(it)=stdtt_day(it);
                end
                
                % ajout/correction year2
                PCTvar=(sigSSS_mens.^2)./(signatm.^2);
                
                errSSSest_mens(ilo0,ila0,:)=sigSSS_mens;
                outlier_mens(ilo0,ila0,:)=nout;
                ndata_mens(ilo0,ila0,:)=ndat;
                stb_bias_mens(ilo0,ila0,:)=bdwellt;
               % mean_bias_mens(ilo0,ila0,:)=meanbdwellt;  % year1
                mean_bias_mens(ilo0,ila0,:)=SSSsol_3sigma-SSSsol_nocorr;  % year2
                pctvar_mens(ilo0,ila0,:)=PCTvar;
                ice_mens(ilo0,ila0,:)=icecont;
                
                if time_ok==1
                    disp('calcul err mens')
                    tim06=cputime;
                    tim=tim06-tim05
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % estimation hebdomadaire de la salinite %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % les SSS sont corrigées en entrée : biais = 0
                if switch_hebdo==1
                    % reinitialisation de l'erreur
                    eSSSGP2=eSSSGP.*eSSSGP;
                    % on corrige les SSS des biais et on repart sur les
                    % donnees suivantes en mode hebdo
                    SSSGPh=SSSGP+biais(idwell)'.*coefSST;
                    % la SSS prior est la SSS mensuelle
                    SSSprior=SSSmod;    % prior sur les data
                    SSSp=SSSsol_3sigma; % prior sur la grille reguliere
                    % le biais est considéré alors comme nul (on a
                    % corrige les donnees)
                    
                    stdtt_day_h=Cm1*vec4;
                    [st1 st2]=meshgrid(stdtt_day_h,stdtt_day_h);
                    %  st0c=(st1.*st2)*0+0.25;
                    st0c=(st1.*st2);
                    matv=matvarth.*st0c;
                    
                    matvart=matv(indtime,:);       % data X model (sans le biais)
                    Cp1_h=matv(indtime,indtime);     % data X data
                    
                    % GG1 est la matrice identite
                    
                    % GG1Cp1GG1=GG1*Cp1GG1;     % data X data; GG1 est la matrice identite
                    GCmGCd=Cp1_h+diag(eSSSGP2);  % data X data. Sans la partie biais.
                    
                    % CpGG=matvart'*GG1;        % GG1 est la matrice identite
                    CpGG=matvart';              % data X model (sans le biais)
                    vec=SSSGPh-SSSprior';
                    
                    chi2=sqrt((((SSSmod-SSSGPh')./eSSSGP2')'*(SSSmod-SSSGPh'))/(ndata));
                    chitab=sqrt(((SSSmod-SSSGPh')./eSSSGP2').*(SSSmod-SSSGPh'));
                    ind=find(chitab>nsig);
                    noutlier=length(ind);
                    eSSSGP2(ind)=1000;
                    chi2_3sigma=sqrt((((SSSmod-SSSGPh')./eSSSGP2')'*(SSSmod-SSSGPh'))/ndata);
                    
                    % sans correction de biais year2
                    vec=SSSGP-SSSmod_nocorr';
                    GCmGCd=Cp1_h+diag(eSSSGP2);
                    vec2_nocorr=GCmGCd\vec';
                    SSSsol_nocorrh=SSSsol_nocorr+CpGG*vec2_nocorr;  % solution sans correction relative de biais
                    
                    if time_ok==1
                        tim07=cputime;
                        disp('solution 1 hebd')
                        tim=tim07-tim06
                    end
                    
                    % reinitialisation de l'erreur
                    eSSSGP2=eSSSGP.*eSSSGP;
                    
                    % estimation de l'erreur
                    dt=10; % on prend les données à +/- 10 jours
                    sigSSS_hebd=zeros(length(tt),1);
                    SSSest_gauss=zeros(length(tt),1);
                    ndat=zeros(length(tt),1);
                    nout=zeros(length(tt),1);
                    dchi=zeros(length(tt),1);
                    bdwellt=zeros(length(tt),1);
                    meanbdwellt=zeros(length(tt),1);
                    signath=zeros(length(tt),1);
                    SSSwindow=zeros(length(tt),1);
                    SSSwindow_no_outlier=zeros(length(tt),1);
                    bdwell=biais(idwell);
                    
                    % on fait le filtrage à 3 sigmas par rapport à la
                    % solution lissée en ajoutant l'erreur de
                    % représentativité
                    chitab=sqrt(((SSSprior-SSSGPh')./(eSSSGP2'+sigSSS2hebd)).*(SSSprior-SSSGPh'));
                    ind=find(chitab>nsig);
                    eSSSGP2(ind)=1000;
                    GCmGCd_no_outlier=Cp1_h+diag(eSSSGP2);
                    % correction year2
                     for it=1:ntime
                        t0=tt(it);
                        indt=find(tSSSGP<t0+dt & tSSSGP>t0-dt);
                        ttsel=tSSSGP(indt);
                        nSSS=length(indt);
                        ndat(it)=nSSS;
                        if nSSS>0
                            % estimation de l'erreur bayesienne sur un seul
                            % point en utilisant l'info locale avoisinante
                            GCmGCd1=GCmGCd(indt,indt);
                            CpGG1=CpGG(it,indt);
                            % CpGG12=CpGG2(it,indt);  % contient la covariance mensuelle + hebdo
                            
                            % matvart1=matvart0(it,it);
                            veci=vec(indt);
                            SSSwindow(it)=SSSp(it)+CpGG1*(GCmGCd1\veci');
                            
                            % calcul de l'erreur par rapport au champ
                            % mensuel.
                            GCmGCd2=GCmGCd_no_outlier(indt,indt);
                            SSSwindow_no_outlier(it)=SSSp(it)+CpGG1*(GCmGCd2\veci');
                            invmat=CpGG1*(GCmGCd2\CpGG1');   % ne contient pas la variance du biais
                            
                            % calcul de l'erreur
                            % GCmGCd22=GCmGCd_no_outlier2(indt,indt);  % covariance mensuel + hebdo
                            % invmat2=CpGG12*(GCmGCd22\CpGG12');   % ne contient pas la variance du biais (voir commentaire partie mensuelle)
                            
                            sigSSS_hebd(it)=sqrt(stdtt_day_h(it).*stdtt_day_h(it)-invmat);
                            bdwellt(it)=std(bdwell(indt));
                            meanbdwellt(it)=mean(bdwell(indt));
                            
                            % calcul des outliers
                            eS1=eSSSGP(indt);
                            dchitab=chitab(indt);
                            ind=find(dchitab>3);
                            nout(it)=length(ind);
                            dchi(it)=sqrt(dchitab'*dchitab/nSSS);
                            icecont(it)=sum(DgIceGP(indt));
                            % calcul de l'erreur
                            % on additionne les covariances a priori mens et hebdo
                            % sigSSS_hebd2(it)=sqrt(Cptot(it,it)-invmat2);
                            
                            %   sprintf('nSSS=%d, Cp=%f,invmat=%f',nSSS, Cptot(it,it),invmat2)
                        else
                            bdwellt(it)=0;
                            meanbdwellt(it)=0;
                            dchi(it)=0;
                            nout(it)=0;
                            icecont(it)=0;
                            sigSSS_hebd(it)=sqrt(stdtt_day_h(it).*stdtt_day_h(it));
                            % sigSSS_hebd2(it)=sqrt(stdtt_day_h(it).*stdtt_day_h(it)+stdtt_day(it).*stdtt_day(it));
                            SSSwindow_no_outlier(it)=SSSp(it);
                            SSSwindow(it)=SSSp(it);
                        end
                        % PCTVAR : variabilite
                        signath(it)=stdtt_day_h(it);
                    end
                    
                    % PCTvar=sigSSS_hebd./signat;
                    PCTvar=(sigSSS_hebd.^2+sigSSS_mens.^2)./(signath.^2+signatm.^2);  % correction/ajout year2
                    
                    errSSSest_hebd(ilo0,ila0,:)=sqrt(sigSSS_hebd.^2+sigSSS_mens.^2);
                    outlier_hebd(ilo0,ila0,:)=nout;
                    ndata_hebd(ilo0,ila0,:)=ndat;
                    stb_bias_hebd(ilo0,ila0,:)=bdwellt;
                    % mean_bias_hebd(ilo0,ila0,:)=meanbdwellt;  % year1
                    mean_bias_hebd(ilo0,ila0,:)=SSSwindow_no_outlier-SSSsol_nocorrh;  % year2
                    pctvar_hebd(ilo0,ila0,:)=PCTvar;
                    
                    chi2_hebd(ilo0,ila0)=chi2;
                    chi2_3sigma_hebd(ilo0,ila0)=chi2_3sigma;
                    
                    SSSest_hebd(ilo0,ila0,:)=SSSwindow;
                    SSSest_3sigma_hebd(ilo0,ila0,:)=SSSwindow_no_outlier;
                    SSSest_nocorr_hebd(ilo0,ila0,:)=SSSsol_nocorrh;
                    SSSoutlier_hebd(ilo0,ila0)=noutlier;
                    ice_hebd(ilo0,ila0,:)=icecont;
                    
                    if time_ok==1
                        tim08=cputime;
                        disp('calcul err hebd')
                        tim=tim08-tim07
                    end
                    %   keyboard
                end
                
                if time_ok==1
                    disp('time tot')
                    tim3=cputime;
                    tim=tim3-tim0
                end
                
                %    keyboard
%                 figure; 
%                 subplot(2,1,1)
%                 hold on; title(['lat=' num2str(latregion(ila0),4.2) '°,lon=' num2str(lonregion(ilo0),4.2) '°' ])
%                 plot(tt,SSSsol_nocorrh,'r-');plot(tt,SSSsol_nocorr,'k-');
%                 plot(tt,SSSwindow,'r--'); plot(tt,SSSsol_3sigma,'k--'); xlabel('time'); ylabel('SSS'); legend('hebd no corr','mens no corr','hebd corr relat','mens corr relat');
%                 grid on; hold off
%                 subplot(2,1,2)
%                 hold on; plot(tt,PCTvar,'g-');
%                 plot(tt,sqrt(sigSSS_hebd.^2+sigSSS_mens.^2),'r-');
%                 plot(tt,sigSSS_mens,'k-');
%                 plot(tt,sqrt((signath.^2)),'r--');
%                 plot(tt,sqrt((signatm.^2)),'k--');
%                 xlabel('time'); ylabel('errSSS or PCTVAR'); legend('PCTVAR','SSS error hebd','SSS error mens','SSS error hebd prior','SSS error mens prior'); 
%                 grid on; hold off
                
            else
                nok(ilo0,ila0)=0;
            end;
            
            %                 ttisas=datenum(datemois_isas(:,2)+2000,datemois_isas(:,1),15,0,0,0);
            %                 figure;
            %                 subplot(2,1,1); hold on; title(['lon=' num2str(lonregion(ilo0),3) ', lat=' num2str(latregion(ila0),3)]);
            %                 plot(tt,SSSwindow_no_outlier,'r-'); plot(tt,SSSp); plot(ttisas,isasSSSsel(:,ilo0,ila0),'g-'); grid on; legend('7d', '30d'); hold off
            %                 subplot(2,1,2); hold on; plot(tt,signat); grid on; hold off
            %                 keyboard
            
        end
    end
    
    cputime-t
    % calcul de la moyenne temporelle cumulee SMOS et isas
    % on prend la meme base temporelle
    indtime=[];
    for idat=1:length(datemois(:,1))
        indti=find(datemois(idat,1)==datemois_isas(:,1) & datemois(idat,2)==datemois_isas(:,2));
        indtime=[indtime indti];
    end
    minindtimeisas=min(indtime);
    maxindtimeisas=max(indtime);
    datenumisas=datenum(datemois_isas(:,2)+2000,datemois_isas(:,1),15);  % isas centre sur le 15 du mois
    indtisas = find(datenumisas<=max(tt) & datenumisas>=min(tt));
    ttisasday=datenumisas(indtisas);
    
    indtsmos = find(tt<=ttisasday(end) & tt>=ttisasday(1));
    
    meanISAS=zeros(nilo,nila);
    meanSMOS_3sigma_mens=zeros(nilo,nila);
    meanSMOS_hebd=zeros(nilo,nila);
    meanSMOS_3sigma_hebd=zeros(nilo,nila);
    meanSMOS_quant95=zeros(nilo,nila);
    meanISAS_quant95=zeros(nilo,nila);
    meanSMOS_quant=zeros(nilo,nila,9);
    meanISAS_quant=zeros(nilo,nila,9);
    
    quantil=[1:9]*0.1;
    
    for ilo0=1:nilo
        for ila0=1:nila
            SSS1=squeeze(isasSSSsel(indtime,ilo0,ila0));
            % indno0=find(SSS0~=0 & SSS0~=35);
            % meme selection sur isas et SMOS
            % meanISAS(ilo0,ila0)=median(SSS1(indno0));
            % meanSMOS(ilo0,ila0)=median(SSS0(indno0));
            meanISAS(ilo0,ila0)=median(SSS1);
            
            SSS0=squeeze(SSSest_hebd(ilo0,ila0,indtsmos));
            meanSMOS_hebd(ilo0,ila0)=median(SSS0);
            
            SSS0=squeeze(SSSest_3sigma_mens(ilo0,ila0,indtsmos));
            meanSMOS_3sigma_mens(ilo0,ila0)=median(SSS0);
            
            SSS0=squeeze(SSSest_3sigma_hebd(ilo0,ila0,indtsmos));
            meanSMOS_3sigma_hebd(ilo0,ila0)=median(SSS0);
            
            SSS0=squeeze(SSSest_3sigma_mens(ilo0,ila0,indtsmos));
            
            % calcul des histogrammes
            N0sort=sort(SSS0);
            N1sort=sort(SSS1);
            
            tt0=ones(length(SSS0),1)/length(SSS0);
            ctt0=cumsum(tt0);
            tt1=ones(length(SSS1),1)/length(SSS1);
            ctt1=cumsum(tt1);
            [v0 ind0]=min(abs(ctt0-0.95));
            [v1 ind1]=min(abs(ctt1-0.95));
            
            meanSMOS_quant95(ilo0,ila0)=N0sort(ind0);
            meanISAS_quant95(ilo0,ila0)=N1sort(ind1);
            
            for iqu=1:9
                [v0 ind0]=min(abs(ctt0-0.1*iqu));
                [v1 ind1]=min(abs(ctt1-0.1*iqu));
                meanSMOS_quant(ilo0,ila0,iqu)=N0sort(ind0);
                meanISAS_quant(ilo0,ila0,iqu)=N1sort(ind1);
            end
        end
    end
    
    % calcul du biais 0 pour la correction
    biais0_3sigma_mens=meanSMOS_3sigma_mens-meanISAS;
    biais0_3sigma_hebd=meanSMOS_3sigma_hebd-meanISAS;
    biais0_3sigma_quant95=meanSMOS_quant95-meanISAS_quant95;
    biais0_3sigma_quant90=squeeze(meanSMOS_quant(:,:,9))-squeeze(meanISAS_quant(:,:,9));
    
    % on split les fichiers en morceaux pour que ça prenne moins de
    % place
    save([namesave '_mens.mat'],'tt','lonregion','latregion','datemois', ...
        'chi2_3sigma_mens','SSSoutlier_mens','nok','SSSest_3sigma_mens','SSSest_nocorr_mens', ...
        'biais_est_mens', 'biais0_3sigma_mens','biais0_3sigma_hebd', 'biais0_3sigma_quant90', 'biais0_3sigma_quant95', ...
        'isasSSSsel','ttisasday','minindtimeisas','maxindtimeisas', ...
        'xswathsel','xswathlim','lon','lat','xswath','conf','SSTmoy','quantil','meanSMOS_quant','meanISAS_quant', '-v7.3')
    
    % indicateurs statistiques mensuelle
    save([namesave '_ind_mens.mat'],'tt','lonregion','latregion','datemois','nok', ...
        'outlier_mens','errSSSest_mens','ndata_mens','stb_bias_mens','mean_bias_mens','pctvar_mens','ice_mens', ...
        'biais_est_mens','quantil','meanSMOS_quant','meanISAS_quant','conf','-v7.3')
    
    save([namesave '_hebd.mat'],'tt','lonregion','latregion','datemois', ...
        'chi2_3sigma_hebd','SSSoutlier_hebd','nok','SSSest_3sigma_hebd','SSSest_nocorr_hebd', ...
        'biais_est_mens', 'biais0_3sigma_mens','biais0_3sigma_hebd', 'biais0_3sigma_quant90', 'biais0_3sigma_quant95', ...
        'isasSSSsel','ttisasday','minindtimeisas','maxindtimeisas', ...
        'xswathsel','xswathlim','lon','lat','xswath','conf','SSTmoy','quantil','meanSMOS_quant','meanISAS_quant', '-v7.3')
    
    % indicateurs statistiques hebdo
    save([namesave '_ind_hebd.mat'],'tt','lonregion','latregion','datemois','nok', ...
        'outlier_hebd','errSSSest_hebd','ndata_hebd','stb_bias_hebd','mean_bias_hebd','pctvar_hebd','ice_hebd', ...
        'biais_est_mens','quantil','meanSMOS_quant','meanISAS_quant','conf','-v7.3')
end

exit
