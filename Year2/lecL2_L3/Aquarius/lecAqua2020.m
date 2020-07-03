% lecture des nouveaux produits Aquarius (L3 daily orbites A et D séparées)

clear

load('D:\CCI_2020\AUX_FILES\isas_CATDS');
load('D:\CCI_2020\AUX_FILES\maskdmin_ease2')
% pp calculé pour d/1000. Valable pour des distances < 3000 km
pp=[0.010110049201987, -0.132977635067397, 0.675117460128751, -1.665973909651722, 2.080693659666045,  -1.275049681173220, 1.359776367468559];
NN=6;
ind1=find(dmin>2000);
dmin1=dmin/1000;
fact_dist=0.*dmin1;
for ipp=1:NN
    fact_dist=fact_dist+pp(ipp)*dmin1.^(NN+1-ipp);
end
fact_dist=fact_dist+pp(NN+1);
fact_dist(ind1)=1;
indf=find(fact_dist<1);
fact_dist(indf)=1;

[lat0, lon0]=meshgrid(lat_fixgrid,lon_fixgrid);

for iorb=1:2
    
    if iorb==1; orb='A'; else; orb='D'; end;
    
    
    dirinput=['\\Espace\tmp15\tmpJLV\SCI' orb '\'];
    
    dirin=['F:\CCI_data\2020\input\aqua_data\SCI'  orb '\']
    
    dirdataaqua='F:\CCI_data\2020\input\aqua_data\file_mat\';
    nameaqua=['aqua' orb '_20100701.mat']   % on pose A ou D
    lonaqua=-179.5:1:179.5;
    lataqua=-89.5:1:89.5;
    % on elargit pour l'interpolation
    lonaqua2=-180.5:1:180.5;
    
    for iy=1:5
        yearc=num2str(2010+iy)
        tt0=datenum(2010+iy,1,1,0,0,0);
        for iday=1:365
            tt1=tt0+iday-0.5;
            
            dvec=datevec(tt1);
            
            dayc=num2str(iday);
            while length(dayc)<3; dayc=['0' dayc]; end;
            
            namepath= [dirinput yearc filesep dayc];
            namepathin= [dirin];
            dirrep=dir(namepath);
            
            yearc=num2str(dvec(1));
            monc=num2str(dvec(2));
            if length(monc)<2; monc=['0' monc]; end;
            dayc=num2str(dvec(3));
            if length(dayc)<2; dayc=['0' dayc]; end;
            
            name_res=nameaqua;
            name_res(7:10)=yearc;
            name_res(11:12)=monc;
            name_res(13:14)=dayc;
            
            indisas=find(datemois_isas(:,2)==dvec(1)-2000 & datemois_isas(:,1)==dvec(2));
            SST1=squeeze(isasTEMP(indisas,:,:));
            
            for ii=3:length(dirrep)
                chainok='0_SSS_1deg.bz2';
                if strcmp(dirrep(ii).name(end-13:end),chainok)
                    filepath=[namepath filesep dirrep(ii).name];
                    
                    filepathin=[namepathin dirrep(ii).name];
                    % copyfile(filepath,namepathin)
                    % on supprime les bz2
                    % delete([namepathin filesep '*.bz2'])
                    
                    % INFO = h5info(filepathin(1:end-4))
                    jdmoy=tt1;
                    
                    % on lit les SSS
                    %  if exist(filepathin(1:end-4))
                    sss=h5read(filepathin(1:end-4),'/l3m_data');
                    ind=find(sss<0);
                    sss(ind)=NaN;
                    
                    sss1=zeros(362,180);
                    sss1(2:end-1,:)=sss;
                    sss1(1,:)=sss(end,:);
                    sss1(end,:)=sss(1,:);
                    
                    SSS1=interp2(lonaqua2,lataqua,sss1',lon0,lat0,'nearest');
                    tSSS1=SSS1.*0+jdmoy;
                    
                    SSS1=SSS1(:,end:-1:1);
                    tSSS1=tSSS1(:,end:-1:1);
                    eSSS1=0.*SSS1(:,end:-1:1);
                    % formule empirique
                    mask=SSS1./SSS1;
                    % eSSS1=0.17./(0.03.*SST1+0.25);
                    
                    eSSS1=0.085./(0.015.*SST1+0.25);
                    eSSS1=eSSS1.*mask;
                    
                    eSSS1=eSSS1.*fact_dist;
                    %   figure; hold on; title(['Aquarius SSS error, ' name_res(7:14) ] ); imagesc(eSSS1'); colorbar; axis tight; axis xy; hold off;
                    
                    save([dirdataaqua name_res],'SSS1','tSSS1','eSSS1','SST1')
                    %  end
                end
            end
        end
    end
end


%%%%% preparation des fichiers
% orb='D';
% dirinput=['\\Espace\tmp15\tmpJLV\SCI' orb '\'];
% dirin=['F:\CCI_data\2020\input\aqua_data\SCI'  orb '\']
%
% for iy=1:5
%     yearc=num2str(2010+iy);
%     tt0=datenum(2010+iy,1,1,0,0,0);
%     for iday=1:365
%         dayc=num2str(iday);
%         while length(dayc)<3; dayc=['0' dayc]; end;
%
%         namepath= [dirinput yearc filesep dayc];
%         namepathin= [dirin];
%         dirrep=dir(namepath);
%
%         for ii=3:length(dirrep)
%             chainok='0_SSS_1deg.bz2';
%             if strcmp(dirrep(ii).name(end-13:end),chainok)
%                 filepath=[namepath filesep dirrep(ii).name]
%                 copyfile(filepath,namepathin)
%             end
%         end
%     end
% end

% delete([namepathin filesep '*.bz2'])


