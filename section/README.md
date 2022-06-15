# Section Generator

*sectionGenerator* is a matlab class for loading sections of ADCP, VMP/CTD (collectively called HYDRO), and FTMET data.

## Usage

First ensure that you have an up to date version of the **SUNRISE2022_code** directory and that it and its subfolders are on your matlab path. Then, we create an instance of the *sectionGenerator* class:

`>> SG = sectionGenerator();`

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

## Selecting Instruments and Variables

Currently, all three ADCPs, the HYDRO combo file, and the FTMET data for both ships are available. However, you may not want data from all these instruments and you'll almost certainly not want all the variables in these files.

You have the option of changing which instruments and variables get loaded. If we look at the public properties of an instance of the *sectionGenerator* class we see

```
>> SG

SG =

  sectionGenerator with properties:

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

Changing these values from the command line is inconvenient and there is a better way. The default values for these properties are read from a *YAML* file called *sectionGeneratorDefaults.yml*.

To set your own default values make a copy of this file, keeping the same name, and place it in your working directory (or some other directory sufficiently early in your matlab path). You can find the original at *SUNRISE2022_code/section/sectionGeneratorDefaults.yml*. Then, edit away.

### Multiple Default Files

It is possible to have multiple default files. The *sectionGenerator* constructor takes an optional argument specifying an alternative *YAML* file. e.g. suppose I create a second default file *sectionGeneratorDefaults_2.yml* then I use this file by calling

`SG = sectionGenerator('sectionGeneratorDefaults_2.yml');`

# TO DO

- [ ] Finalise the implementation of the FTMET netcdf once Pat has a confirmed the file structure
- [ ] Adjust for the final version of Fucent's HYDRO files. Including confirming dimension ordering for *u_star_cint*.
- [ ] Implement support for generating sections by name
- [ ] Try and break it
