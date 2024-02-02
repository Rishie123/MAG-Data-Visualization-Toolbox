# App

- Fix issue when event, meta data and HK patterns are empty
- Fix issue with closing invalid figures

# Software

- Add method to `mag.Instrument` to fill warm-up with `missing` data
- Add method to `mag.Science` to replace periods with a filler variable
- Replace last element of file with `missing` to improve plot where data is missing
- Science object with no data is considered empty in `mag.Instrument`
- Reintroduce filtering for charts
- Rename `cropDataBasedOnScience` to `cropToMatch`
- Make sure derivative is empty when data is empty
- Remove unnecessary `Sealed` attributes on classes
- Fix issue with consecutive events of the same type missing a completion message
- Fix issue when cropping data and no timestamps are selected
- Fix issue with `mag.graphics.chart.Stem` not showing markers
- Add tests for `mag.Instrument`, `mag.PSD` and `mag.Science/computePSD`
- Add tests for `mag.graphics.mixin.mustBeColor`
- Fix typo in `MarkerSupportTestCase`