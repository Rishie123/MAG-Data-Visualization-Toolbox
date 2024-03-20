# App

- Add drop down and text field to browse and view all processing steps separately
- Add check box to select whether to plot PSD
- Add tooltips for meta data text areas and toolstrip buttons

# Software

- Add fine-grained definitions of quality flags (see `mag.meta.Quality`)
- Update previous uses of quality flag
- Allow cropping of `mag.Science` with negative duration (filters from the end)
- Allow cropping of I-ALiRT with separate filter for primary and secondary
- Add conversion method `eventtable` in `mag.event.Event` to simplify logic in science analysis
- Add tests for `mag.event.Event`, `mag.event.ModeChange`, `mag.event.RangeChange` and `mag.event.RampMode`
