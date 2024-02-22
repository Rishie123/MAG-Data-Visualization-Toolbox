# Software

- Add compression flag to `mag.Science`
- Add settings file to specify name of `timetable` properties for `mag.Science`
- Add `Compression` property to supported events for plotting
- Add `YAxisLocation` for `mag.graphics.style.Default` and `mag.graphics.style.Stackedplot`
- Shift `YAxisLocation` to "right" for plots on right-hand side of some views: `mag.graphics.view.Field`, `mag.graphics.view.Frequency`, `mag.graphics.view.HK`, `mag.graphics.view.IALiRT`, and `mag.graphics.view.RampMode`
- Create `mag.meta.Mode` enumeration to capture sensor science mode
- Move definition of time constants to shared utility file `mag.time.Constant`
- Make `mag.process.Range` and `mag.process.SignedInteger` more flexible to custom variable names
- Make sure converted values in `mag.process.SignedInteger` are returned as `double`
- Fix [#10](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/issues/10)
- Fix [#19](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/issues/19)
- Add tests for processing step documentation properties
