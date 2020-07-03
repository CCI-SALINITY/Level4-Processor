% modèle d'erreur
% on compare des données à 8 jours

clear

set(groot,'DefaultFigureColormap',jet)

load('D:\CCI_2020\AUX_FILES\maskdmin_ease2')

repaqu='F:\CCI_data\2020\input\aqua_data\file_mat\';

% chargement de la variabilite pour virer les points a forte variablite
load('D:\CCI_2020\AUX_FILES\smos_isas_rmsd_ease_smooth.mat') % utilisation de std =rmsdmerge
stdvarlim=0.2;


nlon=length(lonDGG);
nlat=length(latDGG);

dirfile=dir(repaqu);

orb='A';
nameaqua=['aqua' orb '_20100701.mat']   % on pose A ou D

% on traite 3 ans 2012, 2013, 2014
dSSS=NaN(3*365,nlon,nlat);
SST=NaN(3*365,nlon,nlat);

k=0;
for ifil=3:length(dirfile)
    yearn=str2num(dirfile(ifil).name(7:10));
    if dirfile(ifil).name(5)==orb & yearn<2015 & yearn>2011
        load([repaqu dirfile(ifil).name]);  % 'SSS1','tSSS1','eSSS1','SST1'
        
        SSSa=SSS1;
        SSTa=SST1;
        ind=find(isnan(tSSS1)==0);
        tt=floor(tSSS1(ind(1)));
        
        tt2=tt+7;
        vecd=datevec(tt2);
        
        yearc=num2str(vecd(1));
        monc=num2str(vecd(2));
        if length(monc)<2; monc=['0' monc]; end;
        dayc=num2str(vecd(3));
        if length(dayc)<2; dayc=['0' dayc]; end;
        
        name_res=nameaqua;
        name_res(7:10)=yearc;
        name_res(11:12)=monc;
        name_res(13:14)=dayc;
        fmonth=str2num(monc);
        nametot=[repaqu name_res];
        
        if exist(nametot)
            k=k+1
            load(nametot);
            
            % selection zones non variables
            stdnat=squeeze(rmsdmerge(:,:,fmonth));
            indvar=find(stdnat>stdvarlim);
            SSS1(indvar)=NaN;
            
            SSSb=SSS1;
            SSTb=SST1;
            
            dSSS(k,:,:)=SSSa-SSSb;
            SST(k,:,:)=(SSTa+SSTb)/2;
            ttm(k)=(tt+tt2)/2;
        end
    end
end

ind0=find(dSSS==0);
dSSS(ind0)=NaN;

errSSS=squeeze(nanstd(dSSS))/sqrt(2);
medSSS=squeeze(nanmedian(dSSS));

medtab=NaN(3*365,nlon,nlat);
for itt=1:3*365
    medtab(itt,:,:)=medSSS;
end

stdrob=squeeze(nanmedian(abs(dSSS-medtab))/0.6745/sqrt(2));

figure
hold on
title(['errSSS from 7day revisit, ' orb '_limVAR_' num2str(round(10*stdvarlim))])
imagesc(errSSS'); caxis([0 0.8]); colorbar; axis tight;
hold off

saveas(gcf,['map_stdSSSaqua_7days_' orb '_limVAR_' num2str(round(10*stdvarlim))],'png')
saveas(gcf,['map_stdSSSaqua_7days_' orb '_limVAR_' num2str(round(10*stdvarlim))],'fig')

figure
hold on
title(['errSSS robust from 7day revisit, ' orb])
imagesc(stdrob'); caxis([0 0.8]); colorbar; axis tight;
hold off

saveas(gcf,['map_stdrobustSSSaqua_7days_' orb '_limVAR_' num2str(round(10*stdvarlim))],'png')
saveas(gcf,['map_stdrobustSSSaqua_7days_' orb '_limVAR_' num2str(round(10*stdvarlim))],'fig')


tabSST=[-1:1:32];
dsst=1;

% pour le filtrage en latitude
latlim=45;
indlat=find(abs(lat_fixgrid)>latlim);
% pour le filtrage en distance
dmin1=NaN(size(dSSS,1),nlon,nlat);
for ii=1:size(dSSS,1)
    dmin1(ii,:,:)=dmin;
end


for itest=1:2;
    if itest==1; indd=find(dmin1<1000); tit='dcoast>1000km'; cond='ocean'; end
    if itest==2; indd=find(dmin1>1000); tit='dcoast<1000km'; cond='coast'; end
    
    dSSS0=dSSS;
    dSSS0(indd)=NaN;
    dSSS0(:,:,indlat)=NaN;  % filtrage sur les latitudes
    dSSS_SST=[];
    mSSS_SST=[];
    for isst=1:length(tabSST)
        isst
        indSST=find(SST<tabSST(isst)+dsst & SST>tabSST(isst)-dsst);
        
        dSSS_SST(isst)=nanstd(dSSS0(indSST))/sqrt(2);
        mSSS_SST(isst)=nanmedian(dSSS0(indSST));
        
        dSSSrob_SST(isst)=nanmedian(abs(mSSS_SST(isst)-dSSS0(indSST)))/0.6745/sqrt(2);
        nn(isst)=length(indSST);
    end
    sig_theo1=0.085./(0.015.*tabSST+0.25); % si on tient compte de la
    %   sensibilité effective du Stokes 1
    %  sig_theo=0.17./(0.03.*tabSST+0.25);  % empirique
    
    figure
    hold on
    title(['Aquarius SSS error characterization, ' orb ', ' tit])
    % plot(tabSST,dSSS_SST,'-')
    plot(tabSST,dSSSrob_SST,'g-')
    % plot(tabSST,sig_theo,'k-')
    plot(tabSST,sig_theo1,'k--')
    % plot(tabSST,log10(nn)/10,'m-')
    grid on
    axis([-2 32 0 0.8])
    xlabel('SST'); ylabel('std(Aqua-Ref)');
    %legend('std(1day - 7days)','std rob(1day - 7days)','empirical model')
    legend('std rob(1day - 7days)','empirical model')
    hold off
    
    saveas(gcf,['stdSSSaqua_7days_' orb '_' cond '_limVAR_' num2str(round(10*stdvarlim)) '_LAT_' num2str(latlim)],'png')
    saveas(gcf,['stdSSSaqua_7days_' orb '_' cond '_limVAR_' num2str(round(10*stdvarlim)) '_LAT_' num2str(latlim)],'fig')
end

keyboard

tabd=50:100:4000;
dd=50;

std_dd=0*tabd;
mean_dd=0*tabd;
dSSS0=dSSS;
dSSS0(:,:,indlat)=NaN;  % filtrage sur les latitudes
sigSST=0.085./(0.015.*SST+0.25); % si on tient compte de la variabilite
% pour aft-for on a sqrt(2) X l'erreur
for itab=1:length(tabd)
    indtt=find(dmin1<tabd(itab)+dd & dmin1>tabd(itab)-dd);
    tA=dSSS0(indtt);
    std_dd(itab)=nanstd(tA);     % biaisé vers les faibles valeurs car pas beaucoup de valeurs pour estimer les std par noeud de grille
    mean_dd(itab)=nanmean(tA);  % beaucoup trop sensible aux outlier
    nn(itab)=length(find(isnan(tA)==0));
    median_dd(itab)=nanmedian(tA);
    dSSSrob_dd(itab)=nanmedian(abs(median_dd(itab)-tA))/0.6745/sqrt(2);
    
    tAnorm=dSSS0(indtt)./sigSST(indtt);
    median_dd_norm(itab)=nanmedian(tAnorm);
    dSSSrob_dd_norm(itab)=nanmedian(abs(median_dd_norm(itab)-tAnorm))/0.6745/sqrt(2);
    
end

figure
hold on
title(['Aqua SSS error vs dcoast, abs(lat)<' num2str(latlim) ', stdvarlim=' num2str(stdvarlim)])
%plot(tabd,std_dd,'-')
plot(tabd,dSSSrob_dd,'-')
grid on
xlabel('dcoast (km)'); ylabel('std diff');
hold off

saveas(gcf,['stdSSSaqua_7days_vs_distance_' orb '_limVAR_' num2str(round(10*stdvarlim)) '_LAT_' num2str(latlim)],'png')
saveas(gcf,['stdSSSaqua_7days_vs_distance_' orb '_limVAR_' num2str(round(10*stdvarlim)) '_LAT_' num2str(latlim)],'fig')

tabd1=tabd/1000;
NN=6;
pp=polyfit(tabd1,dSSSrob_dd_norm,NN);
soltab=0.*tabd;
for ipp=1:NN
    soltab=soltab+pp(ipp)*tabd1.^(NN+1-ipp);
end
soltab=soltab+pp(NN+1);

figure
hold on
title(['Aqua normalized SSS error vs dcoast, abs(lat)<' num2str(latlim) ', stdvarlim=' num2str(stdvarlim)])
%plot(tabd,std_dd,'-')
plot(tabd,dSSSrob_dd_norm,'-')
plot(tabd,soltab,'r-')
grid on; legend('Aqua','model')
xlabel('dcoast (km)'); ylabel('normalized std diff');
hold off

saveas(gcf,['stdSSSaquaNORM_7days_vs_distance_' orb '_limVAR_' num2str(round(10*stdvarlim)) '_LAT_' num2str(latlim)],'png')
saveas(gcf,['stdSSSaquaNORM_7days_vs_distance_' orb '_limVAR_' num2str(round(10*stdvarlim)) '_LAT_' num2str(latlim)],'fig')



