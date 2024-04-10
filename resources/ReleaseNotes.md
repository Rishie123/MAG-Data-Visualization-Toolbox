# App

- Rename `Analysis` and `MAT` options to clearer names
- Ask user whether to overwrite `analysis` variable in workspace

# Software

- Add support for reading Word documents containing meta data
- Capture information about GSE version in `mag.meta.Instrument`
- Do not use cropped results for plotting of HK in `mag.graphics.sftPlots`
- Ignore I-ALiRT during ramp mode
- Increase robustness of detection of nearest I-ALiRT packet in `mag.graphics.view.IALiRT`
- Fix issue with Config events having data and packet frequency equal to 0
- Fix issue with `mag.internal.useParallel` requiring Parallel Computing Toolbox
- Fix typos in `mag.meta.log.Excel`
