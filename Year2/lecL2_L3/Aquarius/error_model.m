% modèle d'erreur
clear

set(groot,'DefaultFigureColormap',jet)

plot_fig=1;
limxy.xmin=-3; limxy.xmax=32;
limxy.ymin=-4; limxy.ymax=4;
limxy.facm=20;


year0=2013;

% dires
dires=['plot_' num2str(year0) '_v3\'];
if exist(dires)==0; mkdir(dires); end;

% chargement ISAS
load('G:\dataSMOS\CATDS\repro_2017\correction_biais\isas_CATDS')
yearisas=datemois_isas(:,2);
moisisas=datemois_isas(:,1);

% chargement de la grille EASE
nlon=length(lon_fixgrid);
nlat=length(lat_fixgrid);

% lecture des fichiers journaliers

pathfile='I:\Aquarius_data\RSS\L2\file_mat\';
dirfile=dir(pathfile);

nfil=200;

mapSSS1A=NaN(nfil,nlon,nlat); % beam 1, asc
mapSSS1D=NaN(nfil,nlon,nlat); % beam 1, desc
mapSSS2A=NaN(nfil,nlon,nlat); % beam 2, asc
mapSSS2D=NaN(nfil,nlon,nlat); % beam 2, desc
mapSSS3A=NaN(nfil,nlon,nlat); % beam 3, asc
mapSSS3D=NaN(nfil,nlon,nlat); % beam 3, desc

% erreur Aquarius
mapeSSS1A=NaN(nfil,nlon,nlat); % beam 1, asc
mapeSSS1D=NaN(nfil,nlon,nlat); % beam 1, desc
mapeSSS2A=NaN(nfil,nlon,nlat); % beam 2, asc
mapeSSS2D=NaN(nfil,nlon,nlat); % beam 2, desc
mapeSSS3A=NaN(nfil,nlon,nlat); % beam 3, asc
mapeSSS3D=NaN(nfil,nlon,nlat); % beam 3, desc


mapSSTA=NaN(nfil,nlon,nlat);
mapSSTD=NaN(nfil,nlon,nlat);
mapISAS=NaN(nfil,nlon,nlat);

kA=0; kD=0;
for ifi=3:200
    ifi
    namefile=dirfile(ifi).name;
    
    namefile(5)='A';
    pathnamefile=[pathfile namefile];
    load(pathnamefile);    % 'SSSA','SSTA','WSA','tSSSA','eSSSA','SSSargoA','beamA'
    
    kA=kA+1;
    ind=find(beamA==1);
    SSS1=SSSA+NaN;
    SSS1(ind)=SSSA(ind);
    mapSSS1A(kA,:,:)=SSS1;
    eSSS1=eSSSA+NaN;
    eSSS1(ind)=eSSSA(ind);
    mapeSSS1A(kA,:,:)=eSSS1;
    
    ind=find(beamA==2);
    SSS1=SSSA+NaN;
    SSS1(ind)=SSSA(ind);
    mapSSS2A(kA,:,:)=SSS1;
    eSSS1=eSSSA+NaN;
    eSSS1(ind)=eSSSA(ind);
    mapeSSS2A(kA,:,:)=eSSS1;
    
    ind=find(beamA==3);
    SSS1=SSSA+NaN;
    SSS1(ind)=SSSA(ind);
    mapSSS3A(kA,:,:)=SSS1;
    eSSS1=eSSSA+NaN;
    eSSS1(ind)=eSSSA(ind);
    mapeSSS3A(kA,:,:)=eSSS1;
    
    mapSSTA(kA,:,:)=SSTA;
    dayA(kA)=str2num(namefile(13:14));
    monA(kA)=str2num(namefile(11:12));
    
    namefile(5)='D';
    pathnamefile=[pathfile namefile];
    load(pathnamefile);
    
    kD=kD+1;
    
    ind=find(beamD==1);
    SSS1=SSSD+NaN;
    SSS1(ind)=SSSD(ind);
    mapSSS1D(kD,:,:)=SSS1;
    eSSS1=eSSSD+NaN;
    eSSS1(ind)=eSSSD(ind);
    mapeSSS1D(kD,:,:)=eSSS1;
    
    ind=find(beamD==2);
    SSS1=SSSD+NaN;
    SSS1(ind)=SSSD(ind);
    mapSSS2D(kD,:,:)=SSS1;
    eSSS1=eSSSD+NaN;
    eSSS1(ind)=eSSSD(ind);
    mapeSSS2D(kD,:,:)=eSSS1;
    
    ind=find(beamD==3);
    SSS1=SSSD+NaN;
    SSS1(ind)=SSSD(ind);
    mapSSS3D(kD,:,:)=SSS1;
    eSSS1=eSSSD+NaN;
    eSSS1(ind)=eSSSD(ind);
    mapeSSS3D(kD,:,:)=eSSS1;
    
    dayD(kD)=str2num(namefile(13:14));
    monD(kD)=str2num(namefile(11:12));
    
    fmonth=monD(kD);
    fyear=str2num(namefile(9:10));
    indisas=find(fyear==yearisas & fmonth==moisisas);
    mapISAS0=squeeze(isasSSS(indisas,:,:));
    
    % mapISAS1=interp2(lon_fixgrid,lat_fixgrid,mapISAS0',lon1,lat1);
    mapISAS(kD,:,:)=mapISAS0;
    
end

% keyboard
% comparaison asc-desc jour par jour

for beam=1:3;
    it=1:180;
    lit=length(it);
    if beam==1
        mapSSS1=mapSSS1A(it,:,:);
        mapSSS2=mapSSS1D(it,:,:);
        mapeSSS1=mapeSSS1A(it,:,:);
        mapeSSS2=mapeSSS1D(it,:,:);
    elseif beam==2
        mapSSS1=mapSSS2A(it,:,:);
        mapSSS2=mapSSS2D(it,:,:);
        mapeSSS1=mapeSSS2A(it,:,:);
        mapeSSS2=mapeSSS2D(it,:,:);
    else
        mapSSS1=mapSSS3A(it,:,:);
        mapSSS2=mapSSS3D(it,:,:);
        mapeSSS1=mapeSSS3A(it,:,:);
        mapeSSS2=mapeSSS3D(it,:,:);
    end
    
    mapSST1=mapSSTA(it,:,:);
    mapISAS1=mapISAS(it,:,:);
    
    indok=find(isnan(mapSSS1)==0 & isnan(mapSSS2)==0);
    SSTA=mapSST1(indok)-273.15;
    dSSSA=mapSSS1(indok)-mapSSS2(indok);
    dSSS1isas=mapSSS1(indok)-mapISAS1(indok);
    dSSS2isas=mapSSS2(indok)-mapISAS1(indok);
    eSSS1=mapeSSS1(indok);
    eSSS2=mapeSSS2(indok);
    
    diffSSSok=dSSSA;
    SSTok=SSTA;
    
    dSST=1.;
    SST0=-2:30;
    sigSSS=0*SST0;
    sigSSS1=0*SST0;
    sigSSS2=0*SST0;
    diffSSS1=0*SST0;
    diffSSS2=0*SST0;
    diffSSS=0*SST0;
    sigrobSSS=0*SST0;
    sigrobSSS1=0*SST0;
    sigrobSSS2=0*SST0;
    sigaquaSSS1=0*SST0;
    sigaquaSSS2=0*SST0;
    
    for ii=1:length(SST0)
        ind1=find( SSTok<SST0(ii)+dSST & SSTok>SST0(ii)-dSST);
        sigSSS(ii)=nanstd(diffSSSok(ind1))/sqrt(2);
        sigSSS1(ii)=nanstd(dSSS1isas(ind1));
        sigSSS2(ii)=nanstd(dSSS2isas(ind1));
                
        diffSSS(ii)=nanmedian(diffSSSok(ind1));
        diffSSS1(ii)=nanmedian(dSSS1isas(ind1));
        diffSSS2(ii)=nanmedian(dSSS2isas(ind1));
        sigrobSSS(ii)=nanmedian(abs(diffSSSok(ind1)-diffSSS(ii)))/0.6745;
        sigrobSSS1(ii)=nanmedian(abs(dSSS1isas(ind1)-diffSSS1(ii)))/0.6745;
        sigrobSSS2(ii)=nanmedian(abs(dSSS2isas(ind1)-diffSSS2(ii)))/0.6745;
        
        sigaquaSSS1(ii)=nanmedian(eSSS1(ind1));
        sigaquaSSS2(ii)=nanmedian(eSSS2(ind1));
    end
    
    [p, s]=polyfit(SST0,sigSSS,2);
    sigtheo=p(1)*SST0.*SST0+p(2)*SST0+p(3);
    
    [p, s]=polyfit(SST0,diffSSS1,2);
    sigtheo2=p(1)*SST0.*SST0+p(2)*SST0+p(3);
    
    [p, s]=polyfit(SST0,diffSSS2,2);
    sigtheo3=p(1)*SST0.*SST0+p(2)*SST0+p(3);
    
    sig_theo=0.2./(0.015.*SST0+0.25);
    
    if plot_fig==1
        
 
        [Nr,xr,yr,C] = densityplot(SSTA,dSSSA,limxy);
        
        figure
        hold on
        title(['A-D, beam' num2str(beam)])
        imagesc(xr,yr,Nr')
        plot(SST0,sigrobSSS,'k-','Linewidth',2)
        plot(SST0,diffSSS,'g-','Linewidth',2)  % moyenne
        plot(SST0,sigaquaSSS1,'c-','Linewidth',2)
        plot(SST0,sig_theo,'r--','Linewidth',2)
        axis([-2 30 -2 2])
        grid on
        xlabel('SST')
        ylabel('diffSSS & sigdiff/\surd{2}')
        legend('std','mean','std aqua','theory with \Delta TB ~ 0.2K')
        hold off
        
        saveas(gcf,[dires 'beam' num2str(beam) '_errorSSS_SST_AminusD_' num2str(min(it)) '_' num2str(max(it))],'png')
        saveas(gcf,[dires 'beam' num2str(beam) '_errorSSS_SST_AminusD_' num2str(min(it)) '_' num2str(max(it))],'fig')
       
        [Nr,xr,yr,C] = densityplot(SSTA,dSSS1isas,limxy);
        figure
        subplot(2,1,1)
        hold on
        title(['A beam' num2str(beam) ' - ISAS'])
        imagesc(xr,yr,Nr')
        plot(SST0,sigrobSSS1,'k-','Linewidth',2) % std
        plot(SST0,diffSSS1,'g-','Linewidth',2)  % moyenne
        plot(SST0,sigaquaSSS1,'c-','Linewidth',2) % median de la std aqua
        plot(SST0,sig_theo,'r--','Linewidth',2) % theory
        axis([-2 30 -2 2])
        grid on
        xlabel('SST')
        ylabel('diffSSS & sigdiff')
        legend('std','mean','std aqua','theory with \Delta TB ~ 0.2K')
        hold off
        [Nr,xr,yr,C] = densityplot(SSTA,dSSS2isas,limxy);
        subplot(2,1,2)
        hold on
        title(['D beam' num2str(beam) ' - ISAS'])
        imagesc(xr,yr,Nr')
        plot(SST0,sigrobSSS2,'k-','Linewidth',2)
        plot(SST0,diffSSS2,'g-','Linewidth',2)  % moyenne
        plot(SST0,sigaquaSSS2,'c-','Linewidth',2)
        plot(SST0,sig_theo,'r--','Linewidth',2)
        axis([-2 30 -2 2])
        grid on
        xlabel('SST')
        ylabel('diffSSS & sigdiff')
        hold off
        
        saveas(gcf,[dires 'beam' num2str(beam) '_error_biasSSS_ISAS_SST_A_D_' num2str(min(it)) '_' num2str(max(it))],'png')
        saveas(gcf,[dires 'beam' num2str(beam) '_error_biasSSS_ISAS_SST_A_D_' num2str(min(it)) '_' num2str(max(it))],'fig')
        


    end
end


