%% initial setup
clear
close all

%%% setting path and pre-loading files
addpath('../_Config')
Process_Mode = 'ShipDas';
data_path %% all data path and library

DAS_RAW_Path = [datapath Process_Mode '/']; % raw das file
copyfile('/Volumes/SCSServer4.9.1/DATALOG40/EventData/MIDAS/MIDAS_001.elg',[DAS_RAW_Path 'MIDAS_001.txt']);


if exist([DAS_PROC_final_Path Prefix '_ShipDas_Processed.mat'],'file')
    das_previous = matfile([DAS_PROC_final_Path Prefix '_ShipDas_Processed.mat'],'Writable',true);
    
    N_old = length(das_previous.dn);
    
    %%% work on ship
    opt = detectImportOptions([DAS_RAW_Path 'MIDAS_001.txt']);
    opt.DataLines = [N_old-2 inf];
    opt = setvaropts(opt,{'Thermosalinograph_Data_Temp','Thermosalinograph_Data_Salinity',...
        'Thermosalinograph_Data_Conductivity','Thermosalinograph_Data_Sound_Velocity',...
        'SPAR_Voltage_DRV_VALUE','SPAR_Microeinsteins_DRV_VALUE','Chirp3_5KHzTrueDepthMeters_VALUE',...
        'Chirp12KHzTrueDepthMeters_VALUE','Chirp100KHzTrueDepthMeters_VALUE'},'Type','double');
    %%%
    
    DAS = readtable([DAS_RAW_Path 'MIDAS_001.txt'],opt);

    das.dn = datenum(DAS.Date+DAS.Time);
    
    latchar = string(DAS.ABX2_GGA_Lat);
    das.lat = str2double(extractBetween(latchar(:),1,2)) + str2double(extractBetween(latchar(:),3,12))/60;
    
    lonchar = string(DAS.ABX2_GGA_Lon);
    das.lon = -(str2double(extractBetween(lonchar(:),1,3)) + str2double(extractBetween(lonchar(:),4,13))/60);
    
    
    das.heading_gyro = DAS.Sperry_MK1_Gyro_Hdg_deg;
    das.heading_GPS = DAS.Furuno_SC50_GPS_Hdg_Hdg;
    das.T = DAS.Thermosalinograph_Data_Temp;
    das.SP = DAS.Thermosalinograph_Data_Salinity;
    das.C = DAS.Thermosalinograph_Data_Conductivity;
    das.ssnd = DAS.Thermosalinograph_Data_Sound_Velocity;
    das.transm = DAS.Transmissometer_percent_DRV_VALUE;
    das.Fl = DAS.Wetstar_Fluorometer_ug_per_L_Chl_A_DRV_VALUE;
    das.SPARvolt = DAS.SPAR_Voltage_DRV_VALUE;
    das.SPARme = DAS.SPAR_Microeinsteins_DRV_VALUE;
    das.airT = DAS.Air_Temp_1;
    das.airT2 = DAS.Air_Temp_2;
    das.RH = DAS.Rel_Humidity_1;
    das.RH2 = DAS.Rel_Humidity_2;
    das.baroP = DAS.BaromPress_1;
    das.baroP2=DAS.BaromPress_2;
    das.relwinddir = DAS.Rel_WindDir_1_Val;
    das.relwindspd = DAS.Rel_WindDir_2;
    das.relwinddir2 = DAS.Rel_WindDir_2;
    das.truewinddir = DAS.TrueWindDirection_1_DRV_DIRECTION;
    das.truewindspd = DAS.TrueWindDirection_1_DRV_SPEED;
    das.truewinddir2 = DAS.True_Wind_2_DRV_DIRECTION;
    das.truewindspd2 = DAS.True_Wind_2_DRV_SPEED;
    das.truewindspd5sa = DAS.TWSpd_5sAvg2_DRV_VALUE;
    das.LW = DAS.Radiometer_Feed__LongWaveRadiationWattsPerSquareMeter;
    das.SW = DAS.Radiometer_Feed__ShortWaveRadiationFromPSPInWattsPerM_2;  

    %% true heading
    %True heading calculate from ship movement
    radius=6373.19*1e3;
    
    dx = radius*cosd(das.lat)*pi/180*1;
    dy = radius*pi/180*1*ones(size(dx)); % 1 degree
    
    das.true_heading = wrapTo360(angle(diffxy(1,das.lon).*dx + 1i*diffxy(1,das.lat).*dy)/pi*180);
    
    %% distance
    [~,temp] = latlon2xy(das.lat,das.lon,lat_c,lon_c);
    das.dist_ship = [0;cumsum(temp)];
    
    
    var_list = fieldnames(das);
    
    for k = 1:length(var_list)
        das_previous.(var_list{k}) = [das_previous.(var_list{k})(1:end-2,1);das.(var_list{k})];
    end
    
    
else
    DAS = readtable([DAS_RAW_Path 'MIDAS_001.txt']);
    
    
    
    das.dn = datenum(DAS.Date+DAS.Time);
    
    latchar = string(DAS.ABX2_GGA_Lat);
    das.lat = str2double(extractBetween(latchar(:),1,2)) + str2double(extractBetween(latchar(:),3,12))/60;
    
    lonchar = string(DAS.ABX2_GGA_Lon);
    das.lon = -(str2double(extractBetween(lonchar(:),1,3)) + str2double(extractBetween(lonchar(:),4,13))/60);
    
    
    das.heading_gyro = DAS.Sperry_MK1_Gyro_Hdg_deg;
    das.heading_GPS = DAS.Furuno_SC50_GPS_Hdg_Hdg;
    das.T = DAS.Thermosalinograph_Data_Temp;
    das.SP = DAS.Thermosalinograph_Data_Salinity;
    das.C = DAS.Thermosalinograph_Data_Conductivity;
    das.ssnd = DAS.Thermosalinograph_Data_Sound_Velocity;
    das.transm = DAS.Transmissometer_percent_DRV_VALUE;
    das.Fl = DAS.Wetstar_Fluorometer_ug_per_L_Chl_A_DRV_VALUE;
    das.SPARvolt = DAS.SPAR_Voltage_DRV_VALUE;
    das.SPARme = DAS.SPAR_Microeinsteins_DRV_VALUE;
    das.airT = DAS.Air_Temp_1;
    das.airT2 = DAS.Air_Temp_2;
    das.RH = DAS.Rel_Humidity_1;
    das.RH2 = DAS.Rel_Humidity_2;
    das.baroP = DAS.BaromPress_1;
    das.baroP2=DAS.BaromPress_2;
    das.relwinddir = DAS.Rel_WindDir_1_Val;
    das.relwindspd = DAS.Rel_WindDir_2;
    das.relwinddir2 = DAS.Rel_WindDir_2;
    das.truewinddir = DAS.TrueWindDirection_1_DRV_DIRECTION;
    das.truewindspd = DAS.TrueWindDirection_1_DRV_SPEED;
    das.truewinddir2 = DAS.True_Wind_2_DRV_DIRECTION;
    das.truewindspd2 = DAS.True_Wind_2_DRV_SPEED;
    das.truewindspd5sa = DAS.TWSpd_5sAvg2_DRV_VALUE;
    das.LW = DAS.Radiometer_Feed__LongWaveRadiationWattsPerSquareMeter;
    das.SW = DAS.Radiometer_Feed__ShortWaveRadiationFromPSPInWattsPerM_2;
    
    %% true heading
    %True heading calculate from ship movement
    radius=6373.19*1e3;
    
    dx = radius*cosd(das.lat)*pi/180*1;
    dy = radius*pi/180*1*ones(size(dx)); % 1 degree
    
    das.true_heading = wrapTo360(angle(diffxy(1,das.lon).*dx + 1i*diffxy(1,das.lat).*dy)/pi*180);
    
    %% distance
    [~,temp] = latlon2xy(das.lat,das.lon,lat_c,lon_c);
    das.dist_ship = [0;cumsum(temp)];
    
    %% Read me
    das.readme=char('Data collected by the R/V Pelican onboard system for GoM 2019 cruise',...
        'dn: time in Matlab datenum format',...
        'lat, lon is degrees',...
        'heading_gyro: ship''s heading from the gyro, [degrees]',...
        'heading_GPS: ship''s heading from GPS [degrees]',...
        'T: temperature [deg C]',...
        'S: salinity [psu]',...
        'conductivity: [mS]',...
        'ssnd: speed of sound, [m\s]',...
        'transm: transmissometer, [%]',...
        'fluo: fluorometer [ug/L]',...
        'SPARvolt: [volt]',...
        'SPARme: [microeinsteins]',...
        'airT: air temperature [degC]',...
        'RH: relative humidity [%]',...
        'baroP: barometric pressure [mbar]',...
        'relwinddir: relative wind direction [degrees]',...
        'relwindspd: relative wind speed [kts]',...
        'truewinddir: true wind direction [degrees]',...
        'truewindspd: true wind speed [kts]',...
        'relwinddir2: relative wind direction [degrees]',...
        'relwindspd2: relative wind speed [kts]',...
        'truewindspd5sa: 5-second average of true wind speed [kts]',...
        'airT2: air temperature from [degC]',...
        'baroP2: barometric pressure from [mbar]',...
        'RH2: relative humidity from [%]',...
        'LW: long wave radiation [W/m2]',...
        'SW: short wave radiation [W/m2]',...
        'true_heading: heading from movement [deg]');
    
    %% Save
    save([DAS_PROC_final_Path Prefix '_ShipDas_Processed.mat'],'-struct','das','-v7.3')
end