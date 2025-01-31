# cameraSwappa
# Version: 1.0.1
# Author: MG

# Changelog:
# - Added console output when a simulator is detected

$MSFSPaths = @{
    "MSFS 2020" = "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft Flight Simulator"  # Adjust as needed
    "MSFS 2024" = "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft Flight Simulator 2024"  # Adjust as needed
}

# Detect Installed Sims
$availableSims = $MSFSPaths.Keys | Where-Object { Test-Path $MSFSPaths[$_] }
if ($availableSims.Count -eq 0) {
    Write-Host "No MSFS installation detected." -ForegroundColor Red
    exit
}

Write-Host "Detected the following Microsoft Flight Simulator installations:" -ForegroundColor Green
$availableSims | ForEach-Object { Write-Host "- $_" }

# Prompt User to Select Sim
Write-Host "Select your Microsoft Flight Simulator version:" -ForegroundColor Cyan
for ($i = 0; $i -lt $availableSims.Count; $i++) {
    Write-Host "[$i] $($availableSims[$i])"
}
$simChoice = Read-Host "Enter the number of your selection"
$selectedSim = $availableSims[$simChoice]
$simPath = $MSFSPaths[$selectedSim]

# Scan for Aircraft
$officialFolder = "$simPath\Official"
$communityFolder = "$simPath\Community"
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
        $backupFile = "$camerasCfgPath.orig$($backupIndex -eq 1 ? '' : ".$backupIndex")"
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
