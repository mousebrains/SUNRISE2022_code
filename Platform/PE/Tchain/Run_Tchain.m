%% initial setup
clear
close all

%%% setting path and pre-loading files
addpath('../_Config')
Process_Mode = 'Tchain';
data_path %% all data path and library

%%% Cannot Run RBR on NAS. So link those file.
TCn_GPS_Path = [Processed_Path 'ShipDas/' Prefix '_ShipDas_Processed.mat']; %% path to Ship Das data.
NAS_path = '/Volumes/homes/Science/PE22_31_Shearman'; %% path to NAS

%%%
Deployment_name = {'deploy_test'};

% 'all' for all deployments
% [] for the latest deployment
% Or Specific Deployment Names you want to rerun
% A name starts with "deploy_".

%%%
%TCn_GPS_Path is Ship GPS. If there are several chuck of data,TCn_GPS_Path
%will be empty. You need to manually write pathes into the config function.
%config = config_SUNRISE2021_PE(Deployment_name,TCn_DATA_Path,TCn_GPS_Path);

% BowChain_master(Prefix)

chain_struct = BowChain_master(Prefix,Deployment_name,TCn_DATA_Path,TCn_GPS_Path);

copyfile('./Deployment_Info.csv',[TCn_DATA_Path 'Deployment_Info.csv']) % backup

for i = 1:length(chain_struct)
    chain_struct_save =   chain_struct(i) ;    
    save([TCn_PROC_final_Path Prefix '_Tchain_' chain_struct_save.info.config.name '_Processed.mat'],'-struct','chain_struct_save','-v7.3')
    
    %%%%move data back to NAS
    %%% final mat-file
    copyfile([TCn_PROC_final_Path Prefix '_Tchain_' chain_struct_save.info.config.name '_Processed.mat'],...
        [NAS_path '/data/Processed/Tchain/' Platform '/' Prefix '_Tchain_' chain_struct_save.info.config.name '_Processed.mat'])
    
    %%% raw data folder
    copyfile([datapath Process_Mode '/' chain_struct_save.info.config.name]...
        ,[NAS_path '/data/Platform/' Platform '/Tchain/' chain_struct_save.info.config.name])
    
    %%% csv file
    copyfile('./Deployment_Info.csv'...
        ,[NAS_path '/code/Platform/' Platform '/Tchain/'])
    copyfile('./Deployment_Info.csv'...
        ,[NAS_path '/data/Platform/' Platform '/Tchain/' chain_struct_save.info.config.name])    
end





return
for i = 1:length(chain_struct)
    
    %%% obv_flag flags time when a chain is fully in the water. In other word, the chain is not on the groud.
    
    chain_struct_save =   chain_struct(i) ;
    N = length(chain_struct_save.dn);
    
    chain_struct_save.obv_flag = zeros(1,N);
    P_last_CTD = chain_struct_save.P(find(~isnan(mean(chain_struct_save.P,2,'omitnan')),1,'last'),:);
    
    P_ana = find(ischange(double(abs(diffxy(chain_struct_save.dn,movmean(P_last_CTD,60,2))/86400)>0.15),'Threshold',0.1));
    
    if mean(P_last_CTD(1:P_ana(1)),'omitnan')<3
        for j = 1:length(P_ana)
            if mod(j-3,4) == 0
                chain_struct_save.obv_flag(1,P_ana(j-1):P_ana(j)) = 1;
            end
        end
    else
        chain_struct_save.obv_flag(1:P_ana(1)) = 1;
        for j = 1:length(P_ana)
            if mod(j-1,4) == 1 && j >1
                chain_struct_save.obv_flag(1,P_ana(j-1):P_ana(j)) = 1;
            end
        end
    end

    save([TCn_PROC_final_Path Prefix '_Tchain_' chain_struct_save.info.config.name '_Processed.mat'],'-struct','chain_struct_save','-v7.3')
end