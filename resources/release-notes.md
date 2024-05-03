# Software

## Graphics

- Add plot for science timestamp Δt in `mag.graphics.view.Timestamp`
- Replace use of `mag.graphics.visualize` in views with abstract factory pattern
- Default `Visible` value in `mag.graphics.visualize` now comes from `matlab.ui.Root/DefaultFigureVisible`
- Rename `mag.graphics.getAllAxes` to `mag.test.getAllAxes`
- Fix issue with views not handling `NaT`
- Add cleanup to all graphics tests, to close any figures opened during the test
- Add tests for `mag.graphics.view.Field`

## Other

- Add `mag.mixin.Signal` as interface for signal-like classes
- Add `resample` and `downsample` methods to `mag.IALiRT`
- Add check for constant rate in `mag.Science/downsample`
- Use `event` continuity variable for `mag.Science/Quality` property
- Do not resample or downsample if target frequency is equal to actual frequency
- Rename `mag.mixin.Croppable` to `mag.mixin.Crop`
- Fix issue with `mag.meta.Quality` not being compatible with `NaN`s

# Workspace

- Add license file
- Add VS Code settings file
