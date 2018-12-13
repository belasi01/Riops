*In-situ* optical data processing with R
================
Simon Bélanger
01/12/2018

# Introduction and scope of the document

Over the years, I have developed an expertize at collecting field
observations, from large icebreakers to small boats, using several type
of optical instruments in support of our research activities in remote
sensing. In aquatic optics, we defined two main types of optical
properties of the water medium: the inherent and apparent optical
properties. IOPs ans AOPs can be measured in situ using submersible
instruments, or remotely using above water radiometry. The purpose of
this document is not to provide the theoritical background of these
measurements. The reader is refered to the NASA or IOCCG protocols that
are widely accepted by the scientific community.

Instead, the present document aims at helping the students to process
their raw data collected on the field and convert them into IOPs or
AOPs. Almost every IOPs or AOPs requires some kind of corrections to end
up with a valid physical quantity. I have implemented most of these
corrections in the R language, which is free and widely use in science.
In 2016, I decided to gather the code in several R packages that I am
sharing via the Open Source repository GitHub
(<https://github.com/belasi01>). That includes the folllowing packages:

  - `Cops` : This package was initially developped by Bernard Gentilly
    at the Laboratoire d’Océanologie de Villefranche (LOV) for the COPS.
    The COPS is a Compact Optical Profilling System commercialized by
    Biospherical instruments. We have updated the package and implement
    new functions. This is an ongoing work.
  - `Riops` : I developped this package first for our optical package
    that included an a-sphere and a HydroScat-6 from HobiLabs, a Sesbird
    CTD and a ECO-triplet from WetLabs. Later I adapted the code to
    process WetLabs AC-s, BB-9, BB-3 and FLBBTR.
  - `asd` : this package can process ASD data (Analytical Spectral
    Device) for both calculating land and water surface reflectance
    (i.e. the water reflectance or Rrs). I have written a User’s Guide
    specifically for this package (available only in French to date).
  - `HyperocR` : this package was first developped for the HyperSAS data
    processing which allows simultaneous above-water measurements of the
    water surface, the sky radiances and the downwelling irradiance. It
    can calculate the reflectance (Rrs) at fixed station or along ship
    transects.
  - `RspectoAbs` This package was written to process spectrophotometric
    measurement in the laboratory (for \(a_{CDOM}\) and \(a_p\)).

I will provide you some tips to get started with the processing of your
data. It will be the support document of a data workshop that will be
held in Rimouski in December 2018.

# Data folders and files structure for in-water vertical profiles.

In 2012, we have adopted a systematic way to store our raw data
collected in the field. Most of the time, field data are store in
different folders, often one folder per instrument or one folder for a
given date, etc. When I come back from the field I tend to copy the data
folders in a folder **./L1/**. Then I create another folder, **./L2/**
where I will organize the data in a more systematic way. In fact, some
the code is adapted to work with this predefined way to organize the raw
data in sub-folders. It therefore important to respect the following
instructions to avoid potential problems…

You have to create **one folder per station**. The folder name contains
the date and the Station ID. That is

**./L2/YYYYMMDD\_StationID/**

In this folder, you can then create one subfolder for each type of
measure (COPS, IOPs, ASD, etc.). Then you put your raw data in their
respective sub-folder.

For example, supposed you have visited the station P1 on the 6th of June
2015. You deployed the COPS (three profile) and one IOP package. So you
will create one folder for the station:

**./L2/20150606\_StationP1/**

Next you will create one subfolder for the COPS data and one for the
IOPs.

**./L2/20150606\_StationP1/COPS/** and
**./L2/20150606\_StationP1/IOPs/**

Next, simply copy your raw files for that station in the appropriate
subfolder. It takes some time to organize at first but is easy to
retrieve the data later (even many years later). An example is given on
the next figure
.

<embed src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/StructureRep.pdf" title="Example of folders structure. The sub-folders in the COPS folder are generated when processing the data using R (see below). The raw COPS data are highlighted in yellow. \label{FolderStructure}" alt="Example of folders structure. The sub-folders in the COPS folder are generated when processing the data using R (see below). The raw COPS data are highlighted in yellow. \label{FolderStructure}" width="100%" type="application/pdf" />

# The COPS data processing

## Preparation

In the field, we always document the deployement operations in a log
sheet. Make sure you have this log sheet in hand before starting. This
will save you a lot a time. In fact, it is common that a bad profile was
recorded in the field for any reason. For example:

  - The reference sensor (Ed0) was shaded during the profile or the
    profiler went below the boat;
  - The profile was started too late and the top layer were missed;
  - The operator start a profile but the boat start to move, draggind
    the instrument at the surface while recording;
  - The acquisition was stated accidentally during the upcast;
  - etc.

Normally this kind of problem should be logged and the data can be
discarded before trying to process them. Usually, we don’t have time on
the boat to delete the data.

The log file should also provide insight about the profile quality. This
can really help when it is the time to quality control the data.

## Installation of the Cops package

As any other package available on GitHub, the installation is
straitforward using the `devools` package utilities, i.e.:

``` r
devtools::install_github("belasi01/Cops")
```

This will install the binaries and all the dependencies, which can take
some times.

To install the full code sources, you can also “clone” the package in a
local folder. You have to create a “New project…” from the file menu and
choose the “Version Control” project type, and then choose “Git” option.
Next you have to indicate the full path of the R package repository on
GitHub, as illustrate
below.

<embed src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/git.pdf" title="Clone the package from GitHub to have a full access to source code." alt="Clone the package from GitHub to have a full access to source code." width="50%" type="application/pdf" />

## Step 0 : Get stated with Cops processing and configuration of the INIT file

Unfortunately, most function of the `Cops` package does not have a help
page. This is because the user **only need to know one single function**
to launch the processing, i.e. the `cops.go()`. So let’s get
    started.

``` r
library(Cops)
```

    ## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ## TO BEGIN A PROCESSING AND PRODUCE WINDOWS PLOTS, TYPE : cops.go()
    ## TO BEGIN A PROCESSING AND PRODUCE   PDF   PLOTS,     TYPE : cops.go(interactive = FALSE)
    ## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

As you can see, when you load the package with the `library()` function,
you got a message saying:

  - TO BEGIN A PROCESSING AND PRODUCE WINDOWS PLOTS, TYPE : cops.go()
  - TO BEGIN A PROCESSING AND PRODUCE PDF PLOTS, TYPE :
    cops.go(interactive = FALSE)

I strongly recommanded to first set the working directory (i.e. a folder
were you put the COPS data for a given station) using `setwd()` and than
type `cops.go(interactive = FALSE)`. See what happen.

``` r
setwd("/data/ProjetX/L2/20500619_StationY1/cops")
cops.go(interactive = FALSE)
```

You will get the following message:

**CREATE a file named directories.for.cops.dat in current directory
(where R is launched) and put in it the names of the directories where
data files can be found (one by line)**

In the present example, I will create a very simple ASCII file named
**directories.for.cops.dat** in my working directory in which I will put
the full path of the folder I want to process,

/data/ProjetX/L2/20500619\_StationY1/cops

One can process as many folders as wanted, but I don’t recommand that
when you process the COPS data for a given station for the first time.
In fact you need to quality control each vertical profile (one by one).
That being said, the batch processing is very useful when the code
change, which could appen in the future. So, after the QC at the end of
the processing, I generally create a **directories.for.cops.dat** file
in the **./L2/** folder containing all the station folder paths.

You can launch again the code.

``` r
cops.go(interactive = FALSE)
```

This time you get the following message:

**@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
PROCESSING DIRECTORY C:/data/ProjetX/L2/20500619\_StationY1/cops
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ EDIT
file C:/data/ProjetX/L2/20500619\_StationY1/cops/init.cops.dat and
CUSTOMIZE IT**

As you can see, the program has created a file named **init.cops.dat**
in your working directory. This file contains several informations that
are required in the data processing but also for reading the data
properly. In general, the parameters (or global variable) found in the
init.cops.dat file remains the same for all station for a given field
campaign.

You have to edit the following lines:

  - **instruments.optics;character;Ed0,EdZ,LuZ** : The
    *instruments.optics* variable is a vector of three character strings
    indicating which type of sensor was available on the current COPS
    configuration. The default is Ed0 (above water surface irradiance),
    EdZ (in-water downwelling irradiance) and LuZ (in-water upwelling
    radiance). Some systems may have EuZ (in-water upwelling irradiance)
    instead of LuZ. The `Cops` package version 3.2-5 and greater can
    process COPS systems having both LuZ and EuZ. In that case, all
    other fields must have 4 parameters instead of 3.
  - **tiltmax.optics;numeric; 10,5,5** : the *tiltmax.optics* is a
    numeric vector of three threshold values used to filter the data for
    the three sensors available in *instruments.optics*. Here the
    default (10,5,5) will eliminate every data collected when the Ed0
    instrument tilt was greater than 10 degrees and when EdZ or LuZ tilt
    were greater than 5 degrees, as recommended by NASA protocols.  
  - **time.interval.for.smoothing.optics;numeric; 40,40,40** The
    *time.interval.for.smoothing.optics* variable is a tricky one. It is
    used to smooth the data on a regular depth interval grid using a
    method known as LOESS (local polynomial regression fitting) which is
    a non-parametric method usually employed to smooth time-series (but
    here applied to light profile). LOESS compute polynomial on the data
    for a given window size that is moving along the profile. The value
    of 40 represent about 3 seconds of measurements. The larger the
    value, the smoother the fitted profile. These parameters (one by
    sensor) often need to be adjusted for a given profile. In shallow
    turbid waters for example, one should use values closer to 20… There
    is no clear rules to set these values. This is why I have
    implemented a linear interpolation scheme to extrapolate the surface
    values to calculate the water-leaving radiance (see Bélanger et al.
    (2017)).
  - **sub.surface.removed.layer.optics;numeric; 0, 0.1, 0** : The
    *sub.surface.removed.layer.optics* variable is use to exclude the
    data very close the air-sea interface. In fact, near-surface data
    may be very noisy due to wave focusing effect under clear sky. It is
    mostly important for EdZ. By default, we eliminate the first 10 cm
    (0.1 m) of the water column for EdZ, also because the sensor may
    exits the water a fraction of second when the profiler it at the
    surface.
  - **delta.capteur.optics;numeric; 0, -0.09, 0.25** : The
    *delta.capteur.optics* variable a numeric vector of three values
    indicating the physical distance between the pressure sensor and the
    actual radiometers. By default, we assume that the EdZ sensor is 9
    cm abovethe pressure sensor (so minus 9 cm relative to the measured
    pressure), which is normally on the back of the LuZ sensor. The LuZ
    sensor length is about 25 cm below the pressure sensor (so we have
    to add 25 cm to get the depth of the LuZ measurement). This setup is
    quite standard and will not change unless you physically change the
    setup (e.g. is EuZ is used instead of LuZ).
  - **radius.instrument.optics;numeric; 0.035, 0.035, 0.035** : The
    *radius.instrument.optics* variable a numeric vector of three values
    of instrument radius that will be used in the shadow correction. All
    sensor are 3.5 cm radius. (Note that this variable could be hard
    coded as it never change).

The next parameters are important for reading the data correctly. You
need to look into one profile to see how the data are written in the
files.

  - **format.date;character;%d/%m/%Y %H:%M:%S** : The *format.date*
    variable is a string indicating how the date and time are written in
    the file. This can change depending on the regional setting of the
    computer used to record the data on the field. The default assumes
    %d/%m/%Y %H:%M:%S but we often encountered %m/%d/%Y %H:%M:%S. You
    may need to read the help about `POSIXct` representing calendar
    dates and times format in R.  
  - **instruments.others;character;Master** : The *instruments.others*
    variable is single string indicating whether or not an other
    intrument is included in the COPS files. In the old COPS data
    acquisition (before 2014 or so), the data file included diagnostic
    information on the system (input voltage to instrument, temperature,
    etc.) in columns that were named Master+VariableName. These data are
    now stored in a separate file. So YOU WILL LIKELY have to put NA (in
    capital letters) instead of Master if you’re working with recent
    COPS data.  
  - **depth.is.on;character;LuZ** : The *depth.is.on* variable inditace
    on which radiometer the pressure sensor is located. Default is LuZ
    but may be EuZ if you are using another set up.  
  - **number.of.fields.before.date;numeric; 0** :
    *number.of.fields.before.date* variable is a numeric value
    indicating the number of field present in the file name before the
    date. In fact, every COPS file are automatically named continaing
    the date and time of the acquisition (computer date/time when the
    file was created). Suppose you have a file named
    *06-261\_CAST\_004\_180813\_150418\_URC*, there are 3 fields
    separated by "\_" before the date. So here we would put 3 instead of
    0 (default value).

As mentioned above, the **init.cops.dat** file should not change much
from one station to another and can be copy/paste to every folder you
want to
process.

## Step 1 : Configure the **info.cops.dat** file and run the code for the first time to generate results

Once you are set with the **init.cops.dat** file, you can launch again
the code.

``` r
cops.go(interactive = FALSE)
```

This time you get the following message:

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
**PROCESSING DIRECTORY C:/data/ProjetX/L2/20500619\_StationY1/cops**
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ **Read
17 items** **EDIT file
C:/data/ProjetX/L2/20500619\_StationY1/cops/info.cops.dat and CUSTOMIZE
IT this file must contain as much lines as cops-experiments you want to
process you will find a header with instructions to fill this file**

Now if you look into the working directory, you will find a file named
**info.cops.dat**. This is another ASCII file you need to edit. As
mentioned above, the header of that file provides instruction on how to
arrange the information to process each light profiles you have in your
working directory. The header lines start with a “\#”. After the header,
you have to provide a line for each profile you want to process. Each
line will need to have 8 mandatory fields separated by “;”. The created
file already contains one line per file found in the working disrectory.
The first field is the file name. So you have to remove the lines that
are not corresponding to calibrated light profile file (e.g. the
init.cops.dat or the GPS file). Then you have to set the processing
parameters for each line.

  - The fields number 2 and 3 are the **longitude** and **latitude** in
    decimal degree, respectively. You have to provide them to allow the
    code to compute the sun position in the sky. This is mandatory. If
    your system was fitted with a BioGPS, you have to copy the GPS file
    in the working directory and put NA in fields 2 and 3. The code will
    retreive the position of the profile automatically. **NOTE: Sometime
    you may get an error when reading the GPS file. This is because a
    header line may be found in the middle of the file. This happen
    because only create one GPS file per day. If the file exists when
    restating the COPS, it will happen the data at the end of the
    existing file. You have to clean the GPS file by removing header
    lines (except the first line of the file).**

  - The field number 4 is for the **shadow correction** method to use
    for calculating the water-leaving radiance and the reflectance (NA,
    0 or a decimal value). The instrument shadow effect has been
    described in Gordon and Ding (1992) and Zibordi and Ferrari (1995).
    The correction they proposed requires the total spectral absorption
    coefficients of the surface water. There is three options: if NA, no
    correction is applied; if 0, you have to provide the absorption
    coefficients for all wavelengths in a file called
    **absorption.cops.dat**; if a decimal value is provided, the code
    will assume it as the chlorophyll-a concentration and estimate
    empirically the absorption value using a Case-1 water bio-optical
    model (Morel and Maritorenna, JGR 2001).

  - The field number 5 is the **time window**, which is the number of
    seconds after the start of the recording corresponding to the actual
    begining and the end of the cast, respectively.

When you process the data for the first time, the fields 4 to 8 can be
leave as is. The processing will take the default values found in
**init.cops.dat** for fields 6 to 8. The later fields were described
above and they stand for *sub.surface.removed.layer*, *tiltmax.optics*,
and *time.interval.for.smoothing*. All of them contains 3 (or 4) values
separated with “,” for each sensors.

You can launch again the code.

``` r
cops.go(interactive = FALSE)
```

Normally the code will run without errors, except if the data is not
good (a very bad profile that was recorded by error on the field) or if
you have made a mistake in the **init.cops.dat** file (e.g. often you
did not changed Master to NA for field *instruments.others*, or you made
a mistake in the date/time format, etc.) or if the data file was
recorded specifically for the Bioshade
measurements.

## Step 2: Preliminary analysis of the results output and processing parameters adjustment for each profiles

First of all, when the code is run without error, it creates two (or
three) new directories (BIN/, PDF/, and optionnaly ASC/) in the working
directory as well as two ASCII files names **absorption.cops.dat** and
**remove.cops.dat**. The former is the file you have to edit if you want
to correct for instrument self-shaddow effect (see above) using measured
absorption coefficients (one line per profile). The **remove.cops.dat**
file lists the same file names found in **info.cops.dat** follow by a
semi-column and an integer (0,1 or 2). By default, all file are set to
1, which consider a normal light profile. To remove profile, we change
the integer to 0. If the file is a Bioshade measurement, we change the
integer to 2.

Let’s focus now on the PDF/ directory in which one PDF per profile was
generated. You will have to open each PDF and analyse the results to
adjust the processing parameters.

### Step 2.1 : Set the right **time.window** field

The first thing to check is the second page of the PDF document showing
the pressure, or depth of the profiler, versus time in second since the
begining of the
recording.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/time.window1.png" title="Example of pressure or depth of the profiler versus time in second since the begining of the recording" alt="Example of pressure or depth of the profiler versus time in second since the begining of the recording" width="50%" />

The title of the plot provides the date/time, the duration of the cast,
the position and the sun zenith angle. Check this information if it is
correct. In that example the cast duration was 31 seconds. The profiler
was at the surface right at the begining and reach the bottom after
about 25 seconds. So for this cast the *time.window* variable (field
\#5) would be set to 0,25 or 1,25 if you want to remove the first
second. To decide if we keep the begining of the cast we can look at the
instrument tilt during the
profile.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/tilt1.png" title="Example of instrument tilt for Ed0 and EdZ (i.e. the profiler) during the cast" alt="Example of instrument tilt for Ed0 and EdZ (i.e. the profiler) during the cast" width="70%" />

Here the tilt below the threshold (10 for Ed0 and 5 for Edz and LuZ)
even near the surface. So we could keep the begin of the cast and edit
the **info.cops.dat** as
:

06-261\_CAST\_001\_180813\_150034\_URC.csv;-53.04958;47.4004;NA;0,25;x;x;x

If I reprocess the file with this new parameter, I will obtain the
following
plots.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/time.window2.png" title="Example of pressure or depth of the profiler versus time in second since the begining of the recording. Red points have been discarded for the rest of the analysis using the time.window field." alt="Example of pressure or depth of the profiler versus time in second since the begining of the recording. Red points have been discarded for the rest of the analysis using the time.window field." width="50%" />

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/tilt2.png" title="Example of instrument tilt for Ed0 and EdZ (i.e. the profiler) during the cast. Red points have been discarded for the rest of the analysis using the time.window field." alt="Example of instrument tilt for Ed0 and EdZ (i.e. the profiler) during the cast. Red points have been discarded for the rest of the analysis using the time.window field." width="70%" />

Note that this step can be avoid if the data are clean using the Shiny
App developped by Guislain Bécu. This application can be downloaded from
<https://github.com/GuislainBecu/01.COPS.CLEAN.INPUT.FILES>

### Step 2.2 : Check the instrument tilt near the surface (**tiltmax.optics** field)

In the above example, the tilt was not a problem. It is some time very
difficult to keep the COPS vertical (strong current or wind, too much
tension in the cable, etc). The following example shows and extreme case
we encountered in the Labrador Sea in 2014. Keeping the tilt threshold
at 5 the for the in-water sensors would have remove nearly all the data.
So we increase the threshold to 10 degree for that profile. This may be
acceptable in the open ocean when the profiler is far from the
ship.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/tilt3.png" title="Example of instrument tilt for Ed0 and EdZ (i.e. the profiler) during the VITALS cruise in 2014 onboard the Hudson" alt="Example of instrument tilt for Ed0 and EdZ (i.e. the profiler) during the VITALS cruise in 2014 onboard the Hudson" width="70%" />

### Step 2.3 : Check the dowelling irradiance conditions during the cast.

Downwelling irradiance above water (Ed0) must be stable during a light
profile. Cloudy sky can make it highly variable. Some shadow on the
instrument from the ship structure a person near by (on small boat
sometime) can be a problem. Big change in Ed0 will likely results in a
bad light profile because LuZ and EdZ are normalized by the Ed0
variability (see NASA
protocols).

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/Ed0_1.png" title="Example of stable Ed0 conditions during a vertical profile" alt="Example of stable Ed0 conditions during a vertical profile" width="70%" />

In this example, Ed0 was very stable. The variability was due to tilt of
the instrument probably resulting from a moving boat by waves. The LOESS
smoothing completely remove these artefacts. In this example, the
conditions were perfect.

The next example shows a drastic drop in Ed0 during a profile. This kind
of unstable conditions is bad for the rest of the data processing. This
profile should be discarded. To do so, you need to edit the file
**remove.cops.dat** but changing the value of 1 to 0 for that
file.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/Ed0_2.png" title="Example of an unstable Ed0 conditions during a vertical profile" alt="Example of an unstable Ed0 conditions during a vertical profile" width="70%" />

### Step 2.4 : Check the quality of the LuZ or EuZ extrapolation to the surface and the overall fitting quality

One of the most important thing to check when processing COPS data is
the quality of the extrapolation of the upwelling radiance or irradiance
at the sea surface. This will determine the quality the remote sensing
reflectance, which is one of the most important AOP. In the current
version, there is two methods implemented to extrapolate to the sea
surface: the LOESS and a linear fit on the log-transformed radiance or
irradiance profile near the surface.

The following plot allow you to evaluate the quality of the LuZ
extrapolation to the surface (x = 0-). The first plot is a zoom on the
top 5 meters of the water
column.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/LuZ.extrapol2_fit40.png" title="Example of LuZ extrapolation to the surface (z=0-) using non-linear fitting with LOESS method (solid line) and the linear method (dashed line) described in Bélanger et al (2017). COPS measurements are the small dots while the big solid circles indicate the maximum depth used to make the linear extrapolation of LuZ to 0- depth. " alt="Example of LuZ extrapolation to the surface (z=0-) using non-linear fitting with LOESS method (solid line) and the linear method (dashed line) described in Bélanger et al (2017). COPS measurements are the small dots while the big solid circles indicate the maximum depth used to make the linear extrapolation of LuZ to 0- depth. " width="100%" />

In this shallow water example, the increase in LuZ near the bottom is
NOT an artefact. It is due to the bottom reflectance which reflect a
large fraction of the EdZ that reached the bottom. So the LuZ at the
bottom is then being attenuated upward above th bottom. For an
insightful discussion, please refer to Maritorena and Morel (L\&O,
1994).

The next plot is good to appreciate the overall quality of the LOESS fit
for each 19
wavelenghts.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/Luz.Fit1.png" title="Example of LuZ fitted with the LOESS method for each individual channels." alt="Example of LuZ fitted with the LOESS method for each individual channels." width="100%" />

Note the depth at which the instrument noise is reached (about 1e-5). At
330 nm, LuZ is in the noise at almost all depths, while the 380 nm and
412 nm channels reach the noise at about 0.8 m and 1.5 m depth,
respectively. Overall the fit is pretty good but not perfect. It can be
improved by using a slightly smaller value for
*time.interval.for.smoothing.optics* for LuZ. I would recude it from 40
to 20. Compare the
results.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/LuZ.extrapol2_fit40vs20.png" title="Comparison of *time.interval.for.smoothing.optics* values of 40 versus 20." alt="Comparison of *time.interval.for.smoothing.optics* values of 40 versus 20." width="100%" />

The improvement of the non linear fit is obvious for 875 nm. The linear
versus non-linear extrapolation to the sub-surface are also in better
agreement. Note that the linear extrapolation at 412 nm was not good.

This step may require to run the code several times before finding the
best parameters.

### Step 2.5 : Check the quality of the EdZ fit quality

As for LuZ, we check whether the LOESS parameters need adjustment to fit
the measurements. In the following plot, the default
*time.interval.for.smoothing.optics* of 40 works well, except at 320 and
380 nm because of the noise. In addition, we can see that the EdZ are
more noisy compare to LuZ due to wave focusing effect. This is expected
under clear sky and wavy
surface.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/EdZ.Fit1.png" title="Example of EdZ fit with the LOESS" alt="Example of EdZ fit with the LOESS" width="100%" />

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/EdZ.Fit1_by_waves.png" title="Example of EdZ fit with the LOESS for each wavelength" alt="Example of EdZ fit with the LOESS for each wavelength" width="100%" />

The following plot is obtained *time.interval.for.smoothing.optics* of
20, which improve significantly the improve the fit at 320 and 380
nm.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/EdZ.Fit2.png" title="Example of EdZ fit with the LOESS using time window of 20 instread of 40" alt="Example of EdZ fit with the LOESS using time window of 20 instread of 40" width="100%" />

### Step 3 : Compare replicates

Once each profile was processed with appropriate values for the
*time.window*, *tiltmax.optics* and *time.interval.for.smoothing.optics*
fields, then we compare the profile. Two plots are generated for Rrs and
Kd (from the surface layer) with every file set to 1 in the file
**remove.cops.dat**. The solid lines are for the LOESS methe while the
dashed lines is for the linear
extrapolation.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/Kd_all.png" title="Example of 6 replicates for Kd" alt="Example of 6 replicates for Kd" width="50%" />

For Kd, there is not obvious difference among replicates or
methods.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/Rrs_all.png" title="Example of 6 replicates for Rrs" alt="Example of 6 replicates for Rrs" width="50%" />

In general, there are always more differences in Rrs due to the
extrapolation. In this example, we found some differences:

  - The linear extrapolation yield lower Rrs values at all wavelengths.
    This is often the case in very absorbing waters as the one observed
    here.
  - The LOESS function yield an artefact at 412 nm (5 out of 6 spectra)
    that is obviously not realistic.
  - the shape of the cast number 3 differs markedly from the other.
    Further examination of the data from this cast revealed that is was
    made in only 3 m depth while all other cast were in about 4.5 m
    depth.

So for this station we should:

  - eliminate the cast number 3;
  - use the linear exprapolation for Rrs.

### Step 4: Remove outlier and document the data processing

In the above example, the cast number 3 must be flag, or remove for
further data procesessing. Again, we do that by editing the file
**remove.cops.dat** such as:

06-261\_CAST\_001\_180813\_150034\_URC.csv;1

06-261\_CAST\_002\_180813\_150144\_URC.csv;1

06-261\_CAST\_003\_180813\_150255\_URC.csv;0

06-261\_CAST\_004\_180813\_150418\_URC.csv;1

06-261\_CAST\_005\_180813\_150545\_URC.csv;1

06-261\_CAST\_006\_180813\_150800\_URC.csv;1

You can also check again the comments logged by the field operators. It
usually help to identify the cast that may be better than the other.

It is also important to document the data processing in a log file. I
usualy fill an EXCEL file with the following columns: COPS File name;
Station; kept; Processing comments. In the later column I would explain
why I did not kept the profile (here it was shallower than the other
cast).

### Step 5 : Instrument self-shading correction

To complete the data processing, you should consider to correct for the
instrument self-shading. This is done by choosing one of the
*shadow.correction* method (field number 4 in the **info.cops.dat**
file) to use for calculating the water-leaving radiance and the
reflectance. As most of our work are in coastal or in-land or Arctic
waters, I strongly recommand to set the *shadow.correction* to 0 and
provide the total absorption coefficients for all wavelengths in the
**absorption.cops.dat** file. Exceptionnaly, if you don’t have
absorption measurement and you work in oceanic water, you can provided
the chlorophyll-a concentration and the Case-1 water bio-optical model
of Morel and Maritorenna (JGR 2001) will be employed.

Absorption coefficients can be measured using in-water instruments, such
as AC-s or a-sphere, or from discrete samples for CDOM and particulate
matter using filter pad thecnique. If in-water coefficients are
available, it will be relatively strait forward to edit the
**absorption.cops.dat** file using `compute.aTOT.for.COPS()` function
from the `Riops` package (see below).

If only discrete samples is available, the **absorption.cops.dat** file
may be edited using `compute.discrete.aTOT.for.COPS()` function from the
`RspectroAbs` package (under construction).

The importance of this correction can be visualised in the PDF document
in the page showing the various water-leaving radiances and reflectances
spectra. The next figure shows a typical Case-2 water case. The
correction is relatively important in the NIR and UV
bands.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/Rrs_with_ShadowCorrection.png" title="Example of Rrs and shadow correction coefficient" alt="Example of Rrs and shadow correction coefficient" width="80%" />

### Step 6 : Generate the data base

Once you have processed all station individually and discard the cast
you consider of lower quality, then you can easily generate a database.
You have to create an ASCCI file named **directories.for.cops.dat** in
the parent folder of the stations folder, i.e. for example

/data/ProjetX/L2/

and put all the station paths you want to include in the data base. Next
you can run the `generate.cops.DB()`. This function compute mean and
standard deviation of selected parameters using the profiles that passed
the QC (as found in **remove.cops.dat** file). The folowing parameters
are computed :

  - *Kd1p*: is the mean spectral diffuse attenuation from the surface to
    the 1% light level for each wavelength (2 matrices for mean and
    s.d.)  
  - *Kd10p*: is the mean spectral diffuse attenuation from the surface
    to the 10% light level for each wavelength (2 matrices for mean and
    s.d.)
  - *Rrs*: is the mean spectral Remote sensing reflectance (2 matrices
    for mean and s.d.)
  - *Ed0.0p*: is the mean spectral incident irradiance at surface (2
    matrices for mean and s.d.)
  - *Ed0.f*: is the modeled or measured (with Bioshade) fraction of
    diffuse skylight to the total downwelling irradiance (matrix)
  - *Ed0.f.measured*: is a flag indicating whether *Ed0.f* was measured
    using the BioShade (=1) or modelled using the Gregg and Carder
    (1990) model (=0)
  - *date*: is a vector of date in POSIXCT format
  - *lat*: is a vector of latitude
  - *lon*: is a vector of longitude
  - *sunzen*: is a vector of solar zenith angle
  - *waves*: is a vector of wavelenghts

The object COPS.DB is saved in RData format. The data are also saved in
ASCII (.dat with comma separator) and a figure showing the measured
\(\rho_w\) spectra of the data base is produced.

``` r
COPS.DB <- generate.cops.DB(path="/data/ProjetX/L2/", 
                            waves.DB = c(412,443,490,555), 
                            mission = "MISSION_IMPOSSIBLE")
```

Note here that you can select the actual wavelengths to include in the
database. In th e example above I only selected 4 channels. The default
wavelenths are (from the former UQAR config): 305, 320, 330, 340, 380,
412, 443, 465, 490, 510, 532, 555, 589, 625, 665, 683, 694, 710,
780.

``` r
load("/Users/simonbelanger/MEGA/data/VITALS/2014/L2/COPS.DB.VITALS2014.RData")
str(COPS.DB)
```

    ## List of 15
    ##  $ waves         : num [1:18] 320 330 340 380 412 443 465 490 510 532 ...
    ##  $ Rrs.m         : num [1:6, 1:19] NA NA NA NA NA ...
    ##  $ Kd.1p.m       : num [1:6, 1:19] NA NA NA NA NA ...
    ##  $ Kd.10p.m      : num [1:6, 1:19] NA NA NA NA NA ...
    ##  $ Ed0.0p.m      : num [1:6, 1:19] NA NA NA NA NA ...
    ##  $ Rrs.sd        : num [1:6, 1:19] NA NA NA NA NA ...
    ##  $ Kd.1p.sd      : num [1:6, 1:19] NA NA NA NA NA ...
    ##  $ Kd.10p.sd     : num [1:6, 1:19] NA NA NA NA NA ...
    ##  $ Ed0.0p.sd     : num [1:6, 1:19] NA NA NA NA NA ...
    ##  $ Ed0.f         : num [1:6, 1:19] 0 0 0 0 0 ...
    ##  $ Ed0.f.measured: num [1:6] 0 0 0 1 1 1
    ##  $ date          : POSIXct[1:6], format: "2014-05-08 14:55:37" "2014-05-09 15:35:56" ...
    ##  $ sunzen        : num [1:6] 42.1 43.4 43.6 48.6 35.6 ...
    ##  $ lat           : num [1:6] 59.1 60.5 59.7 55.3 53.8 ...
    ##  $ lon           : num [1:6] -49.9 -48.3 -49.2 -53.9 -52.8 ...

## Data format

The /BIN folders contain the binary data stored in the RData format.
These files contain list of variables named *cops*. All the information
for a given cast is store in these data structure. This is very easy in
R to deal with this type of data. The example below contains as much as
89 variables, including processing parameters, raw data, fitted data and
so
on.

``` r
load("~/MEGA/data/BoueesIML/2015/L2/20150630_StationIML4/COPS/BIN/IML4_150630_1339_C_data_004.csv.RData")
str(cops)
```

    ## List of 89
    ##  $ verbose                           : logi TRUE
    ##  $ indice.water                      : num 1.34
    ##  $ rau.Fresnel                       : num 0.043
    ##  $ win.width                         : num 9
    ##  $ win.height                        : num 7
    ##  $ instruments.optics                : chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ tiltmax.optics                    : Named num [1:3] 5 5 5
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ time.interval.for.smoothing.optics: Named num [1:3] 40 50 40
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ sub.surface.removed.layer.optics  : Named num [1:3] 0 0 0
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ delta.capteur.optics              : Named num [1:3] 0 -0.09 0.25
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ radius.instrument.optics          : Named num [1:3] 0.035 0.035 0.035
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ format.date                       : chr "%m/%d/%Y %H:%M:%S"
    ##  $ instruments.others                : chr "NA"
    ##  $ depth.is.on                       : chr "LuZ"
    ##  $ number.of.fields.before.date      : num 1
    ##  $ time.window                       : num [1:2] 11 1000
    ##  $ depth.discretization              : num [1:19] 0 0.01 1 0.02 2 0.05 5 0.1 10 0.2 ...
    ##  $ file                              : chr "IML4_150630_1339_C_data_004.csv"
    ##  $ chl                               : logi NA
    ##  $ SHADOW.CORRECTION                 : logi TRUE
    ##  $ absorption.waves                  : num [1:19] 305 320 330 340 380 412 443 465 490 510 ...
    ##  $ absorption.values                 : Named num [1:19] 5.09 4.07 3.51 3.02 1.67 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ blacks                            : chr(0) 
    ##  $ Ed0                               : num [1:1925, 1:19] 0.728 0.728 0.728 0.728 0.728 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : NULL
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ EdZ                               : num [1:1925, 1:19] 0.00575 0.00387 0.00608 0.00624 0.00601 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : NULL
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ LuZ                               : num [1:1925, 1:19] -2.73e-05 -5.64e-06 -2.91e-05 -2.98e-05 -2.96e-05 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : NULL
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ Ed0.anc                           :'data.frame':  1925 obs. of  2 variables:
    ##   ..$ Roll : num [1:1925] -0.0699 -0.0699 -0.1398 -0.0699 0 ...
    ##   ..$ Pitch: num [1:1925] 0.909 0.769 0.699 0.559 0.489 ...
    ##  $ EdZ.anc                           :'data.frame':  1925 obs. of  2 variables:
    ##   ..$ Roll : num [1:1925] -0.979 -0.839 -1.328 -1.258 -0.699 ...
    ##   ..$ Pitch: num [1:1925] 17.1 16.1 13.5 12.6 13 ...
    ##  $ LuZ.anc                           :'data.frame':  1925 obs. of  2 variables:
    ##   ..$ Depth: num [1:1925] 1 0.988 0.98 0.965 0.951 ...
    ##   ..$ Temp : num [1:1925] 8.78 8.81 8.79 8.8 8.79 ...
    ##  $ Ed0.waves                         : num [1:19] 305 320 330 340 380 412 443 465 490 510 ...
    ##  $ EdZ.waves                         : num [1:19] 305 320 330 340 380 412 443 465 490 510 ...
    ##  $ LuZ.waves                         : num [1:19] 305 320 330 340 380 412 443 465 490 510 ...
    ##  $ Others                            :'data.frame':  1925 obs. of  6 variables:
    ##   ..$ GeneralExcelTime : num [1:1925] 42186 42186 42186 42186 42186 ...
    ##   ..$ DateTime         : chr [1:1925] "06/30/2015 14:11:30" "06/30/2015 14:11:30" "06/30/2015 14:11:31" "06/30/2015 14:11:31" ...
    ##   ..$ DateTimeUTC      : chr [1:1925] "06-30-2015 02:11:30.906 " "06-30-2015 02:11:30.968 " "06-30-2015 02:11:31.031 " "06-30-2015 02:11:31.093 " ...
    ##   ..$ Millisecond      : int [1:1925] 906 968 31 93 171 234 296 359 421 500 ...
    ##   ..$ BioGPS_Position  : num [1:1925] 10 141132 -6834 4840 10 ...
    ##   ..$ BioShade_Position: int [1:1925] 31289 31289 31289 31289 31289 31289 31289 31289 31289 31289 ...
    ##  $ file                              : chr "IML4_150630_1339_C_data_004.csv"
    ##  $ potential.gps.file                : chr "IML4_150630_1339_gps.csv"
    ##  $ Ed0.tilt                          : num [1:1925] 0.911 0.772 0.713 0.564 0.489 ...
    ##  $ EdZ.tilt                          : num [1:1925] 17.1 16.1 13.5 12.7 13.1 ...
    ##  $ LuZ.tilt                          : NULL
    ##  $ change.position                   : logi FALSE
    ##  $ longitude                         : num -68.6
    ##  $ latitude                          : num 48.7
    ##  $ dates                             : POSIXct[1:1925], format: "2015-06-30 14:11:30" "2015-06-30 14:11:30" ...
    ##  $ date.mean                         : POSIXct[1:1], format: "2015-06-30 14:12:38"
    ##  $ cops.duration.secs                : num 115
    ##  $ day                               : num 30
    ##  $ month                             : num 6
    ##  $ year                              : num 2015
    ##  $ sunzen                            : num 38.3
    ##  $ Depth                             : num [1:1925] 1 0.988 0.98 0.965 0.951 ...
    ##  $ Depth.good                        : logi [1:1925] FALSE FALSE FALSE FALSE FALSE FALSE ...
    ##  $ depth.fitted                      : num [1:332] 0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 ...
    ##  $ Ed0.th                            : num [1:19] NA 31.8 47.2 49.1 65.8 ...
    ##  $ Ed0.0p                            : num [1:19] 0.739 22.587 42.821 47.517 61.878 ...
    ##  $ Ed0.fitted                        : num [1:332, 1:19] 0.739 0.739 0.739 0.739 0.739 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : chr [1:332] "0" "0.01" "0.02" "0.03" ...
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ Ed0.correction                    : num [1:1925, 1:19] 1.01 1.01 1.01 1.01 1.01 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : NULL
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ LuZ.fitted                        : num [1:332, 1:19] 2.23e-05 2.22e-05 2.21e-05 2.20e-05 2.19e-05 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : chr [1:332] "0" "0.01" "0.02" "0.03" ...
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ KZ.LuZ.fitted                     : num [1:331, 1:19] 0.514 0.513 0.512 0.512 0.511 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : chr [1:331] "0.01" "0.02" "0.03" "0.04" ...
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ K0.LuZ.fitted                     : num [1:331, 1:19] 0.514 0.513 0.513 0.513 0.512 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : chr [1:331] "0.01" "0.02" "0.03" "0.04" ...
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ LuZ.0m                            : num [1:19] 2.23e-05 8.31e-42 9.14e-02 2.35e-01 8.96e-02 ...
    ##  $ K.LuZ.surf                        : num [1:19] NA 4.85 4.22 3.53 2.1 ...
    ##  $ LuZ.Z.interval                    : num [1:19] NA 1.14 1.14 1.14 1.14 ...
    ##  $ LuZ.0m.linear                     : num [1:19] NA 0.0108 0.0251 0.0365 0.095 ...
    ##  $ EdZ.fitted                        : num [1:332, 1:19] 0.0221 0.0216 0.0212 0.0207 0.0203 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : chr [1:332] "0" "0.01" "0.02" "0.03" ...
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ KZ.EdZ.fitted                     : num [1:331, 1:19] 2.11 2.11 2.1 2.09 2.08 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : chr [1:331] "0.01" "0.02" "0.03" "0.04" ...
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ K0.EdZ.fitted                     : num [1:331, 1:19] 2.11 2.11 2.11 2.1 2.1 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : chr [1:331] "0.01" "0.02" "0.03" "0.04" ...
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ EdZ.0m                            : num [1:19] 0.0221 40.4582 122.9247 207.2934 167.716 ...
    ##  $ K.EdZ.surf                        : num [1:19] 5.81 4.69 4.1 3.54 1.98 ...
    ##  $ EdZ.Z.interval                    : num [1:19] 0.802 0.802 0.847 1.245 2.171 ...
    ##  $ EdZ.0m.linear                     : num [1:19] 1.26 36.8 63.48 67.57 72.44 ...
    ##  $ Q.0                               : num [1:19] 3.14 3.14 3.14 3.14 3.14 ...
    ##  $ Q.sun.nadir                       : num [1:19] 3.14 3.14 3.14 3.14 3.14 ...
    ##  $ f.0                               : num [1:19] 0.33 0.33 0.33 0.33 0.33 0.33 0.33 0.33 0.33 0.33 ...
    ##  $ f.sun                             : num [1:19] 0.33 0.33 0.33 0.33 0.33 0.33 0.33 0.33 0.33 0.33 ...
    ##  $ LuZ.shad.aR                       : Named num [1:19] 0.178 0.1425 0.1228 0.1058 0.0583 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ LuZ.shad.Edif                     : num [1:19] NA 0.224 0.3 0.285 0.294 ...
    ##  $ LuZ.shad.Edir                     : num [1:19] NA 0.125 0.2 0.221 0.357 ...
    ##  $ LuZ.shad.ratio.edsky.edsun        : num [1:19] NA 1.8 1.504 1.287 0.822 ...
    ##  $ LuZ.shad.eps.sun                  : Named num [1:19] 0.537 0.46 0.412 0.368 0.223 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ LuZ.shad.eps.sky                  : Named num [1:19] 0.56 0.481 0.432 0.386 0.236 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ LuZ.shad.eps                      : Named num [1:19] NA 0.474 0.424 0.378 0.229 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ LuZ.shad.correction               : Named num [1:19] NA 0.526 0.576 0.622 0.771 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ Lw.0p                             : Named num [1:19] NA 8.42e-42 8.46e-02 2.01e-01 6.19e-02 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ nLw.0p                            : Named num [1:19] NA 2.88e-41 2.11e-01 4.43e-01 1.19e-01 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ R.0m                              : Named num [1:19] NA 2.29e-42 1.21e-02 2.60e-02 6.15e-03 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ Rrs.0p                            : Named num [1:19] NA 3.73e-43 1.98e-03 4.23e-03 1.00e-03 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ Lw.0p.linear                      : Named num [1:19] NA 0.0109 0.0232 0.0312 0.0657 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ nLw.0p.linear                     : Named num [1:19] NA 0.0374 0.058 0.0687 0.1261 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ R.0m.linear                       : Named num [1:19] NA 0.00297 0.00333 0.00404 0.00652 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ Rrs.0p.linear                     : Named num [1:19] NA 0.000484 0.000543 0.000658 0.001061 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...

## The case of Bioshade

Some COPS system include a so called Bioshade. It allows to estimate the
fraction of diffuse skylight to the total downwelling irradiance, as
explain in Bélanger et al. (2017). The BioSHADE system is fitted to the
reference \(E_d(0+, \lambda)\) radiometer. Briefly, the BioSHADE is a
motor that moves a black aluminum band (shadowband) 1.5 mm thick and 2.5
cm wide back and forth above the \(E_d(0+, \lambda)\) sensor. Under
clear sky conditions, when the shadowband completely blocks direct sun
at time \(t_{shadow}\), the radiometer measures the diffuse skylight
(minus a part of the sky that is also blocked by the shadowband),
\(E_{d,diffuse}^*(0+, \lambda, t_{shadow})\). When the shadowband is
horizontal, the sensor measures the global solar irradiance. So to
assess the global solar irradiance at the time \(t_{shadow}\), we
interpolate \(E_d(0+, \lambda)\) just before and after the shadowband
started to shade the sensor. This allows to approximate the fraction of
diffuse skylight to the total downwelling irradiance as :

Because part of the sky is also blocked by the shadowband at
\(t_{shadow}\), \(f^*\) will slightly underestimate \(f\). This
underestimation will have negligible impact on the calculations of the
shading error when \(\theta_0\) is around 35\(^{\circ}\), which is close
to most conditions encountered.

To activate the Bioshade processing, we have to edit **remove.cops.dat**
file and change the integer to 2. For example:

IML4\_150630\_1339\_C\_data\_005.csv;2

As for the other files, the *time.window* field must be edited in the
**info.cops.dat** but the other parameters will be ignore. Here is an
example of the PDF file produce by a bioshade procesing. The next figure
shows that the BioShade was activated during the recovering of the
profiler. In fact, the profiler was at 30 depth when the acquisition was
started.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/BioShade_time.png" title="Example of depth versus time for a BioShade measurements" alt="Example of depth versus time for a BioShade measurements" width="80%" />

The next plot shows the Bioshade position as a function of time, which a
relative unit. The shadowband is horizontal, i.e. not shading the
sensor, when it is \<5000 or \>25000. So here the shadowband a
round-trip, passing twice above the sensor. The red points will be used
to interpolate \(E_d(0+, \lambda)\) just before and after the shadowband
started to shade the
sensor.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/BioShadePos.png" title="Example of Bioshade position versus time" alt="Example of Bioshade position versus time" width="80%" />

The next plot shows the \(E_d(0+, \lambda)\) as a function of time. The
solid lines are the interpolated data use to assess the global
irradiance when the shadowband passed in front the sun, which occured at
about 68 and 110 seconds atfer the begining of the data
acquisition.

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/BioShade_Ed_vs_time.png" title="Example of downwelling irradiance measured during a Bioshade measurement" alt="Example of downwelling irradiance measured during a Bioshade measurement" width="80%" />

In this example is was a clear sky. The resulting contribution of
diffuse sky to the global irradiance is shown in the next plot. The
fraction of diffuse skylight to the total downwelling irradiance (green
curve) increases exponentially from the NIR (\<10%) to the UV
(\~50%).

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/BioShade_Ed0.png" title="Example of total (black), direct (red) and diffuse (blue) downwelling irradiance assessed using the Bioshade measurements" alt="Example of total (black), direct (red) and diffuse (blue) downwelling irradiance assessed using the Bioshade measurements" width="80%" />

The RData structure saved for a Bioshade file is shown
below.

``` r
load("~/MEGA/data/BoueesIML/2015/L2/20150630_StationIML4/COPS/BIN/IML4_150630_1339_C_data_005.csv.RData")
str(cops)
```

    ## List of 56
    ##  $ verbose                           : logi TRUE
    ##  $ indice.water                      : num 1.34
    ##  $ rau.Fresnel                       : num 0.043
    ##  $ win.width                         : num 9
    ##  $ win.height                        : num 7
    ##  $ instruments.optics                : chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ tiltmax.optics                    : Named num [1:3] 5 5 5
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ time.interval.for.smoothing.optics: Named num [1:3] 40 80 80
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ sub.surface.removed.layer.optics  : Named num [1:3] 0 0 0
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ delta.capteur.optics              : Named num [1:3] 0 -0.09 0.25
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ radius.instrument.optics          : Named num [1:3] 0.035 0.035 0.035
    ##   ..- attr(*, "names")= chr [1:3] "Ed0" "EdZ" "LuZ"
    ##  $ format.date                       : chr "%m/%d/%Y %H:%M:%S"
    ##  $ instruments.others                : chr "NA"
    ##  $ depth.is.on                       : chr "LuZ"
    ##  $ number.of.fields.before.date      : num 1
    ##  $ time.window                       : num [1:2] 0 10000
    ##  $ depth.discretization              : num [1:19] 0 0.01 1 0.02 2 0.05 5 0.1 10 0.2 ...
    ##  $ file                              : chr "IML4_150630_1339_C_data_005.csv"
    ##  $ chl                               : logi NA
    ##  $ SHADOW.CORRECTION                 : logi FALSE
    ##  $ absorption.waves                  : logi NA
    ##  $ absorption.values                 : logi NA
    ##  $ blacks                            : chr(0) 
    ##  $ Ed0                               : num [1:2745, 1:19] 0.729 0.731 0.732 0.734 0.736 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : NULL
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ EdZ                               : num [1:2745, 1:19] -0.00054 0.00025 0.00026 0.000315 0.001807 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : NULL
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ LuZ                               : num [1:2745, 1:19] -1.06e-05 -1.09e-05 -1.19e-05 1.40e-05 -7.65e-06 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : NULL
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ Ed0.anc                           :'data.frame':  2745 obs. of  2 variables:
    ##   ..$ Roll : num [1:2745] 3.08 2.66 2.31 1.89 1.19 ...
    ##   ..$ Pitch: num [1:2745] 1.887 1.328 1.118 1.118 0.839 ...
    ##  $ EdZ.anc                           :'data.frame':  2745 obs. of  2 variables:
    ##   ..$ Roll : num [1:2745] -0.349 0.21 0.559 1.048 1.398 ...
    ##   ..$ Pitch: num [1:2745] -8.35 -6.51 -6.3 -5.32 -5.04 ...
    ##  $ LuZ.anc                           :'data.frame':  2745 obs. of  2 variables:
    ##   ..$ Depth: num [1:2745] 29.8 29.8 29.7 29.7 29.7 ...
    ##   ..$ Temp : num [1:2745] 2.96 2.97 2.97 2.96 2.97 ...
    ##  $ Ed0.waves                         : num [1:19] 305 320 330 340 380 412 443 465 490 510 ...
    ##  $ EdZ.waves                         : num [1:19] 305 320 330 340 380 412 443 465 490 510 ...
    ##  $ LuZ.waves                         : num [1:19] 305 320 330 340 380 412 443 465 490 510 ...
    ##  $ Others                            :'data.frame':  2745 obs. of  6 variables:
    ##   ..$ GeneralExcelTime : num [1:2745] 42186 42186 42186 42186 42186 ...
    ##   ..$ DateTime         : chr [1:2745] "06/30/2015 14:13:40" "06/30/2015 14:13:41" "06/30/2015 14:13:41" "06/30/2015 14:13:41" ...
    ##   ..$ DateTimeUTC      : chr [1:2745] "06-30-2015 02:13:40.968 " "06-30-2015 02:13:41.031 " "06-30-2015 02:13:41.109 " "06-30-2015 02:13:41.171 " ...
    ##   ..$ Millisecond      : int [1:2745] 968 31 109 171 234 296 359 437 500 562 ...
    ##   ..$ BioGPS_Position  : num [1:2745] 10 141342 -6834 4840 10 ...
    ##   ..$ BioShade_Position: int [1:2745] 31289 31289 31289 31289 31289 31289 31289 31289 31289 31289 ...
    ##  $ file                              : chr "IML4_150630_1339_C_data_005.csv"
    ##  $ potential.gps.file                : chr "IML4_150630_1339_gps.csv"
    ##  $ Ed0.tilt                          : num [1:2745] 3.61 2.97 2.56 2.19 1.45 ...
    ##  $ EdZ.tilt                          : num [1:2745] 8.35 6.52 6.33 5.42 5.23 ...
    ##  $ LuZ.tilt                          : NULL
    ##  $ change.position                   : logi FALSE
    ##  $ longitude                         : num -68.6
    ##  $ latitude                          : num 48.7
    ##  $ dates                             : POSIXct[1:2745], format: "2015-06-30 14:13:40" "2015-06-30 14:13:41" ...
    ##  $ date.mean                         : POSIXct[1:1], format: "2015-06-30 14:15:11"
    ##  $ cops.duration.secs                : num 182
    ##  $ day                               : num 30
    ##  $ month                             : num 6
    ##  $ year                              : num 2015
    ##  $ sunzen                            : num 37.9
    ##  $ Depth                             : num [1:2745] 29.8 29.8 29.7 29.7 29.7 ...
    ##  $ Depth.good                        : logi [1:2745] TRUE TRUE TRUE TRUE TRUE TRUE ...
    ##  $ depth.fitted                      : num [1:331] 0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 ...
    ##  $ Ed0.th                            : num [1:19] NA 32.1 47.6 49.4 66.2 ...
    ##  $ Ed0.fitted                        : num [1:2438, 1:19] 0.749 0.749 0.749 0.749 0.749 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : chr [1:2438] "0.967999935150146" "1.03099989891052" "1.10899996757507" "1.1710000038147" ...
    ##   .. ..$ : chr [1:19] "305" "320" "330" "340" ...
    ##  $ Ed0.tot                           : Named num [1:19] 0.737 22.186 41.945 46.487 60.448 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ Ed0.dif                           : Named num [1:19] 0.381 11.144 19.931 20.476 19.835 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...
    ##  $ Ed0.f                             : Named num [1:19] 0.517 0.502 0.475 0.44 0.328 ...
    ##   ..- attr(*, "names")= chr [1:19] "305" "320" "330" "340" ...

# The in-water IOPs data processing

In-water measurements of IOPs can be acheive using various optical
instruments. In general, several instruments are put on the same frame
refer to as an **optical package**. Optical packages usuallr includes a
CTD to measure the water temperature and salinity and a set of optical
sensors for IOPs, such as absorption (\(a(\lambda)\)) scattering
(\(b(\lambda)\)), backscattering (\(b_b(\lambda)\)), and attenuation
(\(c(\lambda)\)) meters. Fluorescence for CDOM and Chlorophyll-a is aslo
often measured. In most case, the raw measurements require several
corrections and calibration in order to get accurate IOPs. For example,
backscattering measurements is, in reality, not measure directly. It is
instead a measure of the *Volume Scattering Function* (VSF) a a given
scattering angle in the backward direction relative to the laser beam.
This type of measure should be corrected for the loss of signal due to
the attenuation of the light beam along the optical path (see Doxaran et
al. (2016) for a detailed discussion on that topic). Absorption
measurements also require correction for water temperature and salinity.
In addition, if the absorption is measured using reflecting tubes suahc
as those of an ac-9 or ac-s instruments (WetLabs), a correction is
needed for the loss of photons due to scattering within the tube.

The purpose of the `Riops` package was first to apply the necessary
corrections to the IOPs measured using an optical package available at
UQAR that contains the following instruments:

  - A *Hydroscat-6* from Hobilabs for the particulate backscatteing at
    six wavesbands at 394, 420, 470, 532, 620 and 700 nm.
  - An *a-sphere* from Hobilabs, which is a submersible teflon
    integrating sphere that measures the absorption coefficients at 1500
    wavelengths between 360 and 764 nm, that are binned at 1 nm
    resolution.
  - An *ECO triplet* from WetLabs for CDOM fluoresece with excitation
    wavelength at 370 nm and emission wavelengthd at 420, 460 and 500nm.
  - A *SBE19+ CTD* from Seabird for temperature, conductivity and depth.

This optical package also includes a data logger named *MiniDAS*
commercialized by HobiLabs.

Later, I extended the R code to deal with typical WetLabs optical
pakcages loan from Pierre Larouche at IML and Marcel Babin at Takuvik.
Typically, these packages includes a data logger named *DH4* from
WetLabs and a set of optical instruments such as:

  - A *microCAT CTD* from SeaBirdb for temperature, conductivity and
    depth.
  - An AC-s from WetLab for spectral beam attenuation and absorption
    measurements using reflecting tubes
  - A *BB9* from WetLabs for the particulate backscatteing at nine
    wavesbands.
  - A *BB3* from WetLabs for the particulate backscatteing at nine
    wavesbands.
  - A *FLBBCD*, which is an ECO triplet from WetLabs for chlorophyll
    fluorescence, bacskattering and CDOM fluorescence
  - A *FLCHL* from WetLabs forchlorophyll fluorescence.
  - A *LISST* from Sequoia for particles size distribution (PSD)

I recently inludes some routines to read WetLabs *ECOVSF* that we
deployed in standalone mode in 2018 during Lake Pulse and CoastJB
projects.

The `Riops` package includes reading funtions for all these instruments,
but the main interest of the package in the
`correct.merge.IOP.profile()` function that read, merge, correct and
clean the data from all instruments available on the optical package. In
fact, the data are :

  - resampled on a unique time frame,
  - corrected for temperature, salinity and attenuation,
  - and interpolated on a common grid of equally spaced depth.

Note that the processing was designed for data collected using an
optical package deployed to collect data for vertical profile. This
means that stand-alone deployment of the optical instruments are still
not fully supported (as during the Lake Pulse project). Adaptation of
the code will be necessary.

## Preparation raw data

In the field, we always document the deployement operations in a log
sheet. Make sure you have this log sheet in hand before starting. Unlike
the COPS, we usually perform only one IOPs profile on the field. As
mention above, there is two main types of optical package supported,
i.e. the Hobilabs and the WetLabs. The data pre-processing differ among
the instrument package.

### Hobilabs data pre-processing

For each cast performed on the field, the output from each instrument is
captured in a seperate file and stored in the MiniDAS memory. The
instrument files contain a copy of every byte the instrument transmits,
in its native format. Each file’s name contains the cast number, which
is incremented automatically by the MiniDAS each time the switch is
turned ON. The cast number should have been logged by the operator in
the field. For example the following files are produced by cast number
5:

  - ASPH005.bin : contains the data from the a-sphere in binary format.
    You need to process the raw data using a software called IGOR with
    the appropriate calibration file. IGOR is a window-based program
    that requires a liscence, which was provided by Hobilabs. In IGOR
    you can open the **a-Sphere Processing Template 201.pxt** file,
    which will add an “a-sphere” menu. Then load the a-Sphere
    calibration file using “Load Calibration File…” in the a-Sphere
    menu. All the other a-Sphere functions depend on information in the
    calibration file. Next click **“Load and Graph Dataset…”** from the
    a-sphere menu and select the raw data file to process. Then choose
    the width of the spectral bands into which data will be averaged.
    The default is 5 nm but change it to 1 nm, which the smallest
    wavelength increment available. Finally, choose the **“Export
    Dataset…”** command to save the data as tab-delimited text (ASCII).
    Save the data with the same name but by changing the extension to
    txt. (e.g., ASPH005.BIN → ASPH005.txt).

  - HS6005.raw : contains the data from the Hydroscat-6 in binary
    format. You need to process the raw data using a software called
    HydroSoft with the appropriate calibration file. Simply to menu
    **Processing** → **Process Raw Files** to open a window dialog wich
    allows the conversion of the raw data into the calibrated files
    saved in ASCII (e.g., HS6005.raw → HS6005.dat).  

  - CTD005.txt : contains the data from the CTD in ASCII format (ready
    for the processing in R).

  - FL005.txt : contains the data from the ECO triplet in ASCII format
    (ready for the processing in R).

Finnaly, simply copy the four ASCII files in the appropriate directory,
for example in :

**./L2/20150606\_StationP1/IOPs/**

### WetLabs data pre-processing

As mentioned above, the WetLabs optical packages usually include a data
logger named *DH4*. Unlike the MiniDAS, the *DH4* produces only one file
for each IOP cast refer to as **archive file**. The archive files
generated by the DH4 are in binary format and there extention the cast
number (e.g. cast number 5 will be named **archive.005**). To extract
the data from them, you need to use the **WAP (Wetlabs Archive file
Processing)** software. To process the data in WAP:

  - you will need one **device file** for each WetLabs instrument (i.e.,
    ac-s, BB9, BB3, FLECO, etc.). The device files store the calibration
    coefficients. No device file or calibration file is needed for the
    LISST and CTD at this stage.
  - you need to know the port number of the DH4 in which each intrument
    were connected.

Supposed your package had a CTD in DH4 port 1, a BB9 in port 2, a FLBBCD
in port 3 and an ac-s in port 4. The archive file generated for the cast
number 5 will be named archive.005. The WAP will extract the data and
create the following files:

  - archive\_21\_CTD-ENGR.005 (or archive\_21\_T\_ASCII.005) : is the
    CTD file in ASCII format.
  - archive\_22\_ECO.005 : is the BB9 file in ASCII format.
  - archive\_23\_ECO.005 : is the FLBBCD file in ASCII format.
  - archive\_24\_ACS.005 : is the AC-s filein ASCII format.
  - archive\_TO.005 : is an ASCII file which contains the time offset to
    consider to syncronised the instrument clock.

So the DH4 port number follow the base name **archive\_2**. It will be
important to know this information when you process the data. Once
extracted, these data could be process in R using the `Riops` package.

A detailed description of the WAP is available elsewhere and is out of
the scope of the present document.

IMPORTANT NOTE: the LISST data format is in ASCII but in raw counts. I
wrote an R function to convert the file into a binary file format
readable with the LISST software which is used to calulate the Particles
Size Distribution (PSD). Otherwise one can use Matlab routines provided
by Sequoia to convert the ASCII into PSD.

## Installation of the Riops package

As any other package available on GitHub, the installation is
straitforward using the `devools` package utilities, i.e.:

``` r
devtools::install_github("belasi01/Riops")
```

Follow the same instructions if you want to install the source code.

## Reading routines

The package includes several function to read the data

  - `read.ACs()` Reads AC-s file
  - `read.ASPH()` Reads A-Sphere ASCII file as exported by IGOR
    software.
  - `read.BB3()` Reads BB-3 file
  - `read.BB9()` Reads BB-9 file
  - `read.CTD()` Reads CTD SBE19+ file in ASCII format
  - `read.CTD.DH4()` Reads CTD (MicroCAT) file
  - `read.FLBBCD()` Reads ECO triplet for chlrophyll, bb700 and cdom
    file
  - `read.FLCHL()` Reads chlorophyll fluorescence file
  - `read.FLECO()` Reads ECO triplet for CDOM fluorescence file
  - `read.HS6()` Reads Hydroscat-6 file as created by Hydrosoft
  - `read.LISST()` Reads LISST file in format
\*.asc

## Processing vertical profiles of IOPS

### Step 0 : Get stated with IOPs processing and preparation of the input information

I built the `Riops` package with the same phylosophy as the `Cops`
package. Let’s load the library
    first.

``` r
library(Riops)
```

    ## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ## TO BEGIN A PROCESSING, 
    ## 1. Create an ASCII file named directories.for.IOPs.dat 
    ##    in which the full path of the folder(s) containing the IOPs raw data to process
    ## 2. Type IOPs.go(report=FALSE)
    ## 3. Edit the files cast.info.dat, cal.info.dat and instrument.dat to provide  
    ##    the adequate parameters for the processing (see header of copied cast.info.dat, cal.info.dat) 
    ##    (e.g. lat, lon, cast number, calibration file, blank, depth and smoothing intervals, etc) 
    ## 4. Type again IOPs.go(report=TRUE)
    ## 5. Look at the IOPs.plot.pdf 
    ## WARNING: user will be prompted to synchronized the data form different instruments
    ## This is due to the fact that instrument's clock are never perfectly synchronized
    ## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

So one can launch the code with a single call to the function
`IOPs.go()`. I strongly recommanded to first set the working directory
(i.e. a folder were you put the iops data for a given station) using
`setwd()` and than type `IOPs.go(report = FALSE)`. See what happen.

``` r
IOPs.go(report = F)
```

You will get the following message:

**CREATE a file named directories.for.IOPs.dat in current directory
(where R is launched) and put in it the names of the directories where
data files can be found (one by line)**

So this is exactly as for the cops package.

#### Create the **directories.for.IOPs.dat** file

Once you put the full path of the folder to process in the file
**directories.for.IOPs.dat**, you can lanch again the code.

``` r
IOPs.go(report = F)
```

And you get this
message:

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
**PROCESSING DIRECTORY \~/L2/20150710\_StationIML4/CageBioOptique/**
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
**EDIT file \~/L2/20150710\_StationIML4/CageBioOptique/cast.info.dat and
CUSTOMIZE IT** **EDIT file
\~/L2/20150710\_StationIML4/CageBioOptique/instrument.dat and CUSTOMIZE
IT**

So two new files are created in the working directory, which need to be
edited.

#### Edit the **instrument.dat** file

The **instrument.dat** only contains a list of supported instruments
followed by a coma and an integer indicating whether the instrument was
deployed or not: 0 = not deployed; 1 = deployed. In this example, the
UQAR package was used including a Hydroscat-6 (HS6), an ECO Triplet
(FLECO), an a-sphere (ASPH) and a CTD
(CTD.UQAR).

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/Instrument&cast_file.png" title="Example of the ASCII files to edit for the IOP procesing" alt="Example of the ASCII files to edit for the IOP procesing" width="100%" />

#### Edit the **cast.info.dat** file

The next file, **cast.info.dat** contains a header describing the 12
fields to edit. The fields a separated by comas and they are breifly
described in the header of the file. Here I provide more information.

  - The first two fields are the **lon/lat** coordinates in decimal
    degrees. These are needed to produce the location map of PDF report
    (see below).
  - The third field is the **cast** number. It is a character string of
    three digits corresponding to either MINIDAS cast number or file
    extension generated by the WAP from DH4 archive file (e.g. “001”).
  - The forth and fifth fields are actual **CTD and LISST start time**,
    respectively. This can be NA for most situations, except when a time
    stamp is not avalailable in the current set up. The user will be
    asked to put the start time in POSIXct format as “YYYY-MM-DD
    HH:MM:SS” (e.g.“2015-05-06 12:18:01” or NA)
  - The **minx** and **maxx** are the indices of the CTD vector
    corresponding to the start and the end of the IOP profile. If NA,
    the user will be prompt to select the index interactively by
    clicking on the plot of time versus depth. The begining of the
    profile is when the optical begin the downcast while the end is just
    before the CTD exit the water colomn. Note that at the end of the
    processing, the **cast.info.dat** is updated with the values
    obtained interactively. it can be edited to remove bad data points
    near the sea surface.  
  - The field **Zint** (8th) is the depth interval in meter for the
    smoothed profiles. In fact, all the measured parameter will be
    resample on the same depth vector. By default a depth interval of
    0.5 m. In deep waters it can be 1 m interval. In very shallow water
    when the profile is made very slowly, a Zint of 0.25 or even 0.1
    meter may be better (it is the user’s choice).  
  - The field **depth.interval.for.smoothing** (9th) is the depth
    interval in meter that will be used to smooth data with the LOESS
    function. This is very similar to what is done in the COPS
    processing.
  - The field **asph.skip** (10th) is only used when processing a-sphere
    profile. It is the number or records to skip at the begining of an
    asphere file. This is only (rarely) necessary when the asphere file
    contain 2 or more profiles. It can ce ignore most of the time. When
    it happens, look into the file.  
  - The last two fields (11th and 12th) are parameters used for plots
    that are included in the PDF report. **maxbb** is the maximum value
    of the y-axis of the \(b_b\) plots, which is useful when you have
    outliers. **Ndepth.to.plot** is the number of depth to put in the
    spectral IOP plots.

#### Launch the processing and edit the **cal.info.dat** file

If you launch again the function `IOPs.go()` the code may stop again or
run without error depending on the set up. In fact some instrument
requires calibration information such as the water temperature of the
pure water calibration, the year of calibration, etc. The calibration
information are stored in the **cal.info.dat**. The file includes the
following information (NOTE: any field can be ommited with out problem):

  - Tref.ASPH is the temperature of pure water used by Hobilabs for the
    ASPH calibration. In 2010 and 2014 it was 13.2, in 2013 it was 19,
    in 2016 it was 14.4.
  - HS6.CALYEAR is the year of the HS6 calibration.
  - Tref.ACS is the temperature of pure water used by Wetlabs for the
    ACS calibration. For example, the IML ACs calibration made by
    WetLabs in 2013 was 20.3
  - scat.correction is the method for the scattering correction of AC-S
    abssorption. There is four options available for this correction:
      - “mckee”: This correction method is described in Mckee, Piskozub,
        and Brown (2008) and requires simultaneous measurement of
        particle backscattering (\(b_{bp}\));
      - “zaneveld”: This correction method is described in Zaneveld,
        Kitchen, and Moore (1994) and assumed a spectrally dependent
        loss of photon in the reflecting tube due to a fraction of the
        scattering estimated in the NIR assuming null non-water
        absorption in the NIR.  
      - “baseline”: This is a white correction assuming null non-water
        absorption in the NIR.
      - “none”: no correction.
  - blank.ASPH is a string for the path of the blank file for ASPH as
    created by `analyse.ASPH.blank`.
  - blank.ACS is a string for the path of the blank file for ACS as
    created by `analyse.ACs.blank`.
  - blank.BB9 is a string for the path of the blank file for BB9.
  - blank.BB3 is a string for the path of the blank file for BB3.

### Step 1 : Instruments synchronisation (if necessary)

Some instrument does not have a pressure sensor or an absolute time
stamp. To synchronize the instrument, the program may need user’s input.
This is the case of the ECO triplet of UQAR. When this instrument is
available, the user will be prompt to click on the plot to identify the
moment when the instruments exit the water column (or enter in the water
if it is more obvious), which is easy to detect. On the figure , we can
clearly identify the moment when the instrument exited the water column
at about 55:00 time. Similary, figure  shows the salinity, which jumped
at the entrance or the exit of the water column. Based in this point, a
pressure vector will be added to the FLECO data for further
processing

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/FLECO_vs_Time.png" title="Example of the fluoresence signal versus time of the FLECO. The user clicked the outlier points when the intrument exit the water. The index of that point was 1629. \label{FLECOvsTIME}" alt="Example of the fluoresence signal versus time of the FLECO. The user clicked the outlier points when the intrument exit the water. The index of that point was 1629. \label{FLECOvsTIME}" width="100%" />

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/CTD_vs_time.png" title="Example of the salinity versus time of the CTD. The user clicked the outlier points when the intrument exit the water. The index of that point was 2504. \label{CTDvsTIME}" alt="Example of the salinity versus time of the CTD. The user clicked the outlier points when the intrument exit the water. The index of that point was 2504. \label{CTDvsTIME}" width="100%" />

In the case of the WetLabs DH4, all the absolute time usually comes from
the CTD and the time offset between each sensor is written in a file
named **archive\_TO.001** (if the cast number is “001”). This why this
file must be provided.

At this stage, the programm with will add the depth to instruments
without pressure sensors. For BB9, BB3, FLBBCD, FLECO and ACs, the depth
is obtained from the CTD using time stamp.

### Step 2 : Identify the begining and the end of the cast

In general, when we run the processing for the first time we set the
**minx** and **maxx** to NA. Those are the indices of the CTD vector
corresponding to the start and the end of the IOP profile. If NA, the
user will be prompt to select the index interactively by clicking on the
plot of time versus depth. The begining of the profile is when the
optical begin the downcast while the end is just before the CTD exit the
water column.

The next figure  shows an example of a typical IOP cast with the depth
of the optical package, as measured by the CTD, as a function of time.
The optical package was put at 5 meters depth for about 5 minutes for
the instrument’s warm up. At about 49:30, the package was raise to the
sea surface for a few seconds and then lowered in the water column to
reach 64 meters depth. Note that last part of the profile was not
continuous (due probably to problems with the winch or the cable…). The
upcast was quick compared to the downcast. The user clicked to set the
begining of cast (index 1166) and at the end of the cast (index 2469).
Those are **minx** and **maxx** and they will be store in the
**cast.info.dat** file by the program. The next time you run the code,
the user will not be prompt. However, those values can be edited to
remove bad data points near the sea surface (next
step).

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/Depth_vs_time.png" title="Example of depth versus time for an IOP profile. \label{DepthvsTime}" alt="Example of depth versus time for an IOP profile. \label{DepthvsTime}" width="100%" />

Normally the program will run until the end of the processing and
produce three RData file in the working directory:

  - **IOP.RData** : is a list containing all the data from all
    instruments.  
  - **IOP.fitted.down.RData** : is a list containing the smoothed data
    from the downcast resampled in a regular depth vector with the
    vertical resolution requested. This is determine using the **Zint**
    parameter of **cast.info.dat** (see above).
  - **IOP.fitted.up.RData** : is the same but for the upcast (usually of
    lower
quality).

### Step 3 : Produce the PDF report and check if the parameters of **cast.info.dat** need adjustment

The program can produce a PDF report using a sweave template. IMPORTANT:
you need to install latex on your computer to produce the PDF.

``` r
IOPs.go(report = T)
```

It will create a PDF file with many plots of the CTD and the IOPs
profiles. It also includes spectral plots for the \(b_b(\lambda)\),
\(b_{bp}(\lambda)\), \(a_{nw}(\lambda)\). The number of spectra in these
plot can be changed usung the **Ndepth.to.plot** parameter of the
**cast.info.dat** file. After looking at the plot you may want to remove
some data points near the sea surface that look like outliers. To do so
simply edit manually the **minx** and **maxx** parameters from the
**cast.info.dat**.

### Step 4 : Output absorption coefficients from the COPS processing. (Optionnal)

You can run again the program to output the absorption coefficient from
the surface layer and write the values in the absorption.cops.dat file
located in “../COPS/” folder (assuming you are located in the IOPs
folder). IMPORTANT: the folder structure is very important here (COPS in
capital letters). You should also have run the COPS processing before.
The programme will get the wavelengths in one of the RData file
in“../COPS/BIN/”.

``` r
IOPs.go(output.aTOT.COPS = TRUE, 
        depth.interval = c(0.75,2.1), 
        a.instrument = "ASPH", 
        cast = "down")
```

You can take the absorption from the a-sphere (ASPH) or the ac-s (ACS),
from the down or the up cast and for the depth interval you want.
Default are shown above.

The program will create a figure in the IOPs/ folder named
**absorption.for.cops.png**, as shown below (Fig.
).

<img src="/Users/simonbelanger/OneDrive - UQAR/Cours/R_Optical_Packages_Workshop/absorption.for.cops.png" title="Example of spectral non-water absorption (red) from the a-sphere and the pure water absorption (blue). The black dots are the total absorption coefficients corresponding to the COPS bands (the UV was extrapolated from the 360-400 nm range). \label{abs4cops}" alt="Example of spectral non-water absorption (red) from the a-sphere and the pure water absorption (blue). The black dots are the total absorption coefficients corresponding to the COPS bands (the UV was extrapolated from the 360-400 nm range). \label{abs4cops}" width="50%" />

## Processing backscattering at fixed depth

In shallow waters, we often deploy instrument in stand alone mode. This
was the case during the Lake Pulse project. I have recently developped a
set of routines to deal with the WetLabs ECO meters deployed in
stand-alone mode and record in raw numeric counts. This includes the
VSF3, BB9 and BB3.

The processing includes the application of the calibration coefficients
to convert the raw numerical counts into volume scattering function
(VSF). The dark offsets may be taken from the calibration file (device
file) or from the dark measurements taken on the field. Next, if
absorption coefficients are provided, the VSF is corrected for loss of
photons due to attenuation along the pathlength. The VSF is finaly
converted in to total backscattering (\(b_b\)) and particles
backscattering (\(b_{bp}\)).

The main function to launch this type of processing is
`run.process.ECO.batch()`. The data must be prepare following the
instructions provided in the help of this function. Briefly, the raw
data should be place in a single data folder ../raw/ and the
corresponding dark measurements in ../dark/. But the most important
thing to do before runing this programm is to prepare the log.file. This
ASCII file contains several fields (semi-column delimiter) :
ECO.filename; dev.file; ECO.type; ECO.bands; Station; Date; UTCTime;
Depth; Salinity; dark.file; start; end; process; Anw1;..;AnwX

Again, see the help pages to get started…

# Laboratory spectrophotometric absorption measurements

See `RspectroAbs` package

## CDOM absorption

### Data preparation

All the data must be place in a single ../csv/ folder. The most
important thing to do before runing the code is to prepare the log.file.
This file contains 6 fields :

  - **ID** is the sample ID. It is usually the base name of the CSV
    file. for example, 407839 ID will have the following file name:
    407839.Sample.Raw.csv (from the Perkin Elmer Lambda 850), where the
    “.Sample.Raw.csv” was automatically added by the Lambda850
    software.
  - **Station** is the Station name. For example: “IML4”, “L3\_18”, etc.
  - **Depth** is the depth of the sample in meters.
  - **pathlength** is the pathlength of the cuvette in meters (e.g. 0.1
    when using 10-cm cuvette).
  - **Ag.good** is a binary field where 1 will process the sample while
    0 will skip the sample.
  - **DilutionFactor** Is a factor to adjust the final Ag value if
    dilution was performed in the lab (default=1).

### Data processing

See `run.process.Ag.batch()` help page. The program will automatically
create two new folders in the data.path to store the results. For each
process sample, a png and a RData file is produce and stored in
data.path/png and data.path/RData,
respectively.

## Particles absorption using filter pad technique inside an integrating sphere

### Data preparation

The data files must be named following a convention we adpopted in 2011.
Name the file follow: ID\_REPL\_TYPE, where

  - ID = Sample ID (could include station ID + depth + date),
  - REPL = replicate ID (e.g. A (1st), B (2nd)),
  - TYPE = type of measurement, (i.e. Ap for total absorption; Nap for
    non-algal pacticles after bleaching)

For example for a sample **CL6\_surf\_20170801\_A\_Ap.Sample.Raw.csv**
is for the ID *CL6\_surf\_20170801* the replicate *A* and the total
particulate *Ap*. The same filter measured after pigment extraction
would be named **CL6\_surf\_20170801\_A\_Nap.Sample.Raw.csv**.

As for CDOM, but the log.file should contains 11 fields :

  - **ID** Unique ID of the sample
  - **Repl** A letter corresponding to the replicate (A,B,C,etc)
  - **Station** Station name
  - **Depth** Depth of the sample
  - **Vol** Filtered volume in mL
  - **Farea** clearance area of particles on filter in m^2
  - **blank.file** ID if the reference blank filter
  - **Ap.good** Boolean quality control indicator (1=good ; 0 = not
    good)
  - **NAp.good** Boolean quality control indicator (1=good ; 0 = not
    good)
  - **process** Boolean (1=to be process ; 0 = to skip in the batch
    processing)
  - **NAP.method** String indicating the method is retained to derive
    phytoplankton absorption (“Measured”, “Fitted”,
    “BS90\_1”“,”BS90\_2")

### Data processing

#### Step 1: Convert OD to absorption coefficient

See `run.process.Ap.batch()` help page.

#### Step 2: Average replicate and QC

See `run.process.replicate.batch()` help page.

#### Step 3: Compute phytoplancton absorption coefficient

See `run.compute.Aph.batch()` help page.

# References

<div id="refs" class="references">

<div id="ref-Belanger2017">

Bélanger, Simon, Claudia Carrascal-Leal, Thomas Jaegler, Pierre
Larouche, and Peter Galbraith. 2017. “Assessment of radiometric data
from a buoy in the St. Lawrence estuary.” *Journal of Atmospheric and
Oceanic Technology* 34 (4): 877–96.
<https://doi.org/10.1175/JTECH-D-16-0176.1>.

</div>

<div id="ref-Doxaran2016">

Doxaran, David, Edouard Leymarie, Bouchra Nechad, Ana Dogliotti, Kevin
Ruddick, Pierre Gernez, and Els Knaeps. 2016. “Improved correction
methods for field measurements of particulate light backscattering in
turbid waters.” *Optics Express* 24 (4): 3615–37.
<https://doi.org/10.1364/OE.24.003615>.

</div>

<div id="ref-Gordon1992b">

Gordon, H R, and Kuiyuan Ding. 1992. “Self-shading of in-water optical
instruments.” *Limnology and Oceanography* 37 (3): 491–500.

</div>

<div id="ref-Mckee2008">

Mckee, David, J Piskozub, and I Brown. 2008. “Scattering error
corrections for in situ absorption and attenuation measurements.”
*Optics Express* 16 (24): 19480–92.
<https://doi.org/10.1364/OE.16.019480>.

</div>

<div id="ref-Zaneveld1994">

Zaneveld, J Ronald V, James C Kitchen, and Casey Moore. 1994. “The
scattering Error Correction of Reflecting-Tube Absorption Meters.” In,
edited by J S Jaffe, 2258:44–55. Bergen: SPIE. [c:{\\%}5CDocuments and
Settings{\\%}5Cutilisateur{\\%}5CMy
Documents{\\%}5CScientific{\\\_}papers{\\%}5CZaneveld{\\\_}etal{\\\_}OO{\\\_}XII{\\\_}Bergen{\\\_}1994.pdf](c:{\\%}5CDocuments%20and%20Settings{\\%}5Cutilisateur{\\%}5CMy%20Documents{\\%}5CScientific{\\_}papers{\\%}5CZaneveld{\\_}etal{\\_}OO{\\_}XII{\\_}Bergen{\\_}1994.pdf).

</div>

<div id="ref-Zibordi1995">

Zibordi, G, and G M Ferrari. 1995. “Instrument Self-Shading in
Underwater Optical Measurements - Experimental-Data.” *Applied Optics*
34 (15): 2750–4.

</div>

</div>
