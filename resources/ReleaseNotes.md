# Software

- Add separate classes for each specific HK type
- Make `crop` a method of `mag.TimeSeries` 
- Customize `get` method of `mag.Data` to accept multiple property names
- Allow charts to have `mag.Data` as input
- Rename `mag.AutomatedAnalysis` to `mag.IMAPTestingAnalysis`
- Rename `mag.Result` to `mag.PSD`
- Remove support for `Filters` in charts
- Remove implicit conversion methods for `table`, `timetable` and `tabular`
- Fix issues with setting colors in charts
- Add tests for `mag.Data` and `mag.Science`
- Add tests for `mag.graphics.chart.Area`, `mag.graphics.chart.Scatter`, `mag.graphics.chart.Stairs` and `mag.graphics.chart.Stem` plots

# GitHub Workflows

- Update dependencies to latest versions