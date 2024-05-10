# Software

- Add separate figure in `mag.graphics.view.Frequency` to show field and spectrogram
- Add `mag.time.Constant.Eps` for consistent for consistent definition of `eps` in seconds
- Add `FrequencyPoints` option to specify number of frequency steps in `mag.graphics.chart.Spectrogram`
- Detect mode changes from timestamp cadence, when no event data is available
- Improve algorithm for detecting mode and range cycling
- Do not improve event time estimates for Config mode
- Fix issue with Burst mode auto-exit setting mode to previous, instead of forcing Normal mode
