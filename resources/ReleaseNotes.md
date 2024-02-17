# App

- Fix issue where save location was taken off edit field, instead of analysis object

# Software

## I-ALiRT

- Add plot for comparison of I-ALiRT and science data and timestamps
- Export I-ALiRT data
- Separate `ScienceProcessing` and `IALiRTProcessing` in `mag.IMAPTestingAnalysis`
- Also crop I-ALiRT data when calling `cropScience`
- Fix wrong values for I-ALiRT data and packet frequency

## Other

- Add quality flag to describe data quality and filter data in plots
- Improve estimate of mode change event timestamp
- Allow filtering both by time and number of vectors in `mag.process.Filter`
- Add operations to plot composite variables (e.g., difference between variables, convert variable value, etc.)
- Add optional global legend to figures generated with `mag.graphics.visualize`
- Add option to change tile indexing in figures generated with `mag.graphics.visualize`
- Add sensor name in "ramp inconsistent" warning
- Remove check of mistimed packets
- Remove logic to handle old versions of `mag.IMAPTestingAnalysis` in MAT files
- Replace `fillWarpUp` with `cropScience` in SFT plots
- Make sure range cycling primary and secondary science data are of the same size
- Fix issue with too many sensor events being filtered out when processing science