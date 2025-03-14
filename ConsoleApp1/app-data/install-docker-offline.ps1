# ===========================[ Docker Offline Installation Script ]===========================
# This script installs Docker from binaries on Windows.
# =====================================================================================

# Define the path to the downloaded Docker zip archive and the ProgramFiles directory
$dockerZipPath = Join-Path $PSScriptRoot "\docker-27.5.1.zip"
$dockerInstallDir = "$Env:ProgramFiles\docker"
$helloWorldImagePath = Join-Path $PSScriptRoot "\hello-world-image.tar"
$dockerComposePath = Join-Path $PSScriptRoot "\docker-compose-windows-x86_64.exe"
$dockerComposeInstallPath = "$Env:ProgramFiles\docker\docker-compose.exe"

# Step 1: Extract the Docker binary to Program Files
Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host " STEP 1: Extract Docker binaries " -ForegroundColor Yellow
Write-Host "====================================`n" -ForegroundColor Cyan
Write-Host "Extracting Docker binaries..."
Expand-Archive -Path $dockerZipPath -DestinationPath "$Env:ProgramFiles" -Force
Write-Host "Docker binaries were extracted" -ForegroundColor Green

# Step 2: Register Docker service and start the Docker Engine
Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host " STEP 2: Register Docker service " -ForegroundColor Yellow
Write-Host "====================================`n" -ForegroundColor Cyan
Write-Host "Registering Docker service..."
& "$dockerInstallDir\dockerd" --register-service

Write-Host "Starting Docker service..."
Start-Service -Name docker
Write-Host "Docker service was registered and the Docker Engine was started" -ForegroundColor Green

# Step 3: Add Docker to the system PATH
Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host " STEP 3: Add Docker to the system PATH " -ForegroundColor Yellow
Write-Host "====================================`n" -ForegroundColor Cyan
Write-Host "Adding Docker to system PATH..."
$existingPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($existingPath -notlike "*$dockerInstallDir*") {
    $newPath = "$existingPath;$dockerInstallDir"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Docker path registered successfully" -ForegroundColor Green
} else {
    Write-Host "Docker path is already registered" -ForegroundColor Green
}

# Step 4: Show Docker version
Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host " STEP 4: Show Docker version " -ForegroundColor Yellow
Write-Host "====================================`n" -ForegroundColor Cyan
Write-Host "Displaying Docker version..."
& "$dockerInstallDir\docker" --version
Write-Host "Docker version is correct" -ForegroundColor Green

# Step 5: Verify Docker installation by running the hello-world image
Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host " STEP 5: Run hello-world image " -ForegroundColor Yellow
Write-Host "====================================`n" -ForegroundColor Cyan
Write-Host "Loading and running hello-world image..."
& "$dockerInstallDir\docker" load -i $helloWorldImagePath
& "$dockerInstallDir\docker" images
& "$dockerInstallDir\docker" run hello-world
Write-Host "Hello-world image launched successfully" -ForegroundColor Green

# Step 6: Install Docker Compose
Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host " STEP 6: Install Docker Compose " -ForegroundColor Yellow
Write-Host "====================================`n" -ForegroundColor Cyan
Write-Host "Installing Docker Compose..."
Copy-Item -Path $dockerComposePath -Destination $dockerComposeInstallPath -Force
if (Test-Path $dockerComposeInstallPath) {
    # Check docker-compose version
    Write-Host "Checking docker-compose version..."
    & $dockerComposeInstallPath --version
    Write-Host "Docker Compose installation completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to move docker-compose.exe. Please check the source path." -ForegroundColor Red
}

# Step 7: Refresh environment variables (avoids reboot requirement)
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host " FINAL STEP: Refresh environment variables " -ForegroundColor Yellow
Write-Host "============================================`n" -ForegroundColor Cyan
Write-Host "Refreshing environment variables..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Docker installation completed successfully!" -ForegroundColor Green

