% program for latitudinal bias estimation for SMOS data
% input     : monthly SMOS files (from plots_avec_filtre_SST) produced by
% L3OS_moyenne_main_xswath_SSS_SST_v4.m
% output    : mat files
% date : 06/2019 (CCI+SSS year 1 project)
% author : JLV, ACRI-ST

clear


% utilisation des fichiers mensuels sous plots
set(groot,'DefaultFigureColormap',jet)

dirres='plot_biais_sans_filtre_SST_moyenne_2_corrSST_Atlan_v4/';
if exist(dirres)==0; mkdir(dirres); end;

load('../../isas_CATDS.mat')


load('../../maskdmin_ease2');
% dmin=squeeze(reshape(dmin,1388*584,1));
dmaxmasque=600;
indsel=find(dmin<dmaxmasque);
masquecote=dmin*0;
masquecote(indsel)=1;  % contamination cotiere si == 1

% EASE grid
NlatDGG=length(lat_fixgrid);
NlonDGG=length(lon_fixgrid);
[lat0, lon0]=meshgrid(lat_fixgrid, lon_fixgrid);

% selection des zones à traiter
% tests sur le pacifique
lonmin_tab=[-180 -80 30];
lonmax_tab=[-80 30 130];
nameR=['Pac'; 'Atl' ; 'Ind'];
Nzon=length(lonmin_tab);
izon=2;  % seulement une zone globale pour monter aux plus hautes latitudes

xswathmax=487.5;
pasxswath=25;
xswath_tab=-xswathmax:pasxswath:xswathmax;
ff=xswath_tab(1:end-1)+12.5;

conf.dmaxmasque=dmaxmasque;
conf.xswathmax=xswathmax;
conf.pasxswath=pasxswath;
conf.xswath_tab=xswath_tab;
conf.ff=ff;


SSSmedianA1=zeros(8,12,length(xswath_tab)-1,NlatDGG);
SSSmedianD1=zeros(8,12,length(xswath_tab)-1,NlatDGG);
SSTmedianA1=zeros(8,12,length(xswath_tab)-1,NlatDGG);
SSTmedianD1=zeros(8,12,length(xswath_tab)-1,NlatDGG);

SSSstdA=zeros(8,12,length(xswath_tab)-1,NlatDGG);
SSSstdD=zeros(8,12,length(xswath_tab)-1,NlatDGG);
SSSstd1A=zeros(8,12,length(xswath_tab)-1,NlatDGG);
SSSstd1D=zeros(8,12,length(xswath_tab)-1,NlatDGG);

SSSmedianISAS=zeros(8,12,length(xswath_tab)-1,NlatDGG);
SSSmedianISAS80=zeros(8,12,length(xswath_tab)-1,NlatDGG);

lonmin=lonmin_tab(izon);  % izon=1,Pacific; izon=2,Atlan
lonmax=lonmax_tab(izon);
% indsel=find(masquecote==0);
%indnosel=find(masquecote==1 | (lon0>lonmin & lon0<lonmax & lat0 > 45));  % on supprime le Pacifique Nord où ISAS n'est pas bon
indnosel=find(masquecote==1 | ((lon0<lonmin | lon0>lonmax) & lat0 >-30));

for ifilt=1:(length(xswath_tab)-1)
    xswathmin=xswath_tab(ifilt); xswathmax=xswath_tab(ifilt+1);
  %  dirmens=['../plots_avec_sans_filtre_SST/plots_sans_filtre_' num2str(abs(xswathmin)) '_' num2str(abs(xswathmax)) '/'];
    dirmens=['../plots_avec_filtre_SST/plots_filtreAcard_' num2str(abs(xswathmin)) '_' num2str(abs(xswathmax)) '/'];

    ifilt
    
    for imo=1:12
        for iy=1:8
            year0=2010+iy;
            if imo<10
                monc=['0' num2str(imo)];
            else
                monc=num2str(imo);
            end
            
            indisas=find(imo==datemois_isas(:,1) & year0==(datemois_isas(:,2)+2000));
            mapisas=squeeze(isasSSS(indisas,:,:));
            mapisas(indnosel)=NaN;
            
            isaspctvar=squeeze(isasPCTVAR(indisas,:,:));
            indpctvar=find(isaspctvar>80);  % on exclue les forts PCTVAR
            mapisas80=mapisas;
            mapisas80(indpctvar)=NaN;
            
            datename=['SSS_dist_50_orb_A_date_201' num2str(iy)  monc];
            load([dirmens datename '.mat'])
            
            meanSSSmap1=meanSSSmap;
            meanSSSmap1(indnosel)=NaN;
            SSSmapA=meanSSSmap1;
            SSTmapA=meanSSTmap;    % (Nlon,Nlat)
            
           % déjà corrigé et avec Dinnat 2018, sigSST=0.6
           % indSSTc=find(SSTmapA<8.5);
           % biais=0.0136.*SSTmapA.^2-0.2553.*SSTmapA+1.1874;
           % SSSmapA(indSSTc)=SSSmapA(indSSTc)-biais(indSSTc);  % KS induit des SSS trop élevées. Il faut soustraire le biais
            
            datename=['SSS_dist_50_orb_D_date_201' num2str(iy)  monc];
            load([dirmens datename '.mat'])
            
            meanSSSmap1=meanSSSmap;
            meanSSSmap1(indnosel)=NaN;
            SSSmapD=meanSSSmap1;
            SSTmapD=meanSSTmap;
            
%             indSSTc=find(SSTmapD<8.5);
%             biais=0.0136.*SSTmapD.^2-0.2553.*SSTmapD+1.1874;
%             SSSmapD(indSSTc)=SSSmapD(indSSTc)-biais(indSSTc);
            
            nmA=nanmedian(SSSmapA);
            nmD=nanmedian(SSSmapD);
            
            SSSmedianA1(iy,imo,ifilt,:)=nmA;
            SSSmedianD1(iy,imo,ifilt,:)=nmD;
            SSTmedianA1(iy,imo,ifilt,:)=nanmedian(SSTmapA);
            SSTmedianD1(iy,imo,ifilt,:)=nanmedian(SSTmapD);
            SSSmedianISAS(iy,imo,ifilt,:)=nanmedian(mapisas);
            SSSmedianISAS80(iy,imo,ifilt,:)=nanmedian(mapisas80);
            
            SSSstdA(iy,imo,ifilt,:)=nanstd(SSSmapA);
            SSSstdD(iy,imo,ifilt,:)=nanstd(SSSmapD);
            SSSstd1A(iy,imo,ifilt,:)=nanmedian(abs(SSSmapA-repmat(nmA,1388,1)))/0.6745;
            SSSstd1D(iy,imo,ifilt,:)=nanmedian(abs(SSSmapD-repmat(nmD,1388,1)))/0.6745;
        end
    end
end

save([dirres 'data_std_biais_filtreAcard_SST.mat'],'conf','SSSmedianA1','SSSmedianD1','SSTmedianA1','SSTmedianD1','SSSmedianISAS','SSSmedianISAS80','lat_fixgrid','SSSstdA','SSSstdD','SSSstd1A','SSSstd1D')


%load([dirres 'data_std_biais_filtreAcard_SST.mat'])

% STD mini qui permet ensuite de sélectionner les bonnes années pour chaque dwell et chaque mois.

xswath_tab=conf.xswath_tab;
NlatDGG=length(lat_fixgrid);
ndw=2*(length(xswath_tab)-1);
SSSmedsel=zeros(12,ndw,NlatDGG);
SSSmedISASsel=zeros(12,ndw,NlatDGG);
SSTmedsel=zeros(12,ndw,NlatDGG);
SSSstdsel=zeros(12,ndw,NlatDGG);

yearsel=zeros(12,ndw,NlatDGG);

plot_fig=0;

limNorth=45;
limSouth=-45;
indm45=find(lat_fixgrid<limSouth);
indm45_0=find(lat_fixgrid>=limSouth & lat_fixgrid<0);
ind0_p45=find(lat_fixgrid>=0 & lat_fixgrid<limNorth);
indp45=find(lat_fixgrid>limNorth);
meandSSSmin=zeros(12,4);
meandSSSmin80=zeros(12,4);
inddwell=zeros(12,4);
inddwell80=zeros(12,4);

corrSSS=zeros(12,78,NlatDGG);
corrSSS_SST=zeros(12,78,NlatDGG);
corrSSS80=zeros(12,78,NlatDGG);
corrSSS_SST80=zeros(12,78,NlatDGG);

corrSSS_smooth=zeros(12,78,NlatDGG);
corrSSS_SST_smooth=zeros(12,78,NlatDGG);
corrSSS_smooth80=zeros(12,78,NlatDGG);
corrSSS_SST_smooth80=zeros(12,78,NlatDGG);


SSS_ref=zeros(12,NlatDGG);
SST_ref=zeros(12,NlatDGG);
SSS_ref80=zeros(12,NlatDGG);
SST_ref80=zeros(12,NlatDGG);
SSS_isas=zeros(12,NlatDGG);
SSS_isas80=zeros(12,NlatDGG);

for imo=1:12
    imo
    dSSS0=[squeeze((SSSmedianA1(2:end,imo,:,:)-SSSmedianISAS(2:end,imo,:,:))) squeeze((SSSmedianD1(2:end,imo,:,:)-SSSmedianISAS(2:end,imo,:,:)))];
    dSSS=[squeeze(abs(SSSmedianA1(2:end,imo,:,:)-SSSmedianISAS(2:end,imo,:,:))) squeeze(abs(SSSmedianD1(2:end,imo,:,:)-SSSmedianISAS(2:end,imo,:,:)))];  % on ne prend pas 2011
    dSSS80=[squeeze(abs(SSSmedianA1(2:end,imo,:,:)-SSSmedianISAS80(2:end,imo,:,:))) squeeze(abs(SSSmedianD1(2:end,imo,:,:)-SSSmedianISAS80(2:end,imo,:,:)))];  % on ne prend pas 2011
    
    SSSm=squeeze(nanmedian([squeeze(SSSmedianA1(2:end,imo,:,:)) squeeze(SSSmedianD1(2:end,imo,:,:))]));
    dSSSm=squeeze(nanmedian(dSSS));  % mediane sur les annees
    dSSSm80=squeeze(nanmedian(dSSS80));
    SSSisas=squeeze(nanmedian([squeeze((SSSmedianISAS(2:end,imo,:,:))) squeeze((SSSmedianISAS(2:end,imo,:,:)))]));
    SSSisas80=squeeze(nanmedian([squeeze((SSSmedianISAS80(2:end,imo,:,:))) squeeze((SSSmedianISAS80(2:end,imo,:,:)))]));
    
    dSSSmin=squeeze(nanmin(dSSS));
    dSSSmin80=squeeze(nanmin(dSSS80));
    dSSSstd=squeeze(nanstd(dSSS0));
    SSTm=squeeze(nanmedian([squeeze(SSTmedianA1(2:end,imo,:,:)) squeeze(SSTmedianD1(2:end,imo,:,:))]));
    
    [meandSSSmin(imo,1) inddwell(imo,1)]=min(nanmean(dSSSmin(:,indm45),2));
    [meandSSSmin(imo,2) inddwell(imo,2)]=min(nanmean(dSSSmin(:,indm45_0),2));
    [meandSSSmin(imo,3) inddwell(imo,3)]=min(nanmean(dSSSmin(:,ind0_p45),2));
    [meandSSSmin(imo,4) inddwell(imo,4)]=min(nanmean(dSSSmin(:,indp45),2));
 
    [meandSSSmin80(imo,1) inddwell80(imo,1)]=min(nanmean(dSSSmin80(:,indm45),2));
    [meandSSSmin80(imo,2) inddwell80(imo,2)]=min(nanmean(dSSSmin80(:,indm45_0),2));
    [meandSSSmin80(imo,3) inddwell80(imo,3)]=min(nanmean(dSSSmin80(:,ind0_p45),2));
    [meandSSSmin80(imo,4) inddwell80(imo,4)]=min(nanmean(dSSSmin80(:,indp45),2));
    
    SSS_ref(imo,indm45)=SSSm(inddwell(imo,1),indm45);
    SSS_ref(imo,indm45_0)=SSSm(inddwell(imo,2),indm45_0);
    SSS_ref(imo,ind0_p45)=SSSm(inddwell(imo,3),ind0_p45);
    SSS_ref(imo,indp45)=SSSm(inddwell(imo,4),indp45);
    SSS_ref80(imo,indm45)=SSSm(inddwell80(imo,1),indm45);
    SSS_ref80(imo,indm45_0)=SSSm(inddwell80(imo,2),indm45_0);
    SSS_ref80(imo,ind0_p45)=SSSm(inddwell80(imo,3),ind0_p45);
    SSS_ref80(imo,indp45)=SSSm(inddwell80(imo,4),indp45);
    
    SSS_isas(imo,indm45)=SSSisas(inddwell(imo,1),indm45);
    SSS_isas(imo,indm45_0)=SSSisas(inddwell(imo,2),indm45_0);
    SSS_isas(imo,ind0_p45)=SSSisas(inddwell(imo,3),ind0_p45);
    SSS_isas(imo,indp45)=SSSisas(inddwell(imo,4),indp45);
    SSS_isas80(imo,indm45)=SSSisas80(inddwell80(imo,1),indm45);
    SSS_isas80(imo,indm45_0)=SSSisas80(inddwell80(imo,2),indm45_0);
    SSS_isas80(imo,ind0_p45)=SSSisas80(inddwell80(imo,3),ind0_p45);
    SSS_isas80(imo,indp45)=SSSisas80(inddwell80(imo,4),indp45);
   
    [dSSS_ref0 inddwell0]=min(dSSSmin(:,:));
    SSS_ref0=diag(SSSm(inddwell0,:))';
    SSS_ref(imo,:)=diag(SSSm(inddwell0,:));   % la "vraie" SSS, indépendante de la SST
    SST_ref0=diag(SSTm(inddwell0,:))';
    SST_ref(imo,:)=SST_ref0;
    
    [dSSS_ref080 inddwell080]=min(dSSSmin80(:,:));
    SSS_ref080=diag(SSSm(inddwell080,:))';
    SSS_ref80(imo,:)=diag(SSSm(inddwell080,:));   % la "vraie" SSS, indépendante de la SST
    SST_ref080=diag(SSTm(inddwell080,:))';
    SST_ref80(imo,:)=SST_ref080;
   
    
    corrSSS(imo,:,:)=repmat(SSS_ref0,ndw,1)-SSSm;  % reference - smos. La SSS smos est observee a SSTm , donc le biais est donné à SSTm
    corrSSS80(imo,:,:)=repmat(SSS_ref080,ndw,1)-SSSm;  % reference - smos. La SSS smos est observee a SSTm , donc le biais est donné à SSTm
   
    corrSSS_SST(imo,:,:)=(repmat(SSS_ref0,ndw,1)-SSSm).*((0.015*SSTm+0.25)./(0.015*repmat(SST_ref0,ndw,1)+0.25));  % On donne le biais à SSTref
    corrSSS_SST80(imo,:,:)=(repmat(SSS_ref080,ndw,1)-SSSm).*((0.015*SSTm+0.25)./(0.015*repmat(SST_ref080,ndw,1)+0.25));  % On donne le biais à SSTref

end

% lissage de la correction
[lat0 lat1]=meshgrid(lat_fixgrid, lat_fixgrid);


% conf1
xi2=200;
errdata2=4;
maxSSS=2;
minSSS=-3;

% conf2
xi2=100;
errdata2=1;
maxSSS=5;
minSSS=-5;

Corrxi=exp(-(lat0-lat1).^2/xi2);
%Cd=eye(NlatDGG)*errdata2;
vec0=ones(NlatDGG,1)*errdata2;

indNaN=find(isnan(corrSSS));
corrSSS(indNaN)=0;
inds=find(corrSSS>maxSSS);
corrSSS(inds)=maxSSS;
inds=find(corrSSS<minSSS);
corrSSS(inds)=minSSS;
indNaN=find(isnan(corrSSS_SST));
corrSSS_SST(indNaN)=0;
inds=find(corrSSS_SST>maxSSS);
corrSSS_SST(inds)=maxSSS;
inds=find(corrSSS_SST<minSSS);
corrSSS_SST(inds)=minSSS;

indNaN=find(isnan(corrSSS80));
corrSSS80(indNaN)=0;
inds=find(corrSSS80>maxSSS);
corrSSS80(inds)=maxSSS;
inds=find(corrSSS80<minSSS);
corrSSS80(inds)=minSSS;
indNaN=find(isnan(corrSSS_SST80));
corrSSS_SST80(indNaN)=0;
inds=find(corrSSS_SST80>maxSSS);
corrSSS_SST80(inds)=maxSSS;
inds=find(corrSSS_SST80<minSSS);
corrSSS_SST80(inds)=minSSS;


for imo=1:12
    imo
    for idw=1:78
        data1=squeeze(corrSSS(imo,idw,:))';
        ind=find(data1==0);
        vecd=vec0;
       % vecd(ind)=4;
        Cd=diag(vecd);
        pp1=Corrxi*((Corrxi+Cd)\data1');
        corrSSS_smooth(imo,idw,:)=pp1';
    
        data1=squeeze(corrSSS_SST(imo,idw,:))';
        ind=find(data1==0);
        vecd=vec0;
      %  vecd(ind)=4;
        Cd=diag(vecd);
        pp1=Corrxi*((Corrxi+Cd)\data1');
        corrSSS_SST_smooth(imo,idw,:)=pp1';
    
        data1=squeeze(corrSSS80(imo,idw,:))';
        ind=find(data1==0);
        vecd=vec0;
      %  vecd(ind)=4;
        Cd=diag(vecd);
        pp1=Corrxi*((Corrxi+Cd)\data1');
        corrSSS_smooth80(imo,idw,:)=pp1';
    
        data1=squeeze(corrSSS_SST80(imo,idw,:))';
        ind=find(data1==0);
        vecd=vec0;
     %   vecd(ind)=4;
        Cd=diag(vecd);
        pp1=Corrxi*((Corrxi+Cd)\data1');
        corrSSS_SST_smooth80(imo,idw,:)=pp1';
    end
    
    figure
    hold on
    title(['corrSSS smooth pctvar<80, month=' num2str(imo)])
    imagesc(squeeze(corrSSS_smooth80(imo,:,:))'); axis xy; caxis([-2 2]); colorbar
    hold off
    
    saveas(gcf,[dirres 'CorrSSS_' num2str(imo) '_pctvar_80'],'png')
    
    figure
    hold on
    title(['corrSSS smooth, month=' num2str(imo)])
    imagesc(squeeze(corrSSS_smooth(imo,:,:))'); axis xy; caxis([-2 2]); colorbar
    hold off
    
    saveas(gcf,[dirres 'CorrSSS_' num2str(imo)],'png')
end

save([dirres 'corrSSS'],'SST_ref','corrSSS','corrSSS_smooth','corrSSS_smooth80','corrSSS_SST_smooth','ff','lat_fixgrid')

imo=12;
figure
subplot(3,1,1)
hold on
plot(squeeze(corrSSS(imo,:,:))')
grid on
hold off
subplot(3,1,2)
hold on
plot(squeeze(corrSSS_smooth(imo,:,:))')
grid on
hold off
subplot(3,1,3)
hold on
plot(squeeze(corrSSS_smooth80(imo,:,:))')
grid on
hold off

figure
hold on
plot(lat_fixgrid,SSS_ref'-SSS_isas')
axis([-90 90 -2 2])
grid on
hold off

figure
hold on
title(['corrSSS_smooth - corrSSS_SST smooth, month=' num2str(imo)])
imagesc(squeeze(corrSSS_smooth(imo,:,:)-corrSSS_SST_smooth(imo,:,:))'); axis xy; caxis([-0.1 0.1]); colorbar
hold off

figure
subplot(2,1,1)
hold on
title(['median(abs(smos-isas)), m=' num2str(imo)])
imagesc(meandSSSmin); axis tight; caxis([0 0.7]); colorbar;
hold off

subplot(2,1,2)
hold on
title(['ind dwell, m=' num2str(imo)])
imagesc(inddwell); axis tight; caxis([0 78]); colorbar;
hold off
