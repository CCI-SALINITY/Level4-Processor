% lecture des resultats biais cotier
% construction d'un .mat qui contient le biais absolu et le biais relatif
% par type d'acquisition


clear
set(groot,'DefaultFigureColormap',jet)

load('K:\partitionD\CCI_2020\AUX_FILES\latlon_ease.mat');

load('STD_quantile.mat');   % errtot

nla=length(lat_ease);

% limites des differentes zones
% limites des differentes zones

minlontab=[-180 -172 -164 -156 -148 -140 -132 -124 -116 -108 -100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100 108 116 124 132 140 148 156 164 172];
maxlontab=[-172 -164 -156 -148 -140 -132 -124 -116 -108 -100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100 108 116 124 132 140 148 156 164 172 180];
minlattab=[-90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90 -90];
maxlattab=[90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90];

% minlontab=[-181  -165  -150  -135  -120  -105   -90   -75   -60   -45   -30   -15    0    15    30    45    60    75    90   105   120   135   150   165];
% maxlontab=[-165  -150  -135  -120  -105   -90   -75   -60   -45   -30   -15     0   15    30    45    60    75    90   105   120   135   150   165   181];
% minlattab=[ -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90  -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90   -90];
% maxlattab=[  90    90    90    90    90    90    90    90    90    90    90    90   90    90    90    90    90    90    90    90    90    90    90    90];

minlon=min(minlontab);
maxlon=max(maxlontab);
minlat=min(minlattab);
maxlat= max(maxlattab);

nzone=length(minlontab);

load coast
lonc=long;
latc=lat;

days19700101=datenum(1970,1,1,0,0,0);  % date de reference dans les produits

biais_relative=[];
biais_absolu=[];
SSSoutlier=[];
ok=[];

dtime=4;

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
    indlonsel=find(lon_ease<=maxlon & lon_ease>minlon);
    indlatsel=find(lat_ease<=maxlat & lat_ease>minlat);
    nlon=length(indlonsel);
    
    namezone=['matfile\'];
    namesave=['prod_Lm_' num2str(abs(minlon)) '_LM_'  num2str(abs(maxlon)) '_lm_' num2str(abs(minlat)) '_lM_'  num2str(abs(maxlat)) '_mens.mat'];
    
    load([namezone namesave],'meanSMOS_quant','meanISAS_quant','biais_est_mens','nok','tt');
    if izone==1
        load([namezone namesave],'xswathsel','xswath','xswathlim');
    end
    % perc_outlier_mens=outlier_mens./ndata_mens;
    % perc_outlier_mens=perc_outlier_mens(:,:,1:dtime:end);
    
    ttf=tt(1:dtime:end);
    
    %    keyboard
    nok0=nok.*0+NaN;
    ind=find(nok > 0);
    nok0(ind)=1;
    iinit=indlonsel(1);
    ifin=indlonsel(end);
    
    biais0_3sigma_iquant=squeeze(meanSMOS_quant(:,:,1)).*0;
    
    % ERREUR ABSOLUE
    % calcul du quantile selon l'erreur de representativite
    errtotsel=errtot(iinit:ifin,:);
    iq=round((1.5*errtotsel-0.4)*10);
    indlow=find(errtotsel<=0.6);
    iq(indlow)=5;
    indhigh=find(errtotsel>=0.8);
    iq(indhigh)=8;
    indNaN=find(isnan(iq));   % terre
    iq(indNaN)=5;
    for ilo=1:nlon
        for ila=1:nla
            iquant=iq(ilo,ila);
            biais0_3sigma_iquant(ilo,ila)=meanSMOS_quant(ilo,ila,iquant)-meanISAS_quant(ilo,ila,iquant);
        end
    end
    
    % biais_est_mens correction relative a la dwell central SMOS (58,584,73)
    biais_relative=[biais_relative; biais_est_mens];
    
    % correction a appliquer : SSS0-biais0_3sigma_iquant avec SSS0 corrigée
    % de l'erreur relative
    biais_absolu=[biais_absolu; biais0_3sigma_iquant];
    % SSSoutlier=[SSSoutlier; perc_outlier_mens];
    % ok=[ok; nok0];
end

% save('corrbias','SSSoutlier','biais_absolu','biais_relative','ok','ttf','xswathsel','xswath','xswathlim','-v7.3')
save('corrbias2020','biais_absolu','biais_relative','ttf','xswathsel','xswath','xswathlim','-v7.3')

% comparaison des biais avec l'ancienne version
% nouvelle version 2020
load('corrbias2020')
biais_absolu2020=biais_absolu;
biais_relatif2020=biais_relative;

% ancienne version 2019
load('corrbias','biais_absolu','biais_relative')
biais_absolu2019=biais_absolu;
biais_relatif2019=biais_relative;


% biais absolu
figure
subplot(2,1,1)
hold on
title('absolute bias 2020')
imagesc(biais_absolu2020')
caxis([-1 1]); colorbar
hold off
subplot(2,1,2)
hold on
title('absolute bias 2019')
imagesc(biais_absolu2019')
caxis([-1 1]); colorbar
hold off


% biais relatif - abs
idw=34+17;

for idw=1:20
    biais2020=squeeze(biais_relatif2020(:,:,idw))-biais_absolu2020;
    biais2019=squeeze(biais_relatif2019(:,:,idw))-biais_absolu2019;
    
    figure
    subplot(2,1,1)
    hold on
    title('total bias 2020')
    imagesc(biais2020')
    caxis([-1 1]); colorbar
    hold off
    subplot(2,1,2)
    hold on
    title('total bias 2019')
    imagesc(biais2019')
    caxis([-1 1]); colorbar
    hold off
    
end

idw=2;
biais2020=squeeze(biais_relatif2020(:,:,idw))-biais_absolu2020;
biais2019=squeeze(biais_relatif2019(:,:,idw))-biais_absolu2019;

figure
hold on
title('total bias 2020 - total biais 2019')
imagesc(biais2020'-biais2019'); axis tight;
caxis([-0.5 0.5]); colorbar
hold off

