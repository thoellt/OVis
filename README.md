[![Build Status](https://travis-ci.org/thoellt/OVis.svg?branch=master)](https://travis-ci.org/thoellt/OVis)

## ![OVis Header Icon](https://ovis.thomashollt.com/images/ovis_header.png)

OVis is a framework for interactive visual analysis of ensemble simulation ocean forecasts. OVis allows efficient and easy analysis of ocean forecasts and their parameter subspaces by recomputing derived data on the fly, enabling the user to dive into the data, change parameters, select subsets of the ensemble and instantly visualize the results. OVis is implemented in Objective C and OpenGL. It is a result of my PhD thesis and was developed partly during my time as a PhD student and later as a PostDoc at the [High-Performance Visualization Group](http://vccvisualization.org), part of the [Visual Computing Center](https://vcc.kaust.edu.sa) and the [Red Sea Modeling and Prediction Group](https://assimilation.kaust.edu.sa/) at the [King Abdullah University of Science and Technology](https://www.kaust.edu.sa).

## Contributors
- [Thomas Höllt](https://www.thomashollt.com/) initiated the research project, and is the main developer of the software.
- [Markus Hadwiger](http://vccvisualization.org/people/hadwiger/) supervised the visualization aspects of the project.
- [Ibrahim Hoteit](https://assimilation.kaust.edu.sa/Pages/Ibrahim%20Hoteit.aspx) supervised the simulation and forecasting aspects of the project.

## References
Please consider citing the following references when you use OVis in a research paper. Please note that the current open source version of OVis does not contain all features described in the papers.

```tex
@article { bib:2014_tvcg,
    author = { Thomas H{\"o}llt and Ahmed Magby and Peng Zhan and Guoning Chen and Ganesh Gopalakrishnan and Ibrahim Hoteit and Charles D. Hansen and Markus Hadwiger },
    title = { OVis: A Framework for Visual Analysis of Ocean Forecast Ensembles },
    journal = { IEEE Transactions on Visualization and Computer Graphics },
    volume = { 20 },
    number = { 8 },
    pages = { 1114 -- 1126 },
    year = { 2014 },
    doi = { 10.1109/TVCG.2014.2307892 },
}

@inproceedings { bib:2013_pacificvis,
    author = { Thomas H{\"o}llt and Ahmed Magby and Guoning Chen and Ganesh Gopalakrishnan and Ibrahim Hoteit and Charles D. Hansen and Markus Hadwiger },
    title = { Visual Analysis of Uncertainties in Ocean Forecasts for Planning and Operation of Off-Shore Structures },
    booktitle = { Proceedings of IEEE Pacific Visualization Symposium },
    pages = { 185 -- 192 },
    year = { 2013 },
    doi = { 10.1109/PacificVis.2013.6596144 },
}

@inproceedings { bib:2015_envirvis,
    author = { Thomas H{\"o}llt and Markus Hadwiger and Omar Knio and Ibrahim Hoteit },
    title = { Probability Maps for the Visualization of Assimilation Ensemble Flow Data },
    booktitle = { Proceedings of Workshop on Visualisation in Environmental Sciences },
    pages = { 43 -- 47 },
    year = { 2015 },
    doi = { 10.2312/envirvis.20151090 },
}

@article { bib:2015_nathazards,
    author = { Thomas H{\"o}llt and Mohamed U. Altaf and Kyle T. Mandli and Markus Hadwiger and Clint N. Dawson and Ibrahim Hoteit },
    title = { Visualizing Uncertainties in a Storm Surge Ensemble Data Assimilation and Forecasting System },
    journal = { Natural Hazards },
    volume = { 77 },
    number = { 1 },
    pages = { 317 -- 336 },
    year = { 2015 },
    doi = { 10.1007/s11069-015-1596-y },
}
```

## Building

Building was tested on MacOS 10.14.4. Since OVis uses MapKit you will need an active [Apple Developer](https://developer.apple.com) membership to sign the executable.

OVis has some preliminary netCDF support, you will need to build netCDF libraries to build OVis. The easiest way to do this is through [homebrew](https://brew.sh). If you do not have homebrew install it by running the follwiong in a MacOS terminal.

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Once you have homebrew installed, you can build netCDF by simply running

```bash
brew install netcdf
```

Once the netCDF libraries are installed the application can be build by opening the **OVis.xcodeproj** project file. The project is already set up for automatic code-signing, so if you have your Apple account set up in XCode everything should compile out of the box.

## .ovis file format

At this point in time the netCDF support is not complete. The easiest way to get data into ovis is through a simple text file with the **.ovis** file-extension. Currently we are at file version 2.6. An example is shown below. All lines (except comments) are mandatory.

```bash
# Lines starting with a # are comments

# All-caps words starting with an underscore are keywords, the following text is the corresponding value.
# In this line the key is _VERSION and the value 2.6. This is the version of the .ovis file format.
_VERSION 2.6

# Boolean switch inidcating whether the file describes structured or unstructured data.
_STRUCTURED YES

# Name of Variable
_VARIABLE Sea Surface Height

# Unit of Variable
_VARIABLE_UNIT m

# Raw Filename relative to ovis file.
# The part before the . needs to be identical with the .ovis filename to support MacOS sandboxing.
# In this example the ovis filename would be example.ovis
_FILENAME_SSH example.raw

# Value used to indicate invalid entries in the data files. E.g. for positions without measurements.
_INVALID_VALUE 9.96920997E+36

# Dimensions in x y z members time, if z is equal to 1 it can also be left out.
_DIMENSIONS 256 128 1 50 10

# Covered Area in Lon/Lat
# Range from -180 to 180, E and N are positive, W and S are negative
# lonmin lonmax latmin latmax
_LONLAT 0.0 25.5 -22.7 -10.0

# Date of first time sample in the following format yyyy/mm/dd hh:mm:ss
_STARTDATE 2019/01/01 00:00:00

# Length of one time step in the following format y+/m+/d+ h+:m+:s+
# Here, the time step is two hours.
_TIMESTEPLENGTH 0/0/0 2:0:0
```

The corresponding **.raw** file only contains the raw data of the ensemble, as 32 bit float with increasing indices from right to left as indicated in _DIMENSIONS. I.e. the indices of the data would look like the following. Note, the actual file must only contain the values at these indices, not the indices themselves.

```
(0,0,0,0,0), (0,0,0,0,1), ... (0,0,0,0,9), (0,0,0,1,0), (0,0,0,1,1), ... (0,0,0,1,9), ... (255,127,0,49,0), (255,127,0,49,1), ... (255,127,0,49,9)
```
