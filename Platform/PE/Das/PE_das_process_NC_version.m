%% initial setup
clear
close all

%%% setting path and pre-loading files
addpath('../_Config')
Process_Mode = 'ShipDas';
data_path %% all data path and library


var_list = ncinfo(DAS_RAW_Path);

for i = 1:length(var_list.Variables)
    temp = ncread(DAS_RAW_Path,var_list.Variables(i).Name);
    
    eval(['das.' var_list.Variables(i).Name '= temp;'])
end


save([DAS_PROC_final_Path Prefix '_ShipDas_Processed.mat'],'-struct','das','-v7.3')