# App

- Fix issue when event, meta data and HK patterns are empty
- Fix issue with closing invalid figures

# Software

- Replace last element of file with `missing` to improve plot where data is missing
- Science object with no data is considered empty in `mag.Instrument`
- Fix issue with consecutive events of the same type missing a completion message
- Fix issue when cropping data and no timestamps are selected