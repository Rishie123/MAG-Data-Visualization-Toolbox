# Software

- Add view (`mag.graphics.view.Timestamp`) for analyzing primary and secondary science timestamps
- Improve handling of "croppable" data (inheriting from `mag.mixin.Croppable`) with utility methods `mustBeTimeFilter` and `convertToTimeSubscript`
- Do not use "Primary" or "Secondary" in sensor event labels
- Single-source definition of empty event and science event timetables
- Remove processing-specific constants from event definition
- Fix [#43](https://github.com/ImperialCollegeLondon/MAG-Data-Visualization-Toolbox/issues/43)
- Fix issue with `mag.Instrument/Events` not being part of deep copy
- Fix hardcoded `x`, `y` and `z` strings in `mag.Science`

# GitHub

- Add template for bug issues
