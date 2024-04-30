# Software

- Add `mag.mixin.Signal` as interface for signal-like classes
- Add `resample` and `downsample` methods to `mag.IALiRT`
- Add check for constant rate in `mag.Science/downsample`
- Do not resample or downsample if target frequency is equal to actual frequency
- Rename `mag.mixin.Croppable` to `mag.mixin.Crop`
