# App

- Add support for I-ALiRT data

# Software

- Add support for I-ALiRT data
- Add view for plotting PSD for each selected event
- Simplify custom displays logic
- Simplify calculation of derivatives when input is empty
- Improve "no-Range 0" Range Cycling plot by excluding first Range 0 vector
- Replace `/` and `\` from figure file name when saving
- Allow using `tiledlayout` with `mag.graphics.getAllAxes`
- Fix issue with detecting automated range changes happening after range change commands
- Fix issue with warning generation in `mag.process.Ramp`
- Fix issue with loading `mag.IMAPTestingAnalysis` from versions without separate HK classes per type
- Fix issue with `mag.graphics.chart.Stackedplot` graphs with markers
- Fix issue with `mag.graphics.chart.Stackedplot` not erroring on empty color input
- Add tests for `mag.meta.Data` and `mag.graphics.chart.Stackedplot`