% program for SST and latitudinal bias correction for SMOS data
% input     : L2 SMOS files (from file_mat_full)
% output    : mat files
% date : 06/2019 (CCI+SSS year 1 project)
% author : JLV, ACRI-ST

% remark : to be run twice. First with switch_diel_only=1 and after with
% switch_diel_only=0

clear

switch_diel_only=1;     % ==1 si on applique seulement la correction de la cste diel, ==0 si on applique seulement la correction latitudinale
model=1;  % ==1 for Zhou 2017 and >1 for Dinnat + sigSST

dirres='plot_biais_sans_filtre_SST_moyenne_2_corrSST_Atlan_v3/';  % version utilisee pour generer la CEC v3

% corrSSS_smooth contient toutes les dwells. Correction latitudinale 
load([dirres 'corrSSS'])            % 'SST_ref','corrSSS_smooth','corrSSS_SST_smooth','ff','lat_fixgrid'
% correction en SST
corrfile='F:\vergely\SMOS\phaseE\2018\Acard\biaisDinnat\biais_corr_polynome.mat';
load(corrfile);

SSScorrA_month=corrSSS_SST_smooth(:,1:39,:);
SSScorrD_month=corrSSS_SST_smooth(:,40:end,:);

if switch_diel_only==0
    repL2='J:\CATDS\RE05\file_mat_full_SST\';
    repL2c=['J:\CATDS\RE05\file_mat_full_corr_SST\'];  % resultats corriges latitudinalement et SST diel
else
    repL2='J:\CATDS\RE05\file_mat_full\';
    repL2c=['J:\CATDS\RE05\file_mat_full_SST\']  % resultats corriges SST diel seulement
end

if exist(repL2c)==0
    mkdir(repL2c)
end

dirrepL2=dir(repL2);

% pour les l2
xswathmax=662.5;
pasxswath=25;
xswath=-xswathmax:pasxswath:xswathmax;

indxswath=floor((xswath+xswathmax)/pasxswath)+1;

% correspondance avec les dwells corrigées, plus proche voisin
for ix=1:length(indxswath)
    [val indm]=min(abs(xswath(ix)-ff));
    tab_conv(ix)= indm;
end

for ii=3:length(dirrepL2)
    
    if exist([repL2c dirrepL2(ii).name])== 0
        ii
        load([repL2 dirrepL2(ii).name]);
        orb=dirrepL2(ii).name(5);
        yearc=dirrepL2(ii).name(7:10);
        imonth=str2num(dirrepL2(ii).name(11:12));
        [epsr]=KS(SST0,SSS0);
        Acard_mod=eps2acard(epsr);
        
%        keyboard
        
        % correction de la constante dielectrique
        if model==1
            indSSTc=find(SST0<8.5);
            bias_diel=0.0136.*SST0.^2-0.2553.*SST0+1.1874;               % correction à partir de Zhou 2017 de Jacqueline
        elseif model==2
            indSSTc=find(SST0<12);
            bias_diel=-0.0005.*SST0.^3+0.02.*SST0.^2-0.23.*SST0+0.68;    % correction à partir de Dinnat 2019 d'Alexandre
        else  
            indSSTc=find(SST0<18);
            isigSST=1;   % erreur SST considéré: 0.6°C (isigSST=1), 0.8°C (isigSST=2), 1°C (isigSST=3)
            bias_diel=Poly(isigSST,1)*SST0.^6+Poly(isigSST,2)*SST0.^5+Poly(isigSST,3)*SST0.^4+Poly(isigSST,4)*SST0.^3+Poly(isigSST,5)*SST0.^2+Poly(isigSST,6)*SST0+Poly(isigSST,7);
        end
        
        SSS0(indSSTc)=SSS0(indSSTc)-bias_diel(indSSTc);
        
        if switch_diel_only==0
            if orb=='A'
                corrSSS=squeeze(SSScorrA_month(imonth,:,:));
            else
                corrSSS=squeeze(SSScorrD_month(imonth,:,:));
            end
            
            % biais lat est donné à SSTref
            SST_ref0=SST_ref(imonth,:);
            coeff=((0.015*repmat(SST_ref0,1388,1)+0.25)./(0.015*SST0+0.25));  % On donne le biais à SST0
            
            for ix=10:45
                corrSSS1=repmat(squeeze(corrSSS(tab_conv(ix),:)),1388,1);
                indx=find(idwSSS0==ix);
                SSS0(indx)=SSS0(indx)+corrSSS1(indx).*coeff(indx);
            end
        end
        save([repL2c dirrepL2(ii).name],'Dg_Suspect_ice0','WS0','SST0','SSS0','eSSS0','idwSSS0','chiSSS0','tSSS0','xswath','dualfull','Acard','Dg_chi2_Acard','Acard_mod')
    end
end
