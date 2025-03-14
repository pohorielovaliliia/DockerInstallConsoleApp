# PowerShell Script to Uninstall Docker (Installed from Binaries)

# Step 1: Stop Docker processes if running
Write-Host "Stopping Docker processes..."
Stop-Process -Name "docker" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "dockerd" -Force -ErrorAction SilentlyContinue

# Step 2: Stop and remove Docker service (if registered)
Write-Host "Removing Docker service (if exists)..."
if (Get-Service -Name "docker" -ErrorAction SilentlyContinue) {
    Stop-Service -Name "docker" -Force -ErrorAction SilentlyContinue
    sc.exe delete docker
    Write-Host "Docker service removed."
} else {
    Write-Host "Docker service not found."
}

# Step 3: Remove Docker binaries directory (default location)
$dockerInstallDir = "$Env:ProgramFiles\Docker"
if (Test-Path $dockerInstallDir) {
    Write-Host "Removing Docker installation directory..."
    Remove-Item -Recurse -Force $dockerInstallDir
    Write-Host "Docker binaries removed."
} else {
    Write-Host "Docker installation directory not found."
}

# Step 4: Remove Docker from the system PATH
Write-Host "Removing Docker from system PATH..."
$existingPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
$newPath = ($existingPath -split ";" | Where-Object {$_ -notlike "*Docker*"} ) -join ";"
[System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)

# Step 5: Refresh environment variables (no reboot required)
Write-Host "Refreshing environment variables..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

Write-Host "Docker has been successfully removed from the system."
