clear

dlim=800;

repplot='plot_comp_isas';
if exist(repplot)==0;
    mkdir(repplot)
end

load('G:\dataSMOS\CATDS\repro_2017\latlon_ease.mat')

load('G:\dataSMOS\CATDS\repro_2017\isas_CATDS');  % 'SSSisas_grilleEASE', 'lat_ease' ,'lon_ease', 'dateisas';

load('G:\dataSMOS\CATDS\repro_2017\maskdmin_ease2');
indocean=find(dmin>800);

namefile='ESACCI-SEASURFACESALINITY-L3C-SSS-SMOSSMAPAQUARIUS_Monthly_Centred_15Day_25km-20150601-fv1.0.nc';

datef=namefile(79:86);
yearf=str2num(namefile(81:82));
monthf=str2num(namefile(83:84));

indISAS=find(yearf==datemois_isas(:,2) & monthf==datemois_isas(:,1));

SSSisas=squeeze(isasSSS(indISAS,:,:));

infout=ncinfo(namefile);

sss_smos=ncread(namefile,'sss_smos');

sss_smap=ncread(namefile,'sss_smap');

sss_aquarius=ncread(namefile,'sss_aquarius');

sss_smos_bias=ncread(namefile,'sss_smos_bias');

sss_smap_bias=ncread(namefile,'sss_smap_bias');

sss_aquarius_bias=ncread(namefile,'sss_aquarius_bias');

figure
hold on
imagesc(SSSisas'-sss_aquarius');
caxis([-0.5 0.5]); colorbar
hold off

SSSisasocean=SSSisas;
SSSisasocean(indocean)=NaN;
inds=find(isnan(sss_aquarius)==0 & isnan(SSSisasocean)==0);

corrcoef(sss_aquarius(inds),SSSisasocean(inds))

figure
hold on
plot(sss_aquarius(inds),SSSisasocean(inds),'.')
hold off

inds=find(isnan(sss_smap)==0 & isnan(SSSisasocean)==0 & sss_smap_bias>-10);

figure
hold on
plot(sss_smap(inds),SSSisasocean(inds),'.')
hold off

corrcoef(sss_smap(inds),SSSisasocean(inds))

corrcoef(sss_smap(inds)+sss_smap_bias(inds),SSSisasocean(inds))

inds=find(isnan(sss_smap)==0 & isnan(SSSisasocean)==0);
corrcoef(sss_smap(inds),SSSisasocean(inds))

corrcoef(sss_smap(inds)+sss_smap_bias(inds),SSSisasocean(inds))

figure
hold on
plot(sss_smap(inds)+sss_smap_bias(inds),SSSisasocean(inds),'.')
hold off



inds=find(isnan(sss_aquarius)==0 & isnan(SSSisasocean)==0);

dSSS=sss_aquarius(inds);
sss_aquarius_bias2=sss_aquarius_bias(inds);

map=0*sss_aquarius_bias;
indneg=find(sss_aquarius_bias<-20);
map(indneg)=1;
figure
hold on
imagesc(map')
colorbar
hold off

lat_reg=-80:0.5:80;
lon_reg=-180:0.5:180;

latease=ncread(namefile,'lat');
lonease=ncread(namefile,'lon');

[lat0, lon0]=meshgrid(lat_reg, lon_reg);

load coast

map1=interp2(lonease,latease,map',lon0,lat0);

figure
hold on
imagesc(lon_reg,lat_reg,map1')
plot(long,lat,'c-')
colorbar
hold off


figure
hold on
plot(sss_aquarius(inds)+sss_aquarius_bias(inds),SSSisasocean(inds),'.')
hold off




