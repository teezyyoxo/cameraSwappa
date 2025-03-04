# Changelog
All changes to this project will be documented here.

## [1.3.2]
- Resolved installed-sim lookup function failure by using static install paths
- Updated aircraft path locations for MSFS 2020 and MSFS 2024.

## [1.3.1]
- Updated to detect MSFS 2020 and MSFS 2024 installations from Microsoft Store and Steam.
- Added user selection prompt for which sim to proceed with.


## [1.3.0]
- Added more thorough filtering for Microsoft Flight Simulator 2020 and 2024 installations.
- Ensured registry checking continues across all entries, avoiding an early exit.

## [1.2.0]
- Improved registry lookup for MSFS installations.
- Enhanced error handling and logging for registry retrieval.
- More robust checking for valid DisplayName and InstallLocation.

## [1.1.0]
### Changed
- Updated script to check for installed sims using the registry.
- Improved error handling and logging.

## [1.0.1]
### Added
- Console output when a simulator is detected.

## [1.0.0]
### Initial Release
- First version of the MSFS Cameras.cfg Replacer script
- Detects installed MSFS versions and lists available aircraft.
- Backs up existing cameras.cfg files before replacing them.
- Logs all modifications and ensures log file rotation at 50KB.
- Opens aircraft folder after modification.