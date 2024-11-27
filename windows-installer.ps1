$ErrorActionPreference = "Stop"

# Step 1: Ensure WSL is installed
Write-Host "Checking for WSL installation..."
try {
    wsl --list | Out-Null
    Write-Host "WSL is already installed."
} catch {
    Write-Host "WSL is not installed. Checking system compatibility..."
    
    # Check if the system supports virtualization
    $virtSupport = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty VirtualizationFirmwareEnabled
    if (-not $virtSupport) {
        Write-Host "System does not support virtualization. WSL cannot be installed. Exiting."
        pause
        exit
    }
    
    # Install WSL
    Write-Host "Installing WSL..."
    wsl --install
    Write-Host "WSL installation completed. Please restart your system and rerun the script."
    pause
    exit
}

# Step 2: Ensure Windows Package Manager (winget) is available
Write-Host "Checking for Windows Package Manager (winget)..."
if (!(Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-Host "Windows Package Manager (winget) is not available. Please update your system to Windows 10 (2004) or later."
    pause
    exit
} else {
    Write-Host "Windows Package Manager (winget) is available."
}

# Step 3: Install Docker Desktop using winget
Write-Host "Checking for Docker Desktop installation..."
if (!(Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Desktop is not installed. Installing Docker Desktop via winget..."

    $wingetProcess = Start-Process -FilePath "winget" -ArgumentList "install -e --id Docker.DockerDesktop --accept-source-agreements --accept-package-agreements" -NoNewWindow -PassThru -Wait

    if ($wingetProcess.ExitCode -eq 0) {
        Write-Host "Docker Desktop installation completed successfully."
    } else {
        Write-Host "Docker Desktop installation failed or requires manual steps. Exit code: $($wingetProcess.ExitCode)"
        pause
        exit
    }
} else {
    Write-Host "Docker Desktop is already installed."
}

# Step 4: Ensure Docker Desktop is running
Write-Host "Ensuring Docker Desktop is running..."
$dockerDesktopPath = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
if (!(Get-Process "Docker Desktop" -ErrorAction SilentlyContinue)) {
    if (Test-Path $dockerDesktopPath) {
        Start-Process -FilePath $dockerDesktopPath
        Write-Host "Starting Docker Desktop..."
    } else {
        Write-Host "Docker Desktop executable not found. Please start it manually."
        pause
        exit
    }
} else {
    Write-Host "Docker Desktop is already running."
}

# Step 5: Wait for Docker Daemon to be ready
Write-Host "Checking for Docker Daemon availability..."
$maxRetries = 30  
$retryInterval = 10  
$attempt = 0
$dockerReady = $false

while ($attempt -lt $maxRetries -and -not $dockerReady) {
    try {
        # Check if 'docker' command is available
        if (!(Get-Command "docker" -ErrorAction SilentlyContinue)) {
            Write-Host "Docker CLI is not available in PATH. Retrying in $retryInterval seconds... (Attempt $($attempt + 1) of $maxRetries)"
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
            Start-Sleep -Seconds $retryInterval
            $attempt++
            continue
        }

        docker version | Out-Null
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            $dockerReady = $true
            Write-Host "Docker Daemon is ready."
        } else {
            Write-Host "Docker Daemon is not ready yet. Retrying in $retryInterval seconds... (Attempt $($attempt + 1) of $maxRetries)"
            Start-Sleep -Seconds $retryInterval
            $attempt++
        }
    } catch {
        Start-Sleep -Seconds $retryInterval
        $attempt++
    }
}

if (-not $dockerReady) {
    Write-Host "Docker Daemon did not become ready within the expected time. Please check Docker Desktop and try again."
    pause
    exit
}


# Step 6: Run docker-compose to deploy the cluster
Write-Host "Starting the Docker cluster using docker-compose..."
$composeFile = ".\docker-compose.yml"

if (!(Test-Path $composeFile)) {
    Write-Host "docker-compose.yml file not found in the current directory. Please create it and try again."
    pause
    exit
}

try {
    docker-compose up -d
    Write-Host "Docker cluster started successfully."
} catch {
    Write-Host "Failed to start the cluster. Error: $_"
    pause
    exit
}

# Step 7: Verify the deployment
Write-Host "Verifying the cluster deployment..."
$runningContainers = docker ps
if ($runningContainers -match "cloudbeaver") {
    Write-Host "Cluster is running successfully!"
    docker-compose logs -f
} else {
    Write-Host "Cluster deployment might have issues. Check the logs:"
    docker-compose logs
}
