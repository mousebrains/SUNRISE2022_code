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

das.dn = das.t/86400 + datenum('1970/01/01 00:00:00','yyyy/mm/dd HH:MM:SS');
das.lat = das.latitude;
das.lon = das.longitude;
das.C = das.conductivity;
das.T = das.waterTemperature;
das.SP = das.salinity;

das = rmfield(das,{'t','latitude','longitude','conductivity','waterTemperature','salinity'});


%% true heading
%True heading calculate from ship movement
radius=6373.19*1e3;

dx = radius*cosd(das.lat)*pi/180*1;
dy = radius*pi/180*1*ones(size(dx)); % 1 degree

das.true_heading = wrapTo360(angle(diffxy(1,das.lon).*dx + 1i*diffxy(1,das.lat).*dy)/pi*180);

%% distance
[~,temp] = latlon2xy(das.lat,das.lon,lat_c,lon_c);
das.dist_ship = [0;cumsum(temp)];


save([DAS_PROC_final_Path Prefix '_ShipDas_Processed.mat'],'-struct','das','-v7.3')