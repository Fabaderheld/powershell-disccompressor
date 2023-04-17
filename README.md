# Compress-Games.ps1

`Compress-Games.ps1` is a PowerShell script that compresses disc images according to the support of emulators. The script supports the following formats:

- `BIN/CUE`: compressed into CHD with `chdman`
- `ISO`: compressed into CHD since pcsx2 supports CHD since 1.7
- `CSO`: converted to ISO and then compressed into CHD with `chdman`
- `PS3/Folders`: compressed with `mksquashfs`

The script uses the following parameters:

- `Path`: path to batocera share folder (default: `/mnt/batocera/roms`)
- `CHDMan`: path to `chdman` binary (default: `/usr/bin/chdman`)
- `MaxCSO`: path to `maxcso` binary (default: `~/maxcso/maxcso`)
- `Systems`: systems to look for (default: `psx.ps2,ps3,dreamcast`)
- `Silent`: suppresses warnings
- `Whatif`: shows what the script will do without actually doing it

## Usage

~~~
PS C:> Compress-Games.ps1 -Path "C:\Games\roms"
~~~


The command above will try to compress all games in `C:\Games\roms` according to batocera file structure, e.g., `c:\Games\roms\ps3`.

## Parameters

- `Path`: Path to batocera share folder
- `CHDMan`: Path to `chdman` binary, e.g., `chdman.exe`
- `MaxCso`: Path to `maxcso` binary, e.g., `maxcso.exe`
- `Systems`: Which systems should be looked for, defaults to `psx.ps2,ps3,dreamcast`
- `Silent`: Suppresses warnings
- `Whatif`: Shows what the script will do without actually doing it

## Inputs and Outputs

None.

## Notes

This script follows the guide used from batocera wiki https://wiki.batocera.org/disk_image_compression.
