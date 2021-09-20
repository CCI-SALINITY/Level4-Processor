% patch pour la correction des netcdf

netcdf_path='J:\SSS\CCI\2021\res2\30days\';

dirpath=dir(netcdf_path);
load('F:\vergely\SMOS\CCI\livrables\CCI_soft_year3\aux_files\latlon_ease.mat');

for iyear=3:length(dirpath)
    dirpathyear=dir([netcdf_path dirpath(iyear).name '\']);
    for ifile=3:length(dirpathyear)
        
        nametot=[netcdf_path dirpath(iyear).name '\' dirpathyear(ifile).name]
       % infout0=ncinfo(nametot);
        %  sss_qc0=ncread(nametot,'sss_qc');
        
        %  nc=netcdf.open(nametot,'WRITE');
        % varid=netcdf.inqVarID(nc,'sss_qc');
        % [noFillMode,fillValue] = netcdf.inqVarFill(nc,varid);
        % fillval=-1
        % netcdf.defVarFill(nc,varid,false,fillval);
        
        Value= lat_ease(1);  % year2 type ?
        ncwriteatt(nametot,'/','geospatial_lat_min',Value);
        
        Value= lat_ease(end);  % year2 type ?
        ncwriteatt(nametot,'/','geospatial_lat_max',Value);
        
        Value= lon_ease(1);  % year2 type ?
        ncwriteatt(nametot,'/','geospatial_lon_min',Value);
        
        Value= lon_ease(end); % year2 type ?
        ncwriteatt(nametot,'/','geospatial_lon_max',Value);
                
       % infout1=ncinfo(nametot);
      %  infout1.Attributes(end)
        
        %   figure; subplot(2,1,1); hold on; imagesc( sss_qc0'); caxis([-2 2]); hold off
        %  subplot(2,1,2); hold on; imagesc( sss_qc1'); caxis([-2 2]); hold off
     %   keyboard
    end
    
end