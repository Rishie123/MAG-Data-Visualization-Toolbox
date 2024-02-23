# Software

## Compression

- Add processing step `mag.process.Compression` to correct for compression factor
- Allow filtering around compression changes in `mag.process.Filter`
- Fix issue in `mag.process.SignedInteger` with compression still using 16th bit for signedness, instead of 18th
- Fix typos in compression event plot

## Other

- Add variable continuity definition for science variables in `timetable`
- Add shutdown event as final event in `mag.Science` event table
- Add property `Harness` in `mag.meta.Science` to describe sensor harness
- Simplify how columns are filtered in loading science and I-ALiRT
- Make `mag.process.Calibration` more flexible to custom variable names
- Allow plotting more than one event in `mag.graphics.view.Field`
- Change event type to `categorical` when data is not numeric
- Add option to create folder in `mag.graphics.savePlots`
- Fix issue with loading Excel files containing sensor meta data
- Fix issue in custom events chart when event value is not `double` or `single`
