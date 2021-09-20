% program for configuration report writing
% input     : conf structure
% output    : XML report
% date : 06/2019 (CCI+SSS year 1 project)
% author : JLV, ACRI-ST

rep_name='rapport';
Pref=[];
Pref.ItemName='Input_File';
RootName='';
xml_write([rep_name '.EEF'],conf,RootName,Pref);