function [globalDimensions, globalMetadata, VarData] = readNC_aqua(fPath, fName, DisplayListings)
%  
%  FUNCTION: readNC()
%
%  DESCRIPTION
%   This function reads an arbitrary user defined NetCDF file and returns a data structure array (VarData) 
%   containing complete variable metadata and data. It also returns
%   variables containing information on source file global metadata (globalMetadata) and variable dimension (globalDimensions).
%   Input arguements require file path and name specification, and provide the user with options to dump both
%   dataset attributes & data as listings to screen for review.
%
%  USAGE
%   Call the "readNC() " function from either the Matlab command
%   line or within a script using suitable arguement values
%
%  INPUTS ARGUEMENTS
%       fname: file name of source NetCDF data file
%       fpath: file path
%       DisplayListings: True/False flag setting to output data listings sequentially by Dataset parameter
%
%  OUTPUTS
%       globalMetadata: structure containing global file attributes
%       VarData: multidimensional data structure (dimensioned on number of variables)
%           Name: parameter/variable name
%           Attributes: concatenated parameter attributes (types & values)
%       optional Listings of dataset attributes & data to screen
%  
%  NOTES
%      1. This read software was created using Matlab version 7.14
%      2. Please email all comments and questions concerning these routines
%           to podaac@podaac.jpl.nasa.gov.
%
%  CREATED:
%       4/5/2016: Vardis Tsontos, PO.DAAC, NASA-JPL CalTech
%
%  UPDATED:
%       
%        
%
%======================================================================
% Copyright (c) 2016, California Institute of Technology
%======================================================================




% ***************************** Main **************************************

% Read file Dimensions metadata into GlobalDims structure
FileName = [fPath fName];
FileInfo = ncinfo(FileName);
FileFormat = FileInfo.Format;
globalDimensions = FileInfo.Dimensions;
numGlobalDimensions = length(FileInfo.Dimensions);
for n=1: numGlobalDimensions 
    globalDimensions(n).Attribute = [globalDimensions(n).Name  ': ' num2str(globalDimensions(n).Length)];
end
    
% Read file metadata & global netCDF file attributes into globalMetadata structure
globalAttributes = FileInfo.Attributes;
numGlobalAttributes = length(FileInfo.Attributes);
numGroups = length(FileInfo.Groups);
numDatasets = length(FileInfo.Variables);
for n =1: numGlobalAttributes
    if isnumeric(globalAttributes(n).Value)
            attribVal = num2str(globalAttributes(n).Value(:)');
        else
            attribVal = globalAttributes(n).Value;
        end    
        globalMetadata(n).Attribute = [globalAttributes(n).Name  ':  ' attribVal];
 end


% Read NetCDF file data and variable attributes into VarData structure
for n = 1:numDatasets
    numAttributes = length(FileInfo.Variables(n).Attributes);
    Temp ='';
    for m = numAttributes:-1:1
        Temp = [Temp '   ' FileInfo.Variables(n).Attributes(m).Name  ': ' num2str(FileInfo.Variables(n).Attributes(m).Value)];
    end
    VarData(n).Name = FileInfo.Variables(n).Name;
    VarData(n).Attributes = strtrim(Temp);
    VarData(n).Data = ncread(FileName,['/' FileInfo.Variables(n).Name]);
end



% Display listing of file dataset attributes and values
if DisplayListings
    disp(' ');
    disp(['File Name: ' FileName  '      NetCDF version: ' FileFormat]);
    disp(['Number of Global Dimensions: ' num2str(numGlobalDimensions)]);
    disp(['Number of Global Attributes: ' num2str(numGlobalAttributes)]);
    disp(['Number of Groups: ' num2str(numGroups)]);
    disp(['Number of Datasets: ' num2str(numDatasets)]);
    disp(' ');    
    disp('     Global Dataset Dimensions & Attributes');
    disp('------------------------------------');
    for n =1: numGlobalDimensions
        disp(num2str(globalDimensions(n).Attribute));
    end
    disp(' '); 
    for n =1:numGlobalAttributes
        disp(num2str(globalMetadata(n).Attribute));
    end
    disp(' ');
    disp(['--------- Press Space to Continue with Variable Attribute & Data listings  --------------']);
    pause;
    disp(' ');
    disp('     Variable Attributes');
    disp('------------------------------------');
    for n = 1:numDatasets
        disp(['Dataset # ' num2str(n)]);
        disp(['Dataset Name: ' VarData(n).Name]);
        disp(['Dataset Attributes: ' VarData(n).Attributes]);
        disp('Dataset Values: ');
        disp(VarData(n).Data);
        if n == numDatasets
            disp('------------------   End   -------------------');
        else
            disp(['--------- Press Space to Continue for Remaining ' num2str(numDatasets-n) ' Datasets  --------------']);
            pause;
        end       
    end
end
    

% Cleanup temporary variables
clear('FileInfo', 'fPath', 'fName','globalAttributes');
clear('m', 'n','Temp');
clear('numAttributes','attribVal');
clear('DisplayListings');

% ***************************** End **************************************

