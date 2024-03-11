# App

- Add button to close generated figures
- Fix issue with assigning value of `DebugStatus` when more than one breakpoint is set

# Software

- Add description of both Normal and Burst mode in `mag.event.ModeChange`, regardless of the active mode
- Add mode events in I-ALiRT timestamp comparison plot in `mag.graphics.view.IALiRT`
- Allow specifying multiple labels and label alignment in `mag.graphics.chart.Line`
- Move removal of all-zero vectors in data after removal of missing data
- Improve algorithm to find closest science and I-ALiRT timestamps
- Fix issue with `UNCHANGED` data frequency appearing as `NaN` in event log
- Fix issue with filtering I-ALiRT secondary data in `mag.graphics.view.IALiRT`
- Fix issue with PSDs showing large noise in mode and range cycling
