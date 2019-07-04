% L3 Aquarius product reading program RSS v5
% input     : L3 Aquarius files (7 day running products)
% output    : mat files
% date : 06/2019 (CCI+SSS year 1 project)
% author : JLV, ACRI-ST

clear

load('G:\dataSMOS\CATDS\repro_2017\isas_CATDS');  % for SST extraction

[lat0, lon0]=meshgrid(lat_fixgrid,lon_fixgrid);

dirdataaqua='I:\Aquarius_data\RSS\L3\file_mat\';  % output path

lonaqua=-179.5:1:179.5;
lataqua=-89.5:1:89.5;

% overlap for interpolation
lonaqua2=-180.5:1:180.5;

dirinput='I:\Aquarius_data\L3_mapped_v5_7day_running\';

diraq=dir(dirinput);
nameaqua='aquaA_20100701.mat'   % on pose A même si ce sont des A+D

for ifi=3:length(diraq)
    
    if diraq(ifi).name(end) ~= '2'
        ifi
        year1=str2num(diraq(ifi).name(2:5));
        nda1=str2num(diraq(ifi).name(6:8));
        
        jd1=datenum(year1,1,1,0,0,0);
        jd1=jd1+nda1;
        
        year2=str2num(diraq(ifi).name(9:12));
        nda2=str2num(diraq(ifi).name(13:15));
        
        jd2=datenum(year2,1,1,0,0,0);
        jd2=jd2+nda2;
        
        jdmoy=(jd1+jd2)/2;
        
        dvec=datevec(jdmoy);
        
        yearc=num2str(dvec(1));
        monc=num2str(dvec(2));
        if length(monc)<2; monc=['0' monc]; end;
        dayc=num2str(dvec(3));
        if length(dayc)<2; dayc=['0' dayc]; end;
        
        indisas=find(datemois_isas(:,2)==dvec(1)-2000 & datemois_isas(:,1)==dvec(2));
        
        SST1=squeeze(isasTEMP(indisas,:,:));
        
        % theoretical error : see E3UB document        
        sig_theo=0.2.*sqrt(cosd(abs(lat0)))./(0.015.*SST1+0.25);
                
        name_res=nameaqua;
        name_res(7:10)=yearc;
        name_res(11:12)=monc;
        name_res(13:14)=dayc;
        
        sss=ncread([dirinput diraq(ifi).name],'l3m_data');
        
        sss1=zeros(362,180);
        sss1(2:end-1,:)=sss;
        sss1(1,:)=sss(end,:);
        sss1(end,:)=sss(1,:);
        
        % interpolation on EASE grid
        SSS1=interp2(lonaqua2,lataqua,sss1',lon0,lat0);
        tSSS1=SSS1.*0+jdmoy;
        eSSS1=sig_theo;
        
        SSS1=SSS1(:,end:-1:1);
        tSSS1=tSSS1(:,end:-1:1);
        
        save([dirdataaqua name_res],'SSS1','tSSS1','eSSS1','SST1')
    end
end
