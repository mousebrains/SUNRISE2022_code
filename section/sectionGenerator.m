classdef sectionGenerator

  properties
    % Pelican ADCPs
    ADCP_PE_1200(1,1) logical
    ADCP_PE_1200_filepath char
    ADCP_PE_1200_variables(1,1) struct
    ADCP_PE_600(1,1) logical
    ADCP_PE_600_filepath char
    ADCP_PE_600_variables(1,1) struct
    ADCP_PE_300(1,1) logical
    ADCP_PE_300_filepath char
    ADCP_PE_300_variables(1,1) struct
    % Pelican VMP/CTD
    HYDRO_PE(1,1) logical
    HYDRO_PE_filepath char
    HYDRO_PE_variables(1,1) struct
    % Pelican GPS/MET/FT
    FTMET_PE(1,1) logical
    FTMET_PE_filepath char
    FTMET_PE_variables(1,1) struct
    % Point Sur ADCPs
    ADCP_PS_1200(1,1) logical
    ADCP_PS_1200_filepath char
    ADCP_PS_1200_variables(1,1) struct
    ADCP_PS_600(1,1) logical
    ADCP_PS_600_filepath char
    ADCP_PS_600_variables(1,1) struct
    ADCP_PS_300(1,1) logical
    ADCP_PS_300_filepath char
    ADCP_PS_300_variables(1,1) struct
    % Point Sur VMP/CTD
    HYDRO_PS(1,1) logical
    HYDRO_PS_filepath char
    HYDRO_PS_variables(1,1) struct
    % Point Sur GPS/MET/FT
    FTMET_PS(1,1) logical
    FTMET_PS_filepath char
    FTMET_PS_variables(1,1) struct
  end

  properties (Access = private)
    implemented_instruments = [
                  "ADCP_PE_1200";"ADCP_PE_600";"ADCP_PE_300";
                  "HYDRO_PE"; "FTMET_PE";
                  "ADCP_PS_1200";"ADCP_PS_600";"ADCP_PS_300";
                  "HYDRO_PS"; "FTMET_PS";
                ]
  end

  properties (Access = protected)
    % save the dn data so we don't need to recalculate it each time
    % note that the files may keep growing so we need a method to clear or update these
    ADCP_PE_1200_dn = []
    ADCP_PE_600_dn = []
    ADCP_PE_300_dn = []
    % hydro already has dn data
    FTMET_PE_dn = []
    ADCP_PS_1200_dn = []
    ADCP_PS_600_dn = []
    ADCP_PS_300_dn = []
    % hydro already has dn data
    FTMET_PS_dn = []
  end

  properties (Constant, Access = private)
    %change to 2022 for cruise
    ADCP_time_offset = datetime(2021,1,1) % do we need  - days(1) here?

    ADCP_scalar_variables = {'trajectory'}
    ADCP_time_variables = {'time','lon','lat','heading','tr_temp','num_pings','uship','vship'}
    ADCP_depth_time_variables = {'depth','u','v','amp','pg','pflag'}

    HYDRO_time_variables = {'ToB','dist','dn','lat','lon','tau','u_star'}
    HYDRO_depth_time_variables = {'DO2A','DO2R','Fl','SA','SP','Turbi','epsi','sigma','theta'}
    % what about u_star_cint
    FTMET_time_variables = {'t','longitude','latitude','headingGyro','headingGPS','waterDepth',...
      'waterTemperature','salinity','conductivity','speedOfSound','chlorophyll','fluorometer',...
      'airTemp1','airTemp2','airPressure1','airPressure2','relHumidity1','relHumidity2',...
      'windSpdRel1','windSpdRel2','windDirRel1','windDirRel2','shortWave','longWave'}
  end

  methods
    function obj = sectionGenerator(filepath)

      arguments
        filepath char = ''
      end

      % load defaults from specified file or sectionGeneratorDefaults.yml
      if isempty(filepath); filepath = 'sectionGeneratorDefaults.yml'; end
      try
        fprintf('\nReading default values from "%s"\n',filepath)
        defaults = yaml.loadFile(filepath);
      catch ME
        if strcmp(ME.identifier,'MATLAB:fileread:cannotOpenFile')
          fprintf('Error opening default file\n')
          fprintf(['Ensure "sectionGeneratorDefaults.yml" is on your PATH ' ...
            'or that your specified filepath is valid\n'])
        elseif strcmp(ME.identifier, 'yaml:load:Failed')
          fprintf('Failed to load yaml file\n')
          fprintf(['Usually caused by invalid yaml syntax. ' ...
            'Check "sectionGeneratorDefaults.yml" for valid syntax\n'])
        end
        rethrow(ME)
      end

      % set the class properties with the default values
      fields = fieldnames(defaults);
      for fn = string(fields')
        try
          if regexp(fn,'\w*(_filepath)$')
            obj.(fn) = char(defaults.(fn));
          elseif regexp(fn,'\w*(_variables)$')
            obj.(fn) = struct(defaults.(fn));
            % don't check the contents of the struct here
            % they should be boolean but it only matters
            % whether they are truthy or falsey
          else
            obj.(fn) = logical(defaults.(fn));
          end
        catch ME
          if strcmp(ME.identifier,'MATLAB:noPublicFieldForClass')
            fprintf(['\nWARNING: Skipping "%s" because it is not a valid field\n' ...
              'Valid fields are of the form:\n' ...
              '\t{instrument}, {instrument}_filepath, or {instrument}_variables\n' ...
              'Additionally, only the instruments defined in "sectionGeneratorDefaults.yml" are currently implemented\n'],fn)
            continue
          elseif strcmp(ME.identifier,'MATLAB:invalidConversion')
            fprintf(['\nWARNING: Invalid data type for "%s": %s\n' ...
              'Continuing with "%s" unset. If left unset, data from this instrument will not be loaded\n'],fn,ME.message,fn)
            continue
          end
          rethrow(ME)
        end
      end
      fprintf('\nReady to generate sections\n')
    end %sectionGenerator

    function output = load_section(obj,start_time,end_time)

      arguments
        obj
        start_time(1,:) datetime
        end_time(1,:) datetime
      end

      % check start_time and end_time are the same size
      if size(start_time) ~= size(end_time)
        error('MATLAB:sizeDimensionsMustMatch','"start_time" and "end_time" must be the same size')
      end

      Nsections = length(start_time);
      output(Nsections) = struct();

      for ss = 1:Nsections

        start_dn = datenum(start_time(ss));
        end_dn = datenum(end_time(ss));

        % check start time is before end time
        if end_dn < start_dn
          fprintf('\nWARNING: End time "%s" is before start time "%s". Skipping this section.\n',start_time(ss),end_time(ss))
          continue
        end

        %loop through the different instruments
        for instrument = obj.implemented_instruments'
          try
            % check whether to load this instrument
            if ~obj.(instrument); continue; end
            cinstrument = char(instrument);
            filepath = obj.([cinstrument '_filepath']);

            % first get the full array of datenums
            if regexp(instrument,'^(HYDRO_)\w*')
              dn = ncread(filepath,'dn');
            elseif regexp(instrument,'^(FTMET_)\w*')
              if isempty(obj.([cinstrument '_dn']))
                t = ncread(filepath,'t');
                dn = datenum(datetime(t,'ConvertFrom','posixtime'));
                obj.([cinstrument '_dn']) = dn;
              else
                dn = obj.([cinstrument '_dn']);
              end
            elseif regexp(instrument,'^(ADCP_)\w*')
              if isempty(obj.([cinstrument '_dn']))
                time = ncread(filepath,'time');
                dn = datenum(obj.ADCP_time_offset + days(time));
                obj.([cinstrument '_dn']) = dn;
              else
                dn = obj.([cinstrument '_dn']);
              end
            else
              error('UserError:InstrumentNotImplemented', ...
                'Unknown instrument in sectionGenerator.implemented_instruments')
            end % instrument type using regexp

            % now get the start and count
            start_idx = find(dn >= start_dn,1,'first');
            end_idx = find(dn <= end_dn,1,'last');
            if isempty(start_idx) || isempty(end_idx)
              fprintf('\nWARNING: No datapoints between "%s" and "%s" for instrument "%s".\n', ...
                start_time(ss),end_time(ss),instrument)
              continue
            end
            count_idx = end_idx - start_idx + 1;

          catch ME
            % handle some common errors and allow the function to continue
            if strcmp(ME.identifier,'MATLAB:noSuchMethodOrField')
              fprintf('\nWARNING: %s Skipping this instrument.\n',ME.message)
              continue
            elseif strcmp(ME.identifier,'UserError:InstrumentNotImplemented')
              fprintf('\nWARNING: Instrument "%s" has not been implemented. Skipping this instrument.\n',instrument)
              continue
            elseif strcmp(ME.identifier,'MATLAB:imagesci:netcdf:unableToOpenFileforRead')
              fprintf('\nWARNING: %s\nCheck filepath of "%s". Skipping this instrument.\n',ME.message,instrument)
              continue
            end
            rethrow(ME)
          end

          try
            % now retreive data
            for fn = string(fieldnames(obj.([cinstrument '_variables'])))'
              % skip if we are not loading this data
              if ~logical(obj.([cinstrument '_variables']).(fn)); continue; end

              if regexp(instrument,'^(ADCP_)\w*')
                switch fn
                  case 'dn'
                    output(ss).(cinstrument).(fn) = obj.([cinstrument '_dn'])(start_idx:start_idx+count_idx-1);
                  case obj.ADCP_scalar_variables
                    output(ss).(cinstrument).(fn) = ncread(filepath,fn);
                  case obj.ADCP_time_variables
                    output(ss).(cinstrument).(fn) = ncread(filepath,fn,[start_idx],[count_idx]);
                  case obj.ADCP_depth_time_variables
                    output(ss).(cinstrument).(fn) = ncread(filepath,fn,[1,start_idx],[inf,count_idx]);
                  otherwise
                    fprintf('\nWARNING: Unknown variable "%s" for instrument "%s".\n',fn,instrument)
                end % switch fn
              elseif regexp(instrument,'^(HYDRO_)\w*')
                switch fn
                  case obj.HYDRO_time_variables
                    output(ss).(cinstrument).(fn) = ncread(filepath,fn,[start_idx],[count_idx]);
                  case obj.HYDRO_depth_time_variables
                    output(ss).(cinstrument).(fn) = ncread(filepath,fn,[1,start_idx],[inf,count_idx]);
                  otherwise
                    fprintf('\nWARNING: Unknown variable "%s" for instrument "%s".\n',fn,instrument)
                end % switch fn
              elseif regexp(instrument,'^(FTMET_)\w*')
                switch fn
                  case 'dn'
                    output(ss).(cinstrument).(fn) = obj.([cinstrument '_dn'])(start_idx:start_idx+count_idx-1);
                  case obj.FTMET_time_variables
                    output(ss).(cinstrument).(fn) = ncread(filepath,fn,[start_idx],[count_idx]);
                  otherwise
                    fprintf('\nWARNING: Unknown variable "%s" for instrument "%s".\n',fn,instrument)
                end % switch fn

              end % determine instrument type using regexp
            end %for loop over variables

          catch ME

            if strcmp(ME.identifier,'MATLAB:invalidConversion')
              fprintf(['\nWARNING: Invalid data type for "%s": %s\n' ...
                'Check value in default file. Skipping "%s" in "%s".\n'],fn,ME.message,fn,instrument)
              continue
            end
            rethrow(ME)
          end %try

        end % implemented instruments

      end % sections

    end %load_section

  end %methods
end %classdef
