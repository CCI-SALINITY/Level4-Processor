% modèle d'erreur
clear

SMAPvers='v4';  % v3 ou v4

% chargement dmin EASE
load('G:\dataSMOS\CATDS\repro_2017\maskdmin_ease2.mat');

% chargement de la variabilite pour virer les points a forte variablite
load('F:\vergely\SMOS\CCI\livrables\CCI_soft_year1\aux_files\smos_isas_rmsd_ease_smooth.mat') % utilisation de std =rmsdmerge
stdvarlim=0.2;

set(groot,'DefaultFigureColormap',jet)

plot_fig=1;
% pour utiliser densityplot
limxy.xmin=-3; limxy.xmax=32;
limxy.ymin=-8; limxy.ymax=8;
limxy.facm=20;

% dires
dires=['plot_2016_' SMAPvers '\'];
if exist(dires)==0; mkdir(dires); end;

% chargement ISAS
load('G:\dataSMOS\CATDS\repro_2017\isas_CATDS')
yearisas=datemois_isas(:,2);
moisisas=datemois_isas(:,1);

% lecture des fichiers journaliers
pathfile=['I:\SMAP_data\RSS\L2C_' SMAPvers '\file_mat_40km\'];
dirfile=dir(pathfile);

nlon=length(lon_fixgrid);
nlat=length(lat_fixgrid);

nfil=100;

mapSSS1A=NaN(nfil,nlon,nlat);
mapSSS1D=NaN(nfil,nlon,nlat);
mapSSS2A=NaN(nfil,nlon,nlat);
mapSSS2D=NaN(nfil,nlon,nlat);
mapSSTA=NaN(nfil,nlon,nlat);
mapSSTD=NaN(nfil,nlon,nlat);
mapISAS=NaN(nfil,nlon,nlat);

kA=0; kD=0;
for ifi=3:103
    ifi
    namefile=dirfile(ifi).name;
    
    namefile(5)='A';
    pathnamefile=[pathfile namefile];
    load(pathnamefile);    %'SSS1A','SSS2A','tSSS1A','tSSS2A','WS1A','WS2A','rain1A','rain2A'
    
    kA=kA+1;
    mapSSS1A(kA,:,:)=SSS1;
    mapSSS2A(kA,:,:)=SSS2;
    mapSSTA(kA,:,:)=SST1;
    dayA(kA)=str2num(namefile(13:14));
    monA(kA)=str2num(namefile(11:12));
    
    namefile(5)='D';
    pathnamefile=[pathfile namefile];
    load(pathnamefile);
    
    kD=kD+1;
    mapSSS1D(kD,:,:)=SSS1;
    mapSSS2D(kD,:,:)=SSS2;
    mapSSTD(kD,:,:)=SST1;
    dayD(kD)=str2num(namefile(13:14));
    monD(kD)=str2num(namefile(11:12));
    
    fmonth=monD(kD);
    fyear=str2num(namefile(9:10));
    indisas=find(fyear==yearisas & fmonth==moisisas);
    mapISAS0=squeeze(isasSSS(indisas,:,:));
    mapISAS(kD,:,:)=mapISAS0;
    
    % selection zones non variables
    stdnat=squeeze(rmsdmerge(:,:,fmonth));
    indvar=find(stdnat>stdvarlim);
    mapSSS1A(kA,indvar)=NaN;
    mapSSS2A(kA,indvar)=NaN;
    mapSSS1D(kD,indvar)=NaN;
    mapSSS2D(kD,indvar)=NaN;
end

sig_theoA=0.38./(0.015.*mapSSTA+0.25);
sig_theoD=0.38./(0.015.*mapSSTD+0.25);

% keyboard
tabd=50:100:4000;
dd=50;

for dlat=40:40:80;
    stdnorm_dd1=0.*tabd;
    stdnorm_dd2=0.*tabd;
    
    indlat=find(lat_fixgrid>dlat | lat_fixgrid<-dlat);
    dmin2=dmin;
    dmin2(:,indlat)=NaN;
    
    dSSSnormA=(mapSSS1A-mapSSS2A)./(sqrt(2)*sig_theoA);
    dSSSnormD=(mapSSS1D-mapSSS2D)./(sqrt(2)*sig_theoD);
    
    stdnorm_ddA=0.*tabd;
    stdnorm_ddD=0.*tabd;
    norm_mean_ddA=0.*tabd;
    norm_mean_ddD=0.*tabd;
    std_stdnorm_dd=0.*tabd;
    nnA=0.*tabd;
    nnD=0.*tabd;
    
    dmin1=NaN(size(dSSSnormA,1),nlon,nlat);
    for ii=1:size(dSSSnormA,1)
        dmin1(ii,:,:)=dmin2;
    end
    
    diffisas1A=(mapSSS1A-mapISAS)./sig_theoA;
    diffisas2A=(mapSSS2A-mapISAS)./sig_theoA;
    stdisas1A=0.*tabd;
    stdisas2A=0.*tabd;
    diffisas1D=(mapSSS1D-mapISAS)./sig_theoD;
    diffisas2D=(mapSSS2D-mapISAS)./sig_theoD;
    stdisas1D=0.*tabd;
    stdisas2D=0.*tabd;
    
    % pour aft-for on a sqrt(2) X l'erreur
    for itab=1:length(tabd)
        indtt=find(dmin1<tabd(itab)+dd & dmin1>tabd(itab)-dd);
        tA=dSSSnormA(indtt);
        stdnorm_ddA(itab)=nanstd(tA);     % biaisé vers les faibles valeurs car pas beaucoup de valeurs pour estimer les std par noeud de grille
        norm_mean_ddA(itab)=nanmean(tA);  % beaucoup trop sensible aux outlier
        nnA(itab)=length(find(isnan(tA)==0));
        tD=dSSSnormD(indtt);
        stdnorm_ddD(itab)=nanstd(tD);     % biaisé vers les faibles valeurs car pas beaucoup de valeurs pour estimer les std par noeud de grille
        norm_mean_ddD(itab)=nanmean(tD);  % beaucoup trop sensible aux outlier
        nnD(itab)=length(find(isnan(tD)==0));
        %  figure; hold on; histogram(stdnorm(indtt)); axis([0 6 0 nn(itab)/10]); hold off
        tisas1A=diffisas1A(indtt);
        tisas2A=diffisas2A(indtt);
        stdisas1A(itab)=nanstd(tisas1A);
        stdisas2A(itab)=nanstd(tisas2A);
        tisas1D=diffisas1D(indtt);
        tisas2D=diffisas2D(indtt);
        stdisas1D(itab)=nanstd(tisas1D);
        stdisas2D(itab)=nanstd(tisas2D);
    end
    
    figure
    hold on
    title(['std diff vs coast distance (SSSaft-SSSfor)/(errSSS*sqrt(2)). Norm, abs(lat)<' num2str(dlat) '°'])
    plot(tabd,stdnorm_ddA,'g-')
    plot(tabd,stdnorm_ddD,'b-')
    axis([0 4000 0.9 1.6])
    legend('A', 'D')
    xlabel('dcoast (km)'); ylabel('std diff');
    grid on
    hold off
    saveas(gcf,[dires 'PLOT_diff_aft_for_NORM_vs_dist_LAT_' num2str(dlat) '_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')
   
    figure
    subplot(2,1,1)
    hold on
    title(['mean diff vs coast distance (SSSaft-SSSfor)/(errSSS*sqrt(2)). Norm, abs(lat)<' num2str(dlat) '°'])
    plot(tabd,norm_mean_ddA,'-')
    plot(tabd,norm_mean_ddD,'b-')
    axis([0 4000 -0.1 0.2])
    legend('A', 'D')
    xlabel('dcoast (km)'); ylabel('mean diff');
    grid on
    hold off
    subplot(2,1,2)
    hold on
    title('ndata vs coast distance')
    plot(tabd,nnA,'-')
    plot(tabd,nnD,'b-')
    legend('A', 'D')
    xlabel('dcoast (km)'); ylabel('ndata');
    grid on
    hold off
    
    saveas(gcf,[dires 'PLOT2_diff_aft_for_NORM_vs_dist_LAT_' num2str(dlat) '_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')
    
    figure
    hold on
    title(['std diff ISAS vs coast distance. Norm, abs(lat)<' num2str(dlat) '°'])
    plot(tabd,stdisas1A,'k-')
    plot(tabd,stdisas2A,'k--')
    plot(tabd,stdisas1D,'r-')
    plot(tabd,stdisas2D,'r--')
    axis([0 4000 1.1 1.9])
    grid on; xlabel('dcoast'); ylabel('std((SMAP-ISAS)/errSMAP)');
    legend('aft, A', 'for, A', 'aft, D', 'for, D')
    hold off
    
    saveas(gcf,[dires 'PLOT_diff_SMAP_ISAS_NORM_vs_dist_LAT_' num2str(dlat) '_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')
    
end

% Error estimation (forward method)
% on compare aft - for sans ponderation par l'erreur -> erreur vraie minimale
% on compare aft - ISAS erreur par rapport à ISAS
% on compare for - ISAS
% une estimation de la variabilité non vue par ISAS + erreur ISAS est la difference entre
% l'erreur par rapport a ISAS et l'erreur minimale

dSSSA=(mapSSS1A-mapSSS2A);
dSSSD=(mapSSS1D-mapSSS2D);
diffisas1A=mapSSS1A-mapISAS;
diffisas2A=mapSSS2A-mapISAS;
diffisas1D=mapSSS1D-mapISAS;
diffisas2D=mapSSS2D-mapISAS;
err1A=0.*tabd;
err1D=0.*tabd;

%%%%%%%%%%%%%%%%
%%%%% MAPS %%%%%
%%%%%%%%%%%%%%%%
mapstd1A=squeeze(nanstd(dSSSA)/sqrt(2));
mapstd1Aisas=squeeze(nanstd(diffisas1A));
mapstd1D=squeeze(nanstd(dSSSD)/sqrt(2));
mapstd1Disas=squeeze(nanstd(diffisas1D));
ind0=find(mapstd1A==0);
mapstd1A(ind0)=NaN;
ind0=find(mapstd1D==0);
mapstd1D(ind0)=NaN;
ind0=find(mapstd1Aisas==0);
mapstd1Aisas(ind0)=NaN;
ind0=find(mapstd1Disas==0);
mapstd1Disas(ind0)=NaN;

mapmean1A=squeeze(nanmean(mapSSS1A));
mapmean1D=squeeze(nanmean(mapSSS1D));
mapmean1A_D=squeeze(nanmean(mapSSS1A-mapSSS1D));
%%%% attention si il y a 1 ou 2 elements, la std est mise à 0 et pas à NaN
mapstd1A_D=squeeze(nanstd((mapSSS1A-mapSSS1D)))/sqrt(2);
mapstd2A_D=squeeze(nanstd((mapSSS2A-mapSSS2D)))/sqrt(2);
mapstd1A_Dnorm=squeeze(nanstd((mapSSS1A-mapSSS1D)./sqrt(sig_theoA.^2+sig_theoD.^2)));
mapstd2A_Dnorm=squeeze(nanstd((mapSSS2A-mapSSS2D)./sqrt(sig_theoA.^2+sig_theoD.^2)));

ind0=find(mapstd1A_D==0 | mapstd2A_D==0 | mapstd1A_Dnorm==0 | mapstd2A_Dnorm==0);
mapstd1A_D(ind0)=NaN;
mapstd2A_D(ind0)=NaN;
mapstd1A_Dnorm(ind0)=NaN;
mapstd2A_Dnorm(ind0)=NaN;


figure
subplot(2,2,1)
hold on
title('(aft - for) error, A. No norm, all lat.')
imagesc(mapstd1A'); axis tight;
caxis([0 2]); colorbar
hold off
subplot(2,2,2)
hold on
title('(aft - ISAS), A')
imagesc(mapstd1Aisas'); axis tight;
caxis([0 2]); colorbar
hold off
subplot(2,2,3)
hold on
title('(aft - for), D')
imagesc(mapstd1D'); axis tight;
caxis([0 2]); colorbar
hold off
subplot(2,2,4)
hold on
title('(aft - ISAS), D')
imagesc(mapstd1Disas'); axis tight;
caxis([0 2]); colorbar
hold off

saveas(gcf,[dires 'MAP_diff_aft_for_NO_NORM_vs_dist_allLAT_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')


%%% asc - desc
figure
subplot(2,2,1)
hold on
title('mean(A) - mean(D), afte. No norm, all lat.')
imagesc(mapmean1A'-mapmean1D'); axis tight;
caxis([-0.5 0.5]); colorbar
hold off
subplot(2,2,2)
hold on
title('mean(A-D), afte')
imagesc(mapmean1A_D'); axis tight;
caxis([-0.5 0.5]); colorbar
hold off
subplot(2,2,3)
hold on
title('std(A-D)/sqrt(2), aft, daily comp')
imagesc(mapstd1A_D'); axis tight;
caxis([0 2]); colorbar
hold off
subplot(2,2,4)
hold on
title('std(A-D)/sqrt(2), for, daily comp')
imagesc(mapstd2A_D'); axis tight;
caxis([0 2]); colorbar
hold off

saveas(gcf,[dires 'MAP_diff_A_D_NO_NORM_vs_dist_allLAT_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')

% difference des bruits obtenus par comparaison aft et for et par
% comparaison A et D
figure
hold on
title('std from aft and for comp - std from A and D comp')
imagesc(mapstd1A'-mapstd1A_D')
caxis([-0.4 0.4]); colorbar; axis tight;
hold off

saveas(gcf,[dires 'MAP_diff_STD_aftfor_AD_NO_NORM_vs_dist_allLAT_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')


for dlat=40:20:40;
    stdnorm_dd1=0.*tabd;
    stdnorm_dd2=0.*tabd;
    
    indlat=find(lat_fixgrid>dlat | lat_fixgrid<-dlat);
    dmin2=dmin;
    dmin2(:,indlat)=NaN;
    % on derive l'erreur par comparaison asc desc
    for itab=1:length(tabd)
        indtt=find(dmin2<tabd(itab)+dd & dmin2>tabd(itab)-dd);
        t1=mapstd1A_D(indtt);
        t2=mapstd2A_D(indtt);
        std_dd1(itab)=nanmedian(t1);     %
        std_dd2(itab)=nanmedian(t2);     %
        t1n=mapstd1A_Dnorm(indtt);
        t2n=mapstd2A_Dnorm(indtt);
        stdnorm_dd1(itab)=nanmedian(t1n);     %
        stdnorm_dd2(itab)=nanmedian(t2n);     %
    end
    
    NN=8;
    tabd1=tabd/1000;
    pp=polyfit(tabd1,stdnorm_dd1,NN);
    soltab=0.*tabd1;
    for ipp=1:NN
        soltab=soltab+pp(ipp)*tabd1.^(NN+1-ipp);
    end
    soltab=soltab+pp(NN+1);
   
    ind=find(soltab<1); soltab(ind)=1; 
    ind=find(tabd>3000); soltab(ind)=1; 
    
    figure
    subplot(2,1,1)
    hold on
    title(['median (std(A - D) daily) vs coast distance, abs(lat)<' num2str(dlat) '°'])
    plot(tabd,std_dd1,'k-')
    plot(tabd,std_dd2,'k--')
    axis([0 4000 0.5 0.9])
    grid on; xlabel('dcoast'); ylabel('std(A-D)');
    legend('aft', 'for')
    hold off
    subplot(2,1,2)
    hold on
    title(['median (std(A - D)/sqrt(errSSSA²+errSSSD²) daily) vs coast distance'])
    plot(tabd,stdnorm_dd1,'k-')
    plot(tabd,stdnorm_dd2,'k--')
    axis([0 4000 0.9 1.4])
    grid on; xlabel('dcoast'); ylabel('std((A-D)/norm)');
    legend('aft', 'for')
    plot(tabd,soltab,'r-')
    hold off
    
    saveas(gcf,[dires 'PLOT_diff_A_D_vs_dist_LAT_' num2str(dlat) '_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')
    
end

keyboard
% estimation variablité naturelle vue par Aquarius en comparaison avec
% celle d'ISAS
ind=find(mapstd1Aisas<mapstd1A);
mapstd1Aisas(ind)=0;
mapstd1A(ind)=0;
varnatA=sqrt(mapstd1Aisas.^2-mapstd1A.^2);

ind=find(mapstd1Aisas<mapstd1A_D);
mapstd1Aisas(ind)=0;
mapstd1A_D(ind)=0;
varnat1AD=sqrt(mapstd1Aisas.^2-mapstd1A_D.^2);

ind=find(mapstd1Disas<mapstd1D);
mapstd1Disas(ind)=0;
mapstd1D(ind)=0;
varnatD=sqrt(mapstd1Disas.^2-mapstd1D.^2);

ind=find(mapstd1Aisas<mapstd2A_D);
mapstd1Aisas(ind)=0;
mapstd2A_D(ind)=0;
varnat2AD=sqrt(mapstd1Aisas.^2-mapstd2A_D.^2);


%mapstd1A_D
figure
subplot(2,1,1)
hold on
title('variability (std), A')
%imagesc(varnatA'); axis tight;
imagesc(varnat1AD'); axis tight;
caxis([0 1.5]); colorbar
hold off
subplot(2,1,2)
hold on
title('variability (std), D')
%imagesc(varnatD'); axis tight;
imagesc(varnat2AD'); axis tight;
caxis([0 1.5]); colorbar
hold off

saveas(gcf,[dires 'MAP_VARnat_A_D_NO_NORM_allLAT_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')

%mapstd1A_D
figure
subplot(2,1,1)
hold on
title('variability (std), A')
imagesc(varnatA'); axis tight;
%imagesc(varnat1AD'); axis tight;
caxis([0 1.5]); colorbar
hold off
subplot(2,1,2)
hold on
title('variability (std), D')
imagesc(varnatD'); axis tight;
%imagesc(varnat2AD'); axis tight;
caxis([0 1.5]); colorbar
hold off

saveas(gcf,[dires 'MAP1_VARnat_A_D_NO_NORM_allLAT_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')


% pour aft-for on a sqrt(2) X l'erreur
for itab=1:length(tabd)
    indtt=find(dmin1<tabd(itab)+dd & dmin1>tabd(itab)-dd);
    tA=dSSSA(indtt);
    err1A(itab)=nanstd(tA)/sqrt(2);     % biaisé vers les faibles valeurs car pas beaucoup de valeurs pour estimer les std par noeud de grille
    tD=dSSSD(indtt);
    err1D(itab)=nanstd(tD)/sqrt(2);     % biaisé vers les faibles valeurs car pas beaucoup de valeurs pour estimer les std par noeud de grille
end

figure
hold on
title(['afte-for. No norm, all lat'])
plot(tabd,err1A,'-')
plot(tabd,err1D,'-')
grid on
xlabel('dcoast'); ylabel('std(aft-for)');
legend('Asc' ,'Desc')
hold off

saveas(gcf,[dires 'PLOT_diff_aft_for_NO_NORM_vs_dist_allLAT_limVAR_' num2str(round(10*stdvarlim)) '_smap_' SMAPvers],'png')


