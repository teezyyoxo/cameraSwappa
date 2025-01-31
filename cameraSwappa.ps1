# cameraSwappa
# Version: 1.3.2
# Author: MG
# Description: This script allows you to easily swap out the cameras.cfg file for a specific aircraft in Microsoft Flight Simulator 2020 or 2024.
# Usage: Run the script and follow the prompts to select the aircraft and the new cameras.cfg file.
# Note: This script requires PowerShell 5.1 or later.

function Get-SimulatorPaths {
    $paths = @()

    # Check for Microsoft Store version of MSFS 2020 and 2024
    $msfs2020Path = "C:\Users\$env:USERNAME\AppData\Local\Packages\Microsoft.FlightSimulator_8wekyb3d8bbwe"
    $msfs2024Path = "C:\Users\$env:USERNAME\AppData\Local\Packages\Microsoft.Limitless_8wekyb3d8bbwe"
    if (Test-Path $msfs2020Path) {
        $paths += @{ "Sim" = "MSFS 2020"; "Source" = "MS Store"; "Path" = $msfs2020Path }
    }
    if (Test-Path $msfs2024Path) {
        $paths += @{ "Sim" = "MSFS 2024"; "Source" = "MS Store"; "Path" = $msfs2024Path }
    }

    # Check for Steam version of MSFS
    $steamPath = "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft Flight Simulator"
    if (Test-Path $steamPath) {
        $paths += @{ "Sim" = "Steam MSFS"; "Source" = "Steam"; "Path" = $steamPath }
    }

    return $paths
}

# Detect available simulators
$simInstallationPaths = Get-SimulatorPaths

if ($simInstallationPaths.Count -eq 0) {
    Write-Host "No MSFS installation detected." -ForegroundColor Red
    exit
}

Write-Host "Detected the following Microsoft Flight Simulator installations:" -ForegroundColor Green
$simInstallationPaths | ForEach-Object { Write-Host "- $($_.Sim) ($($_.Source))" }

# Prompt User to Select Sim
Write-Host "Select your Microsoft Flight Simulator version:" -ForegroundColor Cyan
for ($i = 0; $i -lt $simInstallationPaths.Count; $i++) {
    Write-Host "[$i] $($simInstallationPaths[$i].Sim) ($($simInstallationPaths[$i].Source))"
}
$simChoice = Read-Host "Enter the number of your selection"
$selectedSim = $simInstallationPaths[$simChoice]

Write-Host "You selected $($selectedSim.Sim) ($($selectedSim.Source))"

# Define aircraft folders for MSFS 2020 and MSFS 2024
if ($selectedSim.Sim -eq "MSFS 2020") {
    $officialFolder = "$($selectedSim.Path)\LocalCache\Packages\Community"
    $aircraftFolder = "$($selectedSim.Path)\LocalCache\SimObjects\Airplanes"
} elseif ($selectedSim.Sim -eq "MSFS 2024") {
    $officialFolder = "$($selectedSim.Path)\LocalCache\Packages\Community"
    $aircraftFolder = "$($selectedSim.Path)\LocalCache\SimObjects\Airplanes"
}

# Scan for Aircraft
$aircraftPaths = @(Get-ChildItem -Path $aircraftFolder -Directory)

if ($aircraftPaths.Count -eq 0) {
    Write-Host "No aircraft found in the installation folders." -ForegroundColor Red
    exit
}

# List Aircraft
Write-Host "Available Aircraft:" -ForegroundColor Cyan
for ($i = 0; $i -lt $aircraftPaths.Count; $i++) {
    Write-Host "[$i] $($aircraftPaths[$i].Name)"
}
$aircraftChoice = Read-Host "Enter the number of the aircraft to modify"
$selectedAircraft = $aircraftPaths[$aircraftChoice].FullName
$camerasCfgPath = "$selectedAircraft\cameras.cfg"

# Backup Existing cameras.cfg
if (Test-Path $camerasCfgPath) {
    $backupIndex = 0
    do {
        $backupIndex++
        $backupFile = if ($backupIndex -eq 1) { "$camerasCfgPath.orig" } else { "$camerasCfgPath.orig.$backupIndex" }
    } while (Test-Path $backupFile)
    Copy-Item -Path $camerasCfgPath -Destination $backupFile
    Write-Host "Backup created: $backupFile" -ForegroundColor Green
} else {
    Write-Host "No existing cameras.cfg file found, skipping backup." -ForegroundColor Yellow
}

# Prompt for New File
Write-Host "Drag and drop the new cameras.cfg file here:" -ForegroundColor Cyan
$newFilePath = Read-Host "Enter the full path of the new cameras.cfg"
if (-not (Test-Path $newFilePath)) {
    Write-Host "Invalid file path. Exiting." -ForegroundColor Red
    exit
}
Copy-Item -Path $newFilePath -Destination $camerasCfgPath -Force
Write-Host "Replacement complete." -ForegroundColor Green

# Logging
$logPath = "$selectedAircraft\modification.log"
$logSize = 50KB
if ((Test-Path $logPath) -and ((Get-Item $logPath).Length -gt $logSize)) {
    Rename-Item -Path $logPath -NewName "modification_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}
"[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Replaced cameras.cfg with $newFilePath" | Out-File -Append -FilePath $logPath

# Open Folder
Start-Process explorer.exe -ArgumentList "$selectedAircraft"