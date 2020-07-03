% construction d'une climatologie Aquarius à partir des L3 journaliers

clear

set(groot,'DefaultFigureColormap',jet)
load('G:\dataSMOS\CATDS\repro_2017\correction_biais\easegrid_new.mat')

[lat0, lon0]=meshgrid(lat_fixgrid,lon_fixgrid);
nlon_ease=length(lon_fixgrid);
nlat_ease=length(lat_fixgrid);

load('G:\dataSMOS\CATDS\repro_2017\isas_CATDS')

repaqu='I:\Aquarius_data\L3_mapped_v5_7day_running\';
direpaqu=dir(repaqu);

% on selectionne et on trie les fichiers

for ifile=3:length(direpaqu)
    namefile=direpaqu(ifile).name;
    
    if namefile(end)~='2'
        
        yea=str2num(namefile(2:5));
        ida=str2num(namefile(6:8));
        
        dateJJ0=datenum(yea,0,0)+ida;
        vdat=datevec(dateJJ0);
        iday=vdat(3);
        imo=vdat(2);
        iy=vdat(1)-2010;
        
        
        fileaqua(iy,imo).day(iday).name=namefile;
        
    end
end


load coast
loncoast=long;
latcoast=lat;

lon=-179.5:179.5;
%lon=-179:180;

lat=-89.5:89.5;

nlon=length(lon);
nlat=length(lat);

ill=(180:-1:1);
k=0;

aquaSSS0=NaN(47,360,180);
for iyear=1:5
    for imonth=1:12
        
        nday=length(fileaqua(iyear,imonth).day);
        if nday >0
            k=k+1
            kd=0;
            SSSd=NaN(nlon,nlat,31);
            for ida=1:nday
                if length(fileaqua(iyear,imonth).day(ida).name)>0
                    kd=kd+1;
                    filen=[repaqu fileaqua(iyear,imonth).day(ida).name];
                    SSS=ncread(filen,'l3m_data');
                    SSSd(:,:,kd)=SSS(:,ill);
                    
                   sss=ncread(filen,'/Aquarius Data/SSS');
                    
                   keyboard
                end
                
                %                 figure
                %                 hold on
                %                 imagesc(lon,lat,SSS')
                %                 plot(loncoast,latcoast,'-')
                %                 hold off
                %
                %                 keyboard
                
            end
            aquaSSS0(k,:,:)=nanmean(SSSd,3);
            datemois_aqua(k,2)=iyear+10;
            datemois_aqua(k,1)=imonth;
        end
        
    end
end

aquaSSS0(:,2:361,:)=aquaSSS0;
aquaSSS0(:,1,:)=aquaSSS0(:,361,:);
aquaSSS0(:,362,:)=aquaSSS0(:,2,:);
lon1=-180.5:180.5;

indtti=[-1 -1 -1 0 0 0 1 1 1];
indttj=[-1 0 1 -1 0 1 -1 0 1];

% on remplit quelques trous
for itr=1:2
    itr
    for imap=1:k
        SSS0=squeeze(aquaSSS0(imap,:,:));
        SSS1=SSS0;
        [indi, indj]=find(isnan(SSS0));
        for ii=1:length(indi)
            indi0=indi(ii)+indtti;
            indj0=indj(ii)+indttj;
            
            indok=find(indi0>0 & indj0>0 & indi0<363 & indj0<180);
            indiok=indi0(indok);
            indjok=indj0(indok);
            
            SSS1(indi(ii), indj(ii))=nanmean(nanmean(SSS0(indiok,indjok)));
            %   keyboard
        end
        aquaSSS0(imap,:,:)=SSS1;
        
    end
end

figure
subplot(2,1,1)
hold on
imagesc(lon1,lat,SSS0')
axis tight
plot(loncoast,latcoast,'-')
colorbar
hold off
subplot(2,1,2)
hold on
imagesc(lon1,lat,SSS1')
axis tight
plot(loncoast,latcoast,'-')
colorbar
hold off

aquaSSS=NaN(47,nlon_ease,nlat_ease);

for imap=1:k
    SSS0=squeeze(aquaSSS0(imap,:,:));
    SSS1=interp2(lon1,lat,SSS0',lon0,lat0);
    aquaSSS(imap,:,:)=SSS1;
end

save('aqua_month','datemois_aqua','aquaSSS');
% F:\vergely\SMOS\CCI\matlab\Sensors_L2\year1\AQUA_RSS\aqua_month.mat  

for imap=1:k
    
    SSS1=squeeze(aquaSSS(imap,:,:));
    SSS2=squeeze(isasSSS(imap+19,:,:));  % decalage temps 19
    
    figure
    subplot(2,1,1)
    hold on
    title(['Aqua, ' num2str(datemois_aqua(imap,1)) '/' num2str(datemois_aqua(imap,2))])
    imagesc(SSS1')
    axis tight
    caxis([18 38])
    colorbar
    hold off
    subplot(2,1,2)
    hold on
    title('ISAS')
    imagesc(SSS2')
    axis tight
    caxis([18 38])
    colorbar
    hold off
    
end

