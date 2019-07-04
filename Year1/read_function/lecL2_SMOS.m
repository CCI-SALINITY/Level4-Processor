% L2 CATDS product reading program
% input     : L2 CATDS files (L2P and UDP)
% output    : mat files
% date : 06/2019 (CCI+SSS year 1 project)
% author : JLV, ACRI-ST

clear

% L2 input data (from CATDS)
dirdata='J:\CATDS\RE05\RE05\MIR_CSF2P';     % L2P data
dirdataUDP='J:\CATDS\RE05\RE05\MIR_CSF2U';  % UDP data

dateref=datenum(2000,1,1);  % JD time reference SMOS 1/1/2000
% dwell sampling
xswathmax=662.5;
pasxswath=25;
xswath=-xswathmax:pasxswath:xswathmax;

% load EASE grid specification
load('latlon_ease')   %'lat_ease','lon_ease','nlat','nlon';

% baseline for output file names
name='smosA_20100701.nc';

year=['10'; '11'; '12'; '13'; '14'; '15'; '16'; '17'; '18'; '19']   % selected years
nyear=size(year,1);

% initialisation
SSSsel=[];
eSSSsel=[];
tSSSsel=[];
nSsel=[];
tabNaNind=[];

for iad=1:2  % loop asc-desc
    if iad==1
        orb='A'
    end
    if iad==2
        orb='D'
    end
    dirascdesc=[dirdata orb '/'];
    dirascdescUDP=[dirdataUDP orb '/'];
    for ia=1:nyear  % loop over the years
        ia
        ia1=ia;
        ia2=ia;
        diryear=[dirascdesc '20' year(ia1,:) '/'];
        dirt=dir(diryear);
        diryearUDP=[dirascdescUDP '20' year(ia1,:) '/'];
        
        for jday=1:length(dirt)
            
            jour=dirt(jday).name
            
            % L2P
            dir1=dir([diryear dirt(jday).name]);
            filepath=[diryear dirt(jday).name '/' dir1(3).name]
            name1=[dir1(3).name(1:end-4) '.HDR'];
            name2=[dir1(3).name(1:end-4) '.DBL'];
            
            % UDP
            dir1UDP=dir([diryearUDP dirt(jday).name]);
            filepathUDP=[diryearUDP dirt(jday).name '/' dir1UDP(3).name]
            name1UDP=[dir1UDP(3).name(1:end-4) '.HDR'];
            name2UDP=[dir1UDP(3).name(1:end-4) '.DBL'];
            
            if (exist(filepathUDP) ~= 0 & exist(filepath) ~= 0)
                
                untar(filepath)
                
                if exist(name2)==0;
                    name2=[dir1(3).name(1:end-4) '.DBL.nc'];
                end
                
                tSSS=ncread(name2,'Mean_Acq_Time');
                tSSS=tSSS+dateref;
                vecd=datevec(max(max(tSSS)));
                xswathSSS=ncread(name2,'X_Swath');
                
                SSS=ncread(name2,'Sea_Surface_Salinity_Model1_Value');
                eSSS=ncread(name2,'Sea_Surface_Salinity_Model1_Error');
                
                %  cSSS=ncread(name2,'Sea_Surface_Salinity_Model1_Classes');
                %  cSSSbin=dec2bin(cSSS,32);
                %  valdSSS=str2num(cSSSbin(:,32));
                %  valdSSS=reshape(valdSSS,nlon,nlat);
                
                % xswath index
                indxswath=floor((xswathSSS+xswathmax)/pasxswath)+1;
                delete(name1);
                delete(name2);
                
                imonth=vecd(2);
                if imonth < 10; imonc=['0' num2str(imonth)]; else imonc=num2str(imonth); end;
                iday=vecd(3);
                if iday < 10; idayc=['0' num2str(iday)]; else; idayc=num2str(iday); end;
                
                % SSS selection
                ind0=find(SSS<0 | isnan(SSS));
                
                SSS0=SSS;
                eSSS0=eSSS;
                idwSSS0=indxswath;
                tSSS0=tSSS;
                % classSSS0=valdSSS;
                SSS0(ind0)=NaN;
                eSSS0(ind0)=NaN;
                tSSS0(ind0)=NaN;
                idwSSS0(ind0)=NaN;
                % classSSS0(ind0)=NaN;
                
                untar(filepathUDP)
                                
                Dg_chi2_1=ncread(name2UDP,'Dg_chi2_1')./100;
                Acard=ncread(name2UDP,'Acard');
                
                ind=find(Dg_chi2_1<=0);
                Dg_chi2_1(ind)=999;
                Dg_chi2_1=sqrt(Dg_chi2_1);
                chiSSS0=Dg_chi2_1;
                dualfull='full';
                
                SST0=ncread(name2UDP,'SST')-273.15;
                WS0=ncread(name2UDP,'WS');
                Dg_Suspect_ice0=ncread(name2UDP,'Dg_Suspect_ice');
                
                Dg_chi2_Acard=ncread(name2UDP,'Dg_chi2_Acard');
                
                delete(name1UDP);
                delete(name2UDP);
                
                name_ok=name;
                name_ok(5)=orb;
                name_ok(9:10)=year(ia1,:);
                name_ok(11:12)=imonc;
                name_ok(13:14)=idayc;
                namemat=name_ok(1:14);
                [epsr]=KS(SST0,SSS0);
                Acard_mod=eps2acard(epsr);

                save(['J:\CATDS\RE05\file_mat_full\' namemat],'Dg_Suspect_ice0','WS0','SST0','SSS0','eSSS0','idwSSS0','chiSSS0','tSSS0','xswath','dualfull','Acard','Acard_mod','Dg_chi2_Acard')
            end
        end
    end
end

