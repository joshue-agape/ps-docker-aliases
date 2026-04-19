# Description:
# Lists running Docker Compose services from a given project directory
# Uses docker-compose.yml file in the specified path
#
# Usage:
# dComposes
# dComposes -Path "."
# dComposes -Path "C:\my-project"
function dComposes {
    param(
        [string]$Path = "."
    )

    $composeFile = Join-Path $Path "docker-compose.yml"

    if (-not (Test-Path $composeFile)) {
        Write-Host "❌ docker-compose.yml not found in '$Path'." -ForegroundColor Red
        return
    }

    Write-Host "📦 Listing Docker Compose services..." -ForegroundColor Cyan

    docker compose -f $composeFile ps
}


# Description:
# Starts Docker Compose services
# Runs in detached mode by default if -Detached is used
#
# Usage:
# dComposeUp
# dComposeUp -Path "."
# dComposeUp -Detached
# dComposeUp -Path "C:\my-project" -Detached
function dComposeUp {
    param(
        [string]$Path = ".",
        [switch]$Detached
    )

    $composeFile = Join-Path $Path "docker-compose.yml"

    if (-not (Test-Path $composeFile)) {
        Write-Host "❌ docker-compose.yml not found in '$Path'." -ForegroundColor Red
        return
    }

    Write-Host "🚀 Starting Docker Compose services..." -ForegroundColor Cyan

    $cmd = "docker compose -f `"$composeFile`" up"

    if ($Detached) {
        $cmd += " -d"
    }

    Invoke-Expression $cmd
}


# Description:
# Stops and removes Docker Compose services, networks, and containers
#
# Usage:
# dComposeDown
# dComposeDown -Path "."
# dComposeDown -Path "C:\my-project"
function dComposeDown {
    param(
        [string]$Path = "."
    )

    $composeFile = Join-Path $Path "docker-compose.yml"

    if (-not (Test-Path $composeFile)) {
        Write-Host "❌ docker-compose.yml not found in '$Path'." -ForegroundColor Red
        return
    }

    Write-Host "🛑 Stopping Docker Compose services..." -ForegroundColor Yellow

    docker compose -f $composeFile down
}


# Description:
# Builds Docker Compose services defined in a docker-compose.yml file
# Compiles images without starting containers
#
# Usage:
# dComposeBuild
# dComposeBuild -Path "."
# dComposeBuild -Path "C:\project"
function dComposeBuild {
    param(
        [string]$Path = "."
    )

    $composeFile = Join-Path $Path "docker-compose.yml"

    if (-not (Test-Path $composeFile)) {
        Write-Host "❌ docker-compose.yml not found in '$Path'." -ForegroundColor Red
        return
    }

    Write-Host "🔨 Building Docker Compose services..." -ForegroundColor Cyan

    docker compose -f $composeFile build
}


# Description:
# Displays logs for Docker Compose services
# Can target a specific service and/or follow logs in real-time
#
# Usage:
# dComposeLogs
# dComposeLogs -Path "."
# dComposeLogs -Service "api"
# dComposeLogs -Follow
function dComposeLogs {
    param(
        [string]$Path = ".",
        [string]$Service = "",
        [switch]$Follow
    )

    $composeFile = Join-Path $Path "docker-compose.yml"

    if (-not (Test-Path $composeFile)) {
        Write-Host "❌ docker-compose.yml not found in '$Path'." -ForegroundColor Red
        return
    }

    Write-Host "📝 Showing Docker Compose logs..." -ForegroundColor Cyan

    $cmd = "docker compose -f `"$composeFile`" logs"

    if ($Follow) {
        $cmd += " -f"
    }

    if (-not [string]::IsNullOrWhiteSpace($Service)) {
        $cmd += " $Service"
    }

    Invoke-Expression $cmd
}


# Description:
# Executes a command inside a Docker Compose service container
# Defaults to interactive bash shell if no command is provided
#
# Usage:
# dComposeExec
# dComposeExec -Service "api"
# dComposeExec -Service "api" -Command "sh"
function dComposeExec {
    param(
        [string]$Path = ".",
        [string]$Service,
        [string]$Command = "bash"
    )

    $composeFile = Join-Path $Path "docker-compose.yml"

    if (-not (Test-Path $composeFile)) {
        Write-Host "❌ docker-compose.yml not found in '$Path'." -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrWhiteSpace($Service)) {
        Write-Host "📦 Available services:" -ForegroundColor Cyan
        docker compose -f $composeFile ps --services
        Write-Host ""

        $Service = Read-Host "Enter the service name to exec"
    }

    if ([string]::IsNullOrWhiteSpace($Service)) {
        Write-Host "❌ No service provided." -ForegroundColor Red
        return
    }

    Write-Host "💻 Executing '$Command' in service '$Service'..." -ForegroundColor Cyan

    docker compose -f $composeFile exec $Service $Command
}


# Description:
# Restarts all Docker Compose services
# Useful after configuration or environment changes
#
# Usage:
# dComposeRestart
# dComposeRestart -Path "."
function dComposeRestart {
    param(
        [string]$Path = "."
    )

    $composeFile = Join-Path $Path "docker-compose.yml"

    if (-not (Test-Path $composeFile)) {
        Write-Host "❌ docker-compose.yml not found in '$Path'." -ForegroundColor Red
        return
    }

    Write-Host "🔄 Restarting Docker Compose services..." -ForegroundColor Yellow

    docker compose -f $composeFile restart
}
