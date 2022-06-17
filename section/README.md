# Section Generator

*sectionGenerator* is a matlab class for loading sections of ADCP, VMP/CTD (collectively called HYDRO), and FTMET data.

# Usage

First ensure that you have an up to date version of the **SUNRISE2022_code** directory and that it and its subfolders are on your matlab path. Then, we create an instance of the *sectionGenerator* class:

```
>> addpath(genpath('SUNRISE2022_code'));
>> SG = sectionGenerator();
```

## Loading a section

Now, we can load a section between two datetimes:

```
>> end_time = datetime('now',TimeZone='Z');
>> start_time = end_time - hours(2);
>> section = SG.load_section(start_time,end_time);
```

The output is:

```
>> section

section =

  struct with fields:

    ADCP_PE_1200
    ADCP_PE_600
    ADCP_PE_300
    ADCP_PS_1200
    ADCP_PS_600
    ADCP_PS_300
    HYDRO_PE
    HYDRO_PS

>> section.ADCP_PE_1200

ans =

  struct with fields:

     time: [901×1 double]
      lon: [901×1 double]
      lat: [901×1 double]
    depth: [40×901 single]
       dn: [901×1 double]
        u: [40×901 single]
        v: [40×901 single]

```

## Loading multiple sections

Alternatively, you can load multiple sections at once by passing arrays of start and end times:

```
>> end_times = [datetime('now',TimeZone='Z'),datetime('now',TimeZone='Z')-hours(2)];
>> start_times = end_times - hours(2);
>> sections = SG.load_section(start_times,end_times);
```

This gives:

```
>> sections

sections =

  1×2 struct array with fields:

    ADCP_PE_1200
    ADCP_PE_600
    ADCP_PE_300
    HYDRO_PE
    ADCP_PS_1200
    ADCP_PS_600
    ADCP_PS_300
    HYDRO_PS
```

## Ship argument

`load_section` has an option third argument `ship` defaulting to `'both'`. Setting this to `'PE'` or `'PS'` will load the instruments from only that ship. e.g.

```
>> section = SG.load_section(start_time,end_time,"PS")

section =

  struct with fields:

    ADCP_PS_1200: [1×1 struct]
     ADCP_PS_600: [1×1 struct]
     ADCP_PS_300: [1×1 struct]
        HYDRO_PS: [1×1 struct]
```

## Loading a section by ID

There is a second method `SG.load_section_by_id(survey_name,section_number)` for loading sections. This method reads the start and end times out of the *section definition csv files* and uses them to generate a section. For this to work the filepaths of the section definition files need to be set at the top of *sectionGeneratorDefaults.yml*.

# Setup

This code will most likely not run 'out of the box' because I am not psychic and don't know what the filepaths are on your laptop. You may need to set the filepaths to the netcdf files containing the data yourself.

## Setting the filepaths

These file paths are defined in a *YAML* file called *sectionGeneratorDefaults.yml* which can be found in *SUNRISE2022_code/section* alongside this README and the *sectionGenerator.m* class file. Make a copy of this *YAML* file and place it in your working directory and change the filepaths to what every they need to be.

## Selecting Instruments and Variables

Currently, all three ADCPs, the HYDRO combo file, and the FTMET data for both ships are available. However, you may not want data from all these instruments and you'll almost certainly not want all the variables in these files.

You have the option of changing which instruments and variables get loaded. If we look at the public properties of an instance of the *sectionGenerator* class we see

```
>> SG

SG =

  sectionGenerator with properties:

    PE_section_definition_filepath: ''
    PS_section_definition_filepath: ''
                      ADCP_PE_1200: 1
             ADCP_PE_1200_filepath: 'C:\Users\hildi\Documents\Stanford\Research\SUNRISE2022\testdata\wh1200.nc'
            ADCP_PE_1200_variables: [1×1 struct]
                       ADCP_PE_600: 1
              ADCP_PE_600_filepath: 'C:\Users\hildi\Documents\Stanford\Research\SUNRISE2022\testdata\wh1200.nc'
             ADCP_PE_600_variables: [1×1 struct]
                       ADCP_PE_300: 1
              ADCP_PE_300_filepath: 'C:\Users\hildi\Documents\Stanford\Research\SUNRISE2022\testdata\wh1200.nc'
             ADCP_PE_300_variables: [1×1 struct]
                          HYDRO_PE: 1
                 HYDRO_PE_filepath: 'C:\Users\hildi\Documents\Stanford\Research\SUNRISE2022\testdata\SUNRISE2021_PE_HydroCombo_Processed.nc'
                HYDRO_PE_variables: [1×1 struct]
                          FTMET_PE: 1
                 FTMET_PE_filepath: ''
                FTMET_PE_variables: [1×1 struct]
                      ADCP_PS_1200: 1
             ADCP_PS_1200_filepath: 'C:\Users\hildi\Documents\Stanford\Research\SUNRISE2022\testdata\wh1200.nc'
            ADCP_PS_1200_variables: [1×1 struct]
                       ADCP_PS_600: 1
              ADCP_PS_600_filepath: 'C:\Users\hildi\Documents\Stanford\Research\SUNRISE2022\testdata\wh1200.nc'
             ADCP_PS_600_variables: [1×1 struct]
                       ADCP_PS_300: 1
              ADCP_PS_300_filepath: 'C:\Users\hildi\Documents\Stanford\Research\SUNRISE2022\testdata\wh1200.nc'
             ADCP_PS_300_variables: [1×1 struct]
                          HYDRO_PS: 1
                 HYDRO_PS_filepath: 'C:\Users\hildi\Documents\Stanford\Research\SUNRISE2022\testdata\SUNRISE2021_PE_HydroCombo_Processed.nc'
                HYDRO_PS_variables: [1×1 struct]
                          FTMET_PS: 0
                 FTMET_PS_filepath: ''
                FTMET_PS_variables: [1×1 struct]
```

Each instrument has three class properties e.g. *ADCP_PE_1200*, *ADCP_PE_1200_filepath*, *ADCP_PE_1200_variables*. The first of these is a boolean flag that determining whether that instrument should be included (`true`) or skipped entirely (`false`). The second is obviously the file path to the netcdf containing the data. The third is a *struct* containing variable names and boolean flags e.g.

```
>> SG.ADCP_PE_1200_variables

ans =

  struct with fields:

    trajectory: 0
          time: 1
           lon: 1
           lat: 1
         depth: 1
            dn: 1
             u: 1
             v: 1
           amp: 0
            pg: 0
         pflag: 0
       heading: 0
       tr_temp: 0
     num_pings: 0
         uship: 0
         vship: 0
```

### Changing these properties from the command line

These properties are all editable. So, if I decide I no longer want to include the *ADCP_PE_1200* in my sections I can simply go:

```
>> SG.ADCP_PE_1200 = false

SG =

  sectionGenerator with properties:

              ADCP_PE_1200: 0
     ADCP_PE_1200_filepath: 'C:\Users\hildi\Documents\Stanford\Research\SUNRISE2022\testdata\wh1200.nc'
    ADCP_PE_1200_variables: [1×1 struct]
    .
    .
    .
```

and now if I call `SG.load_section(start_time,end_time)` this data won't be loaded.

### Default Values

You may have noticed that like the filepaths these properties are defined in *sectionGeneratorDefaults.yml*. Therefore, by editing your copy of *sectionGeneratorDefaults.yml* you can change the defaults and avoid having to edit them from the command line.

### Multiple Default Files

It is possible to have multiple default files. The *sectionGenerator* constructor takes an optional argument specifying an alternative *YAML* file. e.g. suppose I create a second default file *sectionGeneratorDefaults_2.yml* then I use this file by calling

`SG = sectionGenerator('sectionGeneratorDefaults_2.yml');`

# TO DO

- [ ] Finalise the implementation of the FTMET netcdf once Pat has a confirmed the file structure
- [ ] Adjust for the final version of Fucent's HYDRO files. Including confirming dimension ordering for *u_star_cint*.
- [x] Implement support for generating sections by survey name and number
- [ ] Change ADCP offset to 2022
- [ ] Try and break it
