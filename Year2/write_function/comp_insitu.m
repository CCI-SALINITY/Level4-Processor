% calcul des jacobiens des quantiles SSS ISAS pour le calcul de la correction absolue a
% partir des quantiles


%%%%%%%%%%%%%%%%
% ISAS monthly %
%%%%%%%%%%%%%%%%
load('isas_CATDS')     % chargement des donnees ISAS sur la periode 2012-2019 (SSS à 5m)
ind=find(datemois_isas(:,2)~=0);
datemois_isas=datemois_isas(ind,:);
ttisas=datenum(datemois_isas(:,2)+2000,datemois_isas(:,1),15+datemois_isas(:,1)*0);
isasSSS=isasSSS(ind,:,:);
isasPCTVAR=isasPCTVAR(ind,:,:);

%%%% calcul des quantiles ISAS avec ou sans bruit de 1 psu
isasSSStot=zeros(size(SSScorr,3),size(SSScorr,1),size(SSScorr,2));
isasPCTVARtot=zeros(size(SSScorr,3),size(SSScorr,1),size(SSScorr,2));
isasSSStotnoise=zeros(size(SSScorr,3),size(SSScorr,1),size(SSScorr,2));
smosSSStot=zeros(size(SSScorr,3),size(SSScorr,1),size(SSScorr,2));
for itt=1:length(ttdayJulian)
    [val ind]=min(abs(ttdayJulian(itt)-ttisas));
    isasSSStot(itt,:,:)=squeeze(isasSSS(ind,:,:));
    isasSSStotnoise(itt,:,:)=squeeze(isasSSS(ind,:,:))+randn(size(SSScorr,1),size(SSScorr,2));
end

%btot=zeros(4,nlo,nla);
indsel=find(isasPCTVARtot>seuilpctvar);
isasPCTVARsel=isasPCTVARtot;
isasPCTVARsel(indsel)=NaN;

NN=(isasPCTVARsel./isasPCTVARsel);
toto=squeeze(nansum(NN));
sssm=squeeze(nanstd(isasSSStot.*NN));
esssm=sssm./sqrt(toto);
%P=[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
% P=[0.5 0.6 0.7 0.8 0.9];
% Perr=[0.1 0.1 0.1 0.4 0.5];
P=[0.7 0.8 0.9];
Perr=[0.1 0.1 0.2];

aa = quantile(isasSSStot.*(isasPCTVARsel./isasPCTVARsel),P);
bb = quantile(isasSSStotnoise.*(isasPCTVARsel./isasPCTVARsel),P)-aa;
qs = quantile(smosSSStot.*(isasPCTVARsel./isasPCTVARsel),P)-aa;

% aa = quantile(isasSSStot,P);
% bb = quantile(isasSSStotnoise,P)-aa;
% qs = quantile(smosSSStot,P)-aa;
% Q=aa+bbxnoise = Qsmos-bs
% Qsmos-aa=bbxnoise+bs
% on cherche noise et bs
nqu=length(P);
%     Cdsmos=eye(nqu,nqu);  %*100.0;   % Cd^-1
%    for ii=1:nqu
%       Cdsmos(ii,ii)=1./(Perr(ii)*Perr(ii));
%    end

d00=ones(nqu,1);
bsmos=nan(nlo,nla);
ebsmos=nan(nlo,nla);
esmos=zeros(nlo,nla);
eesmos=zeros(nlo,nla);
for ilo=1:nlo
    ilo
    for ila=1:nla
        err2=esssm(ilo,ila).*esssm(ilo,ila);
        Cdsmos=eye(nqu,nqu)./err2;
        if isnan(bb(1,ilo,ila))==0
            bb0=bb(:,ilo,ila);
            qs0=qs(:,ilo,ila);
            G=[bb0,d00];
            matinv=inv(G'*Cdsmos*G);
            sol=matinv*(G'*Cdsmos*qs0);
            bsmos(ilo,ila)=sol(2);
            esmos(ilo,ila)=sol(1);   % si négatif alors prendre la médiane
            ebsmos(ilo,ila)=sqrt(sqrt(matinv(2,2)));
            eesmos(ilo,ila)=sqrt(sqrt(matinv(1,1)));
            %             else
            %                 bsmos(ilo,ila)=-1.5;
        end
    end
end


save('bsmos_70_80_90','bsmos','esmos','ebsmos','eesmos')

load('bsmos_70_80_90')

bsmosreg1=interp2(lat_fixgrid,lon_fixgrid,bsmos,la0,lo0);
btot(k,:,:)=bsmos;
esmosreg1=interp2(lat_fixgrid,lon_fixgrid,esmos,la0,lo0);

figure
subplot(2,3,1); hold on; title(['biais q7-9, pctvarlim=' num2str(seuilpctvar)])
imagesc(lonreg,latreg,bsmosreg1')
plot(long,lat,'k-')
axis([-179 179 -85 85]); caxis([-2 2]); colorbar; hold off
subplot(2,3,4); hold on; title('erreur q7-9')
imagesc(lonreg,latreg,esmosreg1')
plot(long,lat,'k-')
axis([-179 179 -85 85]);caxis([-0.2 0.6]); colorbar; hold off

load('bsmos')

bsmosreg=interp2(lat_fixgrid,lon_fixgrid,bsmos,la0,lo0);
btot(k,:,:)=bsmos;
esmosreg=interp2(lat_fixgrid,lon_fixgrid,esmos,la0,lo0);

subplot(2,3,2); hold on; title(['biais q5-9, pctvarlim=' num2str(seuilpctvar)])
imagesc(lonreg,latreg,bsmosreg')
plot(long,lat,'k-')
axis([-179 179 -85 85]); caxis([-2 2]); colorbar; hold off
subplot(2,3,5); hold on; title('erreur q5-9')
imagesc(lonreg,latreg,esmosreg')
plot(long,lat,'k-')
axis([-179 179 -85 85]);caxis([-0.2 0.6]); colorbar; hold off

subplot(2,3,3); hold on; title(['biais q7-9 - q5-9, pctvarlim=' num2str(seuilpctvar)])
imagesc(lonreg,latreg,bsmosreg1'-bsmosreg')
plot(long,lat,'k-')
axis([-179 179 -85 85]); caxis([-0.5 0.5]); colorbar; hold off
subplot(2,3,6); hold on; title('erreur q7-9 - q5-9')
imagesc(lonreg,latreg,esmosreg1'-esmosreg')
plot(long,lat,'k-')
axis([-179 179 -85 85]);caxis([-0.2 0.2]); colorbar; hold off



% figure
% subplot(2,2,1); hold on; title('bsmos');
% imagesc(bsmos'); caxis([-1.2 1.2]); colorbar; axis tight;  colorbar;
% hold off
% subplot(2,2,2); hold on; title('err bsmos');
% imagesc(ebsmos'); caxis([0. 0.3]); colorbar; axis tight; colorbar;
% hold off
% subplot(2,2,3); hold on; title('esmos');
% imagesc(esmos'); caxis([0. 1.2]); colorbar; axis tight; colorbar;
% hold off
% subplot(2,2,4); hold on; title('erreur esmos');
% imagesc(eesmos'); caxis([0. 1.2]); colorbar; axis tight; colorbar;
% hold off
%
%
% figure
% hold on
% imagesc(squeeze(btot(1,:,:)-btot(3,:,:))'); caxis([-0.2 0.2]); colorbar;
% hold off
%
% figure
% hold on
% title('biais (quantile 50%)')
% imagesc(squeeze(qs(1,:,:))'-squeeze(btot(2,:,:))')
% caxis([-.2 .2]); colorbar
% hold off
%
% bok=squeeze(btot(2,:,:));
% ind0=find(bok==0);
% b3=squeeze(btot(3,:,:));
% bok(ind0)=b3(ind0);
% ind0=find(bok==0);
% b4=squeeze(btot(4,:,:));
% bok(ind0)=b4(ind0);
%
% bok=squeeze(btot(4,:,:));
%
% figure
% hold on
% title('biais (quantile 50%)')
% imagesc(squeeze(qs(1,:,:))'-bok')
% caxis([-.2 .2]); colorbar
% hold off
%
%
% figure
% hold on
% title('biais (quantile 50%)')
% imagesc(squeeze(qs(1,:,:))'-squeeze(qs(4,:,:))')
% caxis([-.2 .2]); colorbar
% hold off
%
%
% %[X,Y,Z] = meshgrid(ttisas,lon_fixgrid,lat_fixgrid);
%
% indlat=find(lat_fixgrid>58);
%
% [X,Y,Z] = meshgrid(lon_fixgrid,ttisas,lat_fixgrid(indlat));
%
% sssinterp=interp3(X,Y,Z,isasSSS(:,:,indlat),loninsitu,timeinsitu,latinsitu);
%
% pctvarinterp=interp3(X,Y,Z,isasPCTVAR(:,:,indlat),loninsitu,timeinsitu,latinsitu);
%
% nlatsel=length(indlat);
%
% SSS0=zeros(891,1388,nlatsel);
% SSS1=zeros(891,1388,nlatsel);
% for itt=1:891
%     SSS0(itt,:,:)=SSScorr(:,indlat,itt);
% end
%
% SSS_quant50=zeros(891,1388,nlatsel);
% SSS_quant80=zeros(891,1388,nlatsel);
% SSSnewcorr=zeros(891,1388,nlatsel);
% for itt=1:891
%     SSS_quant50(itt,:,:)=SSScorr(:,indlat,itt)-SMOS_quant_tot(:,indlat,5);
%     SSS_quant80(itt,:,:)=SSScorr(:,indlat,itt)-SMOS_quant_tot(:,indlat,8);
%     SSSnewcorr(itt,:,:)=SSScorr(:,indlat,itt)-bsmos(:,indlat);
%    %  SSSnewcorr(itt,:,:)=SSScorr(:,indlat,itt)-bok(:,indlat);
% end
%
% [X,Y,Z] = meshgrid(lon_fixgrid,ttdayJulian,lat_fixgrid(indlat));
% sssinterpSMOS=interp3(X,Y,Z,SSS0,loninsitu,timeinsitu,latinsitu);
% sssinterpSMOS50=interp3(X,Y,Z,SSS_quant50,loninsitu,timeinsitu,latinsitu);
% sssinterpSMOS80=interp3(X,Y,Z,SSS_quant80,loninsitu,timeinsitu,latinsitu);
% sssinterpSMOSnew=interp3(X,Y,Z,SSSnewcorr,loninsitu,timeinsitu,latinsitu);
%
% dSSS=sssinterp-SSSinsitu;
% dSSSsmos=sssinterpSMOS-SSSinsitu;
% dSSSsmos50=sssinterpSMOS50-SSSinsitu;
% dSSSsmos80=sssinterpSMOS80-SSSinsitu;
% dSSSsmosnew=sssinterpSMOSnew-SSSinsitu;
%
% mSSS=nanmedian(dSSS)
% stdSSS=nanstd(dSSS)
% mSSSsmos=nanmedian(dSSSsmos)
% stdSSSsmos=nanstd(dSSSsmos)
% mSSSsmos50=nanmedian(dSSSsmos50)
% stdSSSsmos50=nanstd(dSSSsmos50)
% mSSSsmos80=nanmedian(dSSSsmos80)
% stdSSSsmos80=nanstd(dSSSsmos80)
% mSSSsmosnew=nanmedian(dSSSsmosnew)
% stdSSSsmosnew=nanstd(dSSSsmosnew)
%
% lat_reg=60:85;
% latmap=lat_reg(1:end-1)+0.5;
% nlatmap=length(latmap);
% nlat_reg=length(lat_reg);
% lon_reg=-180:180;
% lonmap=lon_reg(1:end-1)+0.5;
% nlonmap=length(lonmap);
% nlon_reg=length(lon_reg);
% dSSSmap=zeros(nlonmap,nlatmap);
% dSSSsmosmap=zeros(nlonmap,nlatmap);
% dSSSsmos50map=zeros(nlonmap,nlatmap);
% dSSSsmos80map=zeros(nlonmap,nlatmap);
% dSSSsmosnewmap=zeros(nlonmap,nlatmap);
% for ilat=1:(nlat_reg-1)
%     for ilon=1:(nlon_reg-1)
%         ind=find(latinsitu<lat_reg(ilat+1) & latinsitu>lat_reg(ilat) & loninsitu<lon_reg(ilon+1) & loninsitu>lon_reg(ilon));
%         dSSSmap(ilon,ilat)=nanmedian(dSSS(ind));
%         dSSSsmosmap(ilon,ilat)=nanmedian(dSSSsmos(ind));
%         dSSSsmos50map(ilon,ilat)=nanmedian(dSSSsmos50(ind));
%         dSSSsmos80map(ilon,ilat)=nanmedian(dSSSsmos80(ind));
%         dSSSsmosnewmap(ilon,ilat)=nanmedian(dSSSsmosnew(ind));
%     end
% end
%
% load coast
%
% figure
% subplot(2,2,1)
% hold on
% title('ISAS - in situ')
% imagesc(lonmap,latmap,dSSSmap')
% caxis([-3 2])
% colorbar
% plot(long,lat,'c-')
% axis([min(lonmap) max(lonmap) min(latmap) max(latmap)])
% hold off
% subplot(2,2,2)
% hold on
% title('SMOS nocorr - in situ')
% imagesc(lonmap,latmap,dSSSsmosmap')
% caxis([-3 2])
% colorbar
% plot(long,lat,'c-')
% axis([min(lonmap) max(lonmap) min(latmap) max(latmap)])
% hold off
% subplot(2,2,3)
% hold on
% title('SMOS q50 - in situ')
% imagesc(lonmap,latmap,dSSSsmos50map')
% caxis([-3 2])
% colorbar
% plot(long,lat,'c-')
% axis([min(lonmap) max(lonmap) min(latmap) max(latmap)])
% hold off
% subplot(2,2,4)
% hold on
% title('SMOS q80 - in situ')
% imagesc(lonmap,latmap,dSSSsmos80map')
% caxis([-3 2])
% colorbar
% plot(long,lat,'c-')
% axis([min(lonmap) max(lonmap) min(latmap) max(latmap)])
% hold off
%
% figure
% hold on
% title('SMOS new - in situ')
% imagesc(lonmap,latmap,dSSSsmosnewmap')
% caxis([-3 2])
% colorbar
% plot(long,lat,'c-')
% axis([min(lonmap) max(lonmap) min(latmap) max(latmap)])
% hold off
%
% saveas(gcf,'mapSSSisas_smos_insitu','png')
%
% clear isasSSS
%
% figure
% subplot(2,1,1)
% hold on
% title('SSS in-situ vs ISAS')
% plot(sssinterp,SSSinsitu,'.')
% axis([20 37 20 37])
% grid on
% xlabel('SSS ISAS')
% ylabel('SSS in-situ')
% hold off
% subplot(2,1,2)
% hold on
% title('SSS in-situ vs SMOS')
% plot(sssinterpSMOS,SSSinsitu,'.')
% axis([20 37 20 37])
% grid on
% xlabel('SSS SMOS')
% ylabel('SSS in-situ')
% hold off
%
% saveas(gcf,'ISAS_insitu','png')
%
%
% figure
% subplot(2,1,1)
% hold on
% title(['mean/std diff SSS=' num2str(nanmedian(sssinterp-SSSinsitu),3.2) '/' num2str(nanstd(sssinterp-SSSinsitu),3.2)])
% histogram(sssinterp-SSSinsitu,[-4:0.2:4])
% grid on
% ylabel('#')
% xlabel('SSS ISAS-SSS in-situ')
% hold off
%
% indpctvar=find(pctvarinterp<70);
% subplot(2,1,2)
% hold on
% title(['mean/std diff SSS=' num2str(nanmedian(sssinterp(indpctvar)-SSSinsitu(indpctvar)),3.2) '/' num2str(nanstd(sssinterp(indpctvar)-SSSinsitu(indpctvar)),3.2)])
% histogram(sssinterp(indpctvar)-SSSinsitu(indpctvar),[-4:0.2:4])
% grid on
% ylabel('#')
% xlabel('SSS ISAS (PCTVAR<70) -SSS in-situ')
% hold off
%
% saveas(gcf,'histo_ISAS_PCTVAR70_insitu','png')
%
% % calcul des courbes de biais SMOS vs InSitu et ISAS Insitu en fonction du
% % PCTVAR et du quantile
% SMOS_PCTVAR
%
%
% % application du quantile à 50% seulement si la distribution SMOS est symétrique.
%
% symSMOS=quantSMOS_tot;
% %d1=squeeze(reshape(abs(2*quantSMOS_tot(:,:,5)-quantSMOS_tot(:,:,3)-quantSMOS_tot(:,:,7)),nlo*nla,1));
% indNaN=find(quantSMOS_tot<1);
% quantSMOS_tot(indNaN)=NaN;
% d1=squeeze((2*quantSMOS_tot(:,:,5)-quantSMOS_tot(:,:,3)-quantSMOS_tot(:,:,7)));
%
% d1reg=interp2(lat_fixgrid,lon_fixgrid,d1,la0,lo0);
% figure; hold on; title('SMOS (q50-q30)-(q70-q50)'); imagesc(lonreg,latreg,d1reg'); axis tight; caxis([-0.1 1]); colorbar; hold off
%
% d2=squeeze((2*quantSMOS_tot(:,:,5)-quantSMOS_tot(:,:,2)-quantSMOS_tot(:,:,8)));
% d2reg=interp2(lat_fixgrid,lon_fixgrid,d2,la0,lo0);
% figure; hold on; title('SMOS (q50-q20)-(q80-q50)'); imagesc(lonreg,latreg,d2reg'); axis tight; caxis([-0.1 1]); colorbar; hold off
%
% % exemple Amazone
% qq=squeeze(quantSMOS_tot(494,332,:))
%
% quantISAS_tot(indNaN)=NaN;
% d1isas=squeeze((2*quantISAS_tot(:,:,5)-quantISAS_tot(:,:,3)-quantISAS_tot(:,:,7)));
% figure; hold on; title('ISAS (q50-q30)-(q70-q50)'); imagesc(d1isas'); caxis([-0.1 1]); colorbar; hold off
%
% d2isas=squeeze((2*quantISAS_tot(:,:,5)-quantISAS_tot(:,:,2)-quantISAS_tot(:,:,8)));
% figure; hold on; title('ISAS (q50-q20)-(q80-q50)'); imagesc(d2isas'); caxis([-0.1 1]); colorbar; hold off
%
% % exemple Arctic
% qq=squeeze(quantISAS_tot(1220,580,:))
%

