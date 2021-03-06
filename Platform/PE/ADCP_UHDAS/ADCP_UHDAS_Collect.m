%collect UHDAS ADCP

%% initial setup
clear
close all

%%%
% ADCP_Project_name = 'PE22_31_SHERAMAN';
% ADCP_name = {'wh300','wh600','wh1200'};

ADCP_Project_name = 'PE22_31_SHERAMAN';
ADCP_name = {'wh300','wh1200'};


%%% setting path and pre-loading files
addpath('../_Config')
Process_Mode = 'ADCP_UHDAS';
data_path %% all data path and library

ADCP_PROC_Path = ['/Volumes/homes/Science/PE22_31_Shearman/data/Platform/PE/ADCP_UHDAS/PE22_31_Shearman_ADCP_1'];
%%
for i = 1:length(ADCP_name)
    
    ADCP_temp = load_getmat(fullfile( [ADCP_PROC_Path ADCP_name{i} '/contour/'], 'allbins_'));
    
    time_temp = num2str(ADCP_temp.time');
    ADCP_temp.dn = datenum(time_temp,'yyyy  mm  dd  HH  MM  SS')';
    
%     true_heading = repmat(interp1(ship.dn,ship.true_heading,ADCP_temp.dn),[size(ADCP_temp.depth,1) 1 ]);
    
%     ADCP_temp.uA =  ADCP_temp.u.*cosd(true_heading) + ADCP_temp.v.*sind(true_heading);
%     ADCP_temp.uC =  ADCP_temp.u.*sind(true_heading) - ADCP_temp.v.*cosd(true_heading);
    
    save([ADCP_PROC_final_Path Prefix '_' ADCP_name{i} '_Processed.mat'],'-struct','ADCP_temp','-v7.3')
end