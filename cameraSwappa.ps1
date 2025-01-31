# cameraSwappa
# Version: 1.2.0
# Author: MG

function Get-InstallationPaths {
    param (
        [string]$registryPath
    )
    $paths = @()
    try {
        $regKeys = Get-ChildItem -Path $registryPath
        foreach ($key in $regKeys) {
            # Safely get DisplayName and InstallLocation
            $displayName = (Get-ItemProperty -Path $key.PSPath -Name "DisplayName" -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "*Microsoft Flight Simulator*") {
                $installPath = (Get-ItemProperty -Path $key.PSPath -Name "InstallLocation" -ErrorAction SilentlyContinue).InstallLocation
                if ($installPath) {
                    $paths += $installPath
                } else {
                    Write-Host "No InstallLocation found for $displayName" -ForegroundColor Yellow
                }
            }
        }
    } catch {
        Write-Host "Failed to get installation paths from registry: $registryPath" -ForegroundColor Red
    }
    return $paths
}

# Registry paths for installed applications
$simRegistryPaths = @(
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

$simInstallationPaths = @()
foreach ($path in $simRegistryPaths) {
    $simInstallationPaths += Get-InstallationPaths -registryPath $path
}

if ($simInstallationPaths.Count -eq 0) {
    Write-Host "No MSFS installation detected." -ForegroundColor Red
    exit
}

Write-Host "Detected the following Microsoft Flight Simulator installations:" -ForegroundColor Green
$simInstallationPaths | ForEach-Object { Write-Host "- $_" }

# Prompt User to Select Sim
Write-Host "Select your Microsoft Flight Simulator version:" -ForegroundColor Cyan
for ($i = 0; $i -lt $simInstallationPaths.Count; $i++) {
    Write-Host "[$i] $($simInstallationPaths[$i])"
}
$simChoice = Read-Host "Enter the number of your selection"
$selectedSim = $simInstallationPaths[$simChoice]

# Scan for Aircraft
$officialFolder = "$selectedSim\Official"
$communityFolder = "$selectedSim\Community"
$aircraftPaths = @(Get-ChildItem -Path $officialFolder -Directory) + @(Get-ChildItem -Path $communityFolder -Directory)
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
