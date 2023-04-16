<#
.SYNOPSIS
    Compresses disc images according to support of emulators
.DESCRIPTION
    Guide used from batocera wiki https://wiki.batocera.org/disk_image_compression
    BIN/CUE will be compressed into CHD with chdman
    ISO will be commpressed into CSO with maxcso or to CHD since pcsx2 supports CHD since 1.7
    CSO to CHD via decompressing to ISO and then into CHD
    PS3/Folders Games will be compressed with mksquashfs
.EXAMPLE
    PS C:\> Compress-Games.ps1 -Path "C:\Games\roms"
    Will try to compress all games in C:\Games\roms according to batocera filestructure e.g. c:\Games\roms\ps3
.PARAMETER Path
    Path to batocera share folder
.PARAMETER CHDMan
    Path to chdman binary e.g. chdman.exe
.PARAMETER MaxCso
    Path to maxcso binary e.g. maxcso.exe
.PARAMETER Systems
    Which systems should be looked for, defaults to psx.ps2,ps3,dreamcast
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

[CmdletBinding()]
param (
    [Parameter()]
    [Alias("BatoceraPath")]
    [String]
    $Path = "/mnt/batocera/roms",
    [String]
    $CHDMan = "/usr/bin/chdman",
    [String]
    $MaxCSO = "~/maxcso/maxcso",
    [String[]]
    [ValidateSet("PS", "PS2", "PS3", "Dreamcast")]
    $Systems = @("PS", "PS2", "PS3", "Dreamcast"),
    [Switch]
    $Silent,
    [Switch]
    $Whatif
)

$ErrorActionPreference = "Stop"

function Compress-Game {
    param (
        [String]
        $Source,
        [String]
        $Destination,
        [String]
        [ValidateSet("ISO", "CUE", "Directory", "ps3")]
        $Format,
        [Switch]
        $Whatif
    )


    # Testing source file
    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Error "Source file $Source not found"
        break
    }

    $Game = Get-ChildItem -LiteralPath $Source

    # if ($Format -eq "iso") {
    #     Write-Verbose "Source format is ISO"
    #     $CompressedFile = $Game.Fullname -replace "iso", "cso"
    #     $Command = "'$MaxCSO '$($Game.FullName)''"
    #     Write-Verbose "Compressing $($Game.FullName)"
    #     if (-not (Test-Path -LiteralPath $CompressedFile)) {
    #         if ($whatif) {
    #             "$MaxCSO '$($Game.FullName)'"
    #         }
    #         else {
    #             & $MaxCSO "$($Game.FullName)"
    #         }
    #     }
    #     else {
    #         if (-not $Silent) {
    #             Write-Warning "$($Game.Name) already compressed"
    #         }
    #     }

    # }
    if ($Format -eq "iso") {
        Write-Verbose "Source format is ISO"
        $CompressedFile = $Game.Fullname -replace "iso", "chd"
        $Command = "'$MaxCSO '$($Game.FullName)''"
        Write-Verbose "Compressing $($Game.FullName)"
        if (-not (Test-Path -LiteralPath $CompressedFile)) {
            if ($whatif) {
                "$CHDMan createcd -i '$($Game.FullName)' -o '$CompressedFile' --force"
            }
            else {
                & $CHDMan createcd -i "$($Game.FullName)" -o "$CompressedFile" --force
            }
        }
        else {
            if (-not $Silent) {
                Write-Warning "$($Game.Name) already compressed"
            }
        }

    }
    elseif ($Format -eq "cue") {
        Write-Verbose "Source format is BIN/CUE"
        $CompressedFile = $Game.Fullname -replace "cue", "chd"
        $Command = "$CHDMan createcd -i '$($Game.FullName)' -o '$CompressedFile' --force"
        Write-Verbose "Compressing $($Game.FullName)"
        if (-not (Test-Path -LiteralPath $CompressedFile)) {
            if ($whatif) {
                "$CHDMan createcd -i '$($Game.FullName)' -o '$CompressedFile' --force"
            }
            else {
                & $CHDMan createcd -i "$($Game.FullName)" -o "$CompressedFile" --force
            }
        }
        else {
            if (-not $Silent) {
                Write-Warning "$($Game.Name) already compressed"
            }
        }
    }
    elseif ($Format -eq "Directory") {
        Write-Verbose "Source format is a folder"
        Write-Verbose "$Game"
        $Game = $Game.Directory
        $CompressedFile = "$($Game.Fullname).squashfs"
        Write-Verbose "Compressed file will be $CompressedFile"
        $Command = "'mksquashfs '$($Game.FullName)' '$CompressedFile''"
        Write-Verbose "Compressing $($Game.FullName)"
        if (-not (Test-Path -LiteralPath $CompressedFile)) {
            if ($whatif) {
                $Command
            }
            else {
                mksquashfs "$($Game.FullName)" "$CompressedFile"
            }
        }
        else {
            if (-not $Silent) {
                Write-Warning "$($Game.Name) already compressed"
            }
        }
    }
    elseif ($Format -eq "CSO") {
        Write-Verbose "Source format is CSO"
        $CompressedFile = $Game.Fullname -replace "cso", "chd"
        $tempfile = $Game.Fullname -replace "cso", "iso"
        Write-Verbose "Compressing $($Game.FullName)"
        if (-not (Test-Path -LiteralPath $CompressedFile)) {
            if ($whatif) {
                "$CHDMan createcd -i '$($Game.FullName)' -o '$CompressedFile' --force"
            }
            else {
                & $MaxCSO "$($Game.FullName)" --decompress -o "$tempfile"
                & $CHDMan createcd -i "$tempfile" -o "$CompressedFile" --force
            }
        }
        else {
            if (-not $Silent) {
                Write-Warning "$($Game.Name) already compressed"
            }
        }

    }

    if ($Whatif) {
        $Global:whatif = $Whatif
    }

    foreach ($System in $Systems) {

        Write-Verbose "Looking for $System"


        # PSX Games
        if ($System -eq "PS") {

            if (-not $Silent) {
                Write-Output "Checking PlayStation Games"
            }

            # Compress BIN/CUE to CHD
            $Games = Get-ChildItem $Path/$($System.ToLower()) -File -Recurse | Where-Object { $_.Name -like "*.cue" }
            foreach ($Game in $Games) {
                Write-Verbose "Working on Game: $($Game.FullName)"
                Compress-Game -Source $Game.FullName -Format "cue"
            }
        }

        # PS2 Games
        if ($System -eq "PS2") {
            if (-not $Silent) {
                Write-Output "Checking PlayStation 2 Games"
            }

            # Compress ISOs to CHD
            $Games = Get-ChildItem $Path/$($System.ToLower()) -File -Recurse | Where-Object { $_.Name -like "*.iso" }
            foreach ($Game in $Games) {
                Write-Verbose "Working on Game: $($Game.FullName)"
                Compress-Game -Source $Game.FullName -Format "iso"
            }

            # Compress ISOs to CSO
            $Games = Get-ChildItem $Path/$($System.ToLower()) -File -Recurse | Where-Object { $_.Name -like "*.iso" }
            foreach ($Game in $Games) {
                Write-Verbose "Working on Game: $($Game.FullName)"
                Compress-Game -Source $Game.FullName -Format "iso"
            }

            # Compress BIN/CUE to CHD
            $Games = Get-ChildItem $Path/$($System.ToLower()) -File -Recurse | Where-Object { $_.Name -like "*.cue" }
            foreach ($Game in $Games) {
                Write-Verbose "Working on Game: $($Game.FullName)"
                Compress-Game -Source $Game.FullName -Format "cue"
            }
        }

        # PS3 Games
        if ($System -eq "PS3") {
            if (-not $Silent) {
                Write-Output "Checking PlayStation 3 Games"
            }

            # Compress Folders to Squashfs
            $Games = Get-ChildItem $Path/$($System.ToLower()) -Directory  | Where-Object { $_.Name -like "*.ps3" }
            foreach ($Game in $Games) {
                Write-Verbose "Working on Game: $($Game.FullName)"
                Compress-Game -Source $Game.FullName -Format "Directory"
            }
        }

        # Dreamcast Games
        if ($System -eq "Dreamcast") {

            if (-not $Silent) {
                Write-Output "Checking Dreamcast Games"
            }

            # Compress BIN/CUE to CHD
            $Games = Get-ChildItem $Path/roms/$($System.ToLower()) -File -Recurse | Where-Object { $_.Name -like "*.cue" }
            foreach ($Game in $Games) {
                Write-Verbose "Working on Game: $($Game.FullName)"
                Compress-Game -Source $Game.FullName -Format "cue"
            }
        }
    }