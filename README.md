# MAG Data Visualization Toolbox

[![MATLAB Tests](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/actions/workflows/matlab.yml/badge.svg)](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/actions/workflows/matlab.yml)

This repository contains utilities for processing and visualizing MAG science and HK data. The supported MATLAB releases are MATLAB R2023b and later. The following MATLAB toolboxes are required to use the toolbox:

* MATLAB
* Signal Processing Toolbox
* Statistics and Machine Learning Toolbox
* Text Analytics Toolbox

## Getting Started

The toolbox adds to the path many functions and classes that can be used for data processing and visualization. These can be found under the `mag` namespace; you can use tab-completion to see what is available:
``` matlab
mag.<TAB>
```
In the sections below you can find more information about some of the functionalities.

## User Manual

### Visualization

TBD

### Data Processing

TBD

### App

The `DataVisualization` app provides an interface to the `mag.IMAPTestingAnalysis` object. It can be used for quick visualization of data collected during an AT, CPT or SFT. 

## Development

When developing new features or fixing issues, create a new branch. After finishing development, make sure to write tests to cover any new changes. 

To change the version of the toolbox, modify the `VERSION` variable in `.github/workflows/matlab.yml`. This will automatically updated the toolbox version and create a new release with the correct tag.
Also, update the contents of the `resources/ReleaseNotes.md` file by detailing what has changed in the new version.
