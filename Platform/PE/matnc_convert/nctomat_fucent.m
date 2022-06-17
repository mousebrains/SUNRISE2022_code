%% initial setup
clear
close all

%%% setting path and pre-loading files
addpath('../_Config')
Process_Mode = 'ShipDas';
data_path %% all data path and library


% This code is an easy way to convert nc into mat file.

Processed_Path = '../../../../data/Processed_NC/';

process_nc_path = dir(fullfile(Processed_Path, '**/*.*'));
process_nc_path = process_nc_path(startsWith({process_mat_path.name},'SUNRISE2022_') & endsWith({process_mat_path.name},'_Processed.nc'));

if strcmp(Platform,'PS')
    process_nc_path = process_nc_path(~contains({process_path.folder},'ADCP','Das','PS'));

elseif strcmp(Platform,'PE')
    process_nc_path = process_nc_path(~contains({process_path.folder},'ADCP','Das','PE'));
else
    error('new platform')
end


for i = 1:length(process_nc_path)
    mat_folder = [Processed_Path(1:end-1) '_NC/' process_mat_path(i).folder(text_str:end)];
    mat_path =  [mat_folder '/' process_nc_path(i).name(1:end-2) 'mat'];
    
    nc_path = [process_nc_path(i).folder '/' process_nc_path(i).name];

    if ~exist(mat_folder,'dir')
        mkdir(mat_folder)
    end
    
    var_list = ncinfo(DAS_RAW_Path);
    
    for j = 1:length(var_list.Variables)
        temp = ncread(DAS_RAW_Path,var_list.Variables(i).Name);
        
        eval(['save_struct.' var_list.Variables(i).Name '= temp;'])
    end
    
    
    save(mat_path,'-struct','save_struct','-v7.3')
    
end