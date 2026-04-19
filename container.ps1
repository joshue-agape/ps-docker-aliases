# Description:
# Lists Docker containers
# By default, shows only running containers
# Use -All to display all containers (running and stopped)
#
# Usage:
# dContainers
# dContainers -All
function dContainers {
    param(
        [switch]$All
    )

    Write-Host "📦 Docker containers:" -ForegroundColor Cyan

    if ($All) {
        $containers = docker ps -a
    } else {
        $containers = docker ps
    }

    if ($containers) {
        Write-Host $containers
    } else {
        Write-Host "❌ No containers found." -ForegroundColor Yellow
    }
}


# Description:
# Runs a Docker container from a specified image
# Supports detached mode, custom container name, port mappings, volumes, and extra arguments
# Validates that the image exists locally before running
#
# Usage:
# dRunContainer
# dRunContainer "nginx:latest"
# dRunContainer -ImageName "nginx" -Detach
# dRunContainer -ImageName "nginx" -ContainerName "web-server"
# dRunContainer -ImageName "nginx" -Ports "8080:80"
# dRunContainer -ImageName "nginx" -Ports "8080:80","443:443"
# dRunContainer -ImageName "nginx" -Volumes "/host/path:/container/path"
# dRunContainer -ImageName "nginx" -Detach -Ports "8080:80" -ContainerName "web"
# dRunContainer -ImageName "nginx" -ExtraArgs "--restart always"
function dRunContainer {
    param(
        [string]$ImageName,
        [string]$ContainerName,
        [switch]$Detach,
        [string[]]$Ports,
        [string[]]$Volumes,
        [string]$ExtraArgs
    )

    # Prompt for image if not provided
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        docker images
        $ImageName = Read-Host "Enter the image name to run (e.g. nginx:latest)"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    # Add default tag if missing
    if ($ImageName -notmatch ":") {
        $ImageName += ":latest"
    }

    # Validate image existence
    $localImages = docker images --format "{{.Repository}}:{{.Tag}}"
    if (-not ($localImages -contains $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    # Build argument list (SAFE way)
    $args = @("run")

    if ($Detach) { $args += "-d" }
    if ($ContainerName) { $args += "--name"; $args += $ContainerName }

    if ($Ports) {
        foreach ($p in $Ports) {
            $args += "-p"
            $args += $p
        }
    }

    if ($Volumes) {
        foreach ($v in $Volumes) {
            $args += "-v"
            $args += $v
        }
    }

    if ($ExtraArgs) {
        $args += $ExtraArgs.Split(" ")
    }

    $args += $ImageName

    # Display command preview
    Write-Host "🚀 Running container:" -ForegroundColor Cyan
    Write-Host ("docker " + ($args -join " ")) -ForegroundColor Yellow

    # Execute safely
    docker @args

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container from '$ImageName' started successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to start container from '$ImageName'." -ForegroundColor Red
    }
}


# Description:
# Creates a Docker container from a specified image without starting it
# Supports container naming, port mapping, volume mounting, and extra arguments
# Validates that the image exists locally before creation
#
# Usage:
# dCreateContainer
# dCreateContainer "nginx:latest"
# dCreateContainer -ImageName "nginx" -ContainerName "web"
# dCreateContainer -ImageName "nginx" -Ports "8080:80"
# dCreateContainer -ImageName "nginx" -Volumes "/host:/container"
# dCreateContainer -ImageName "nginx" -ContainerName "app" -Ports "8080:80" -Volumes "/data:/app"
function dCreateContainer {
    param(
        [string]$ImageName,
        [string]$ContainerName,
        [string[]]$Ports,
        [string[]]$Volumes,
        [string]$ExtraArgs
    )

    # Prompt for image if not provided
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        docker images
        $ImageName = Read-Host "Enter the image name to create (e.g. nginx:latest)"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    # Add default tag if missing
    if ($ImageName -notmatch ":") {
        $ImageName += ":latest"
    }

    # Validate image exists locally
    $localImages = docker images --format "{{.Repository}}:{{.Tag}}"
    if (-not ($localImages -contains $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    # Build command safely
    $args = @("create")

    if ($ContainerName) {
        $args += "--name"
        $args += $ContainerName
    }

    if ($Ports) {
        foreach ($p in $Ports) {
            $args += "-p"
            $args += $p
        }
    }

    if ($Volumes) {
        foreach ($v in $Volumes) {
            $args += "-v"
            $args += $v
        }
    }

    if ($ExtraArgs) {
        $args += $ExtraArgs.Split(" ")
    }

    $args += $ImageName

    # Preview command
    Write-Host "🛠 Creating container:" -ForegroundColor Cyan
    Write-Host ("docker " + ($args -join " ")) -ForegroundColor Yellow

    # Execute safely
    docker @args

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container from '$ImageName' created successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create container from '$ImageName'." -ForegroundColor Red
    }
}


# Description:
# Starts a stopped Docker container
# Lists all containers if no name or ID is provided
# Validates that the container exists before starting
#
# Usage:
# dStartContainer
# dStartContainer "my-container"
# dStartContainer -ContainerName "container_id"
function dStartContainer {
    param(
        [string]$ContainerName
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers (stopped or running):" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to start"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    # Get all container names
    $allContainers = docker ps -a --format "{{.Names}}"

    # Validate container exists
    if (-not ($allContainers -contains $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🚀 Starting container '$ContainerName'..." -ForegroundColor Cyan

    # Start container
    docker start $ContainerName

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container '$ContainerName' started successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to start container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Stops a running Docker container
# Lists currently running containers if no name or ID is provided
# Validates that the container is currently running before stopping it
#
# Usage:
# dStopContainer
# dStopContainer "my-container"
# dStopContainer -ContainerName "container_id"
function dStopContainer {
    param(
        [string]$ContainerName
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Running containers:" -ForegroundColor Cyan
        docker ps --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to stop"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    # Get running containers
    $runningContainers = docker ps --format "{{.Names}}"

    # Validate container is running
    if (-not ($runningContainers -contains $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' is not running or does not exist." -ForegroundColor Red
        return
    }

    Write-Host "🛑 Stopping container '$ContainerName'..." -ForegroundColor Cyan

    # Stop container
    docker stop $ContainerName

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container '$ContainerName' stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to stop container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Restarts a Docker container (stopped or running)
# Lists all containers if no name or ID is provided
# Validates that the container exists before restarting it
#
# Usage:
# dRestartContainer
# dRestartContainer "my-container"
# dRestartContainer -ContainerName "container_id"
function dRestartContainer {
    param(
        [string]$ContainerName
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers (running or stopped):" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to restart"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    # Get all containers
    $allContainers = docker ps -a --format "{{.Names}}"

    # Validate container exists
    if (-not ($allContainers -contains $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🔄 Restarting container '$ContainerName'..." -ForegroundColor Cyan

    # Restart container
    docker restart $ContainerName

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container '$ContainerName' restarted successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to restart container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Forcefully kills a running Docker container (SIGKILL)
# Lists all containers if no name or ID is provided
# Validates that the container exists before killing it
#
# Usage:
# dKillContainer
# dKillContainer "my-container"
# dKillContainer -ContainerName "container_id"
function dKillContainer {
    param(
        [string]$ContainerName
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers (running or stopped):" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to kill"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    # Get all containers
    $allContainers = docker ps -a --format "{{.Names}}"

    # Validate container exists
    if (-not ($allContainers -contains $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "💀 Killing container '$ContainerName'..." -ForegroundColor Cyan

    # Kill container
    docker kill $ContainerName

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container '$ContainerName' killed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to kill container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Removes a Docker container from the system
# Supports forced removal using -Force flag
# Lists all containers if no name or ID is provided
# Validates that the container exists before removing it
#
# Usage:
# dRemoveContainer
# dRemoveContainer "my-container"
# dRemoveContainer -ContainerName "container_id" -Force
function dRemoveContainer {
    param(
        [string]$ContainerName,
        [switch]$Force
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers (stopped or running):" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to remove"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    # Get all containers
    $allContainers = docker ps -a --format "{{.Names}}"

    # Validate container exists
    if (-not ($allContainers -contains $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    # Confirmation if not forced
    if (-not $Force) {
        Write-Host "⚠️ You are about to remove container '$ContainerName'. Continue? (Y/N)" -ForegroundColor Yellow
        $confirm = Read-Host
        if ($confirm -notmatch "^[Yy]$") {
            Write-Host "❌ Operation cancelled." -ForegroundColor Red
            return
        }
    }

    Write-Host "🗑️ Removing container '$ContainerName'..." -ForegroundColor Cyan

    # Remove container
    if ($Force) {
        docker rm -f $ContainerName
    } else {
        docker rm $ContainerName
    }

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container '$ContainerName' removed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to remove container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Displays logs of a Docker container
# Supports real-time log streaming using -Follow
# Lists available containers if no name or ID is provided
# Validates that the container exists before showing logs
#
# Usage:
# dLogsContainer
# dLogsContainer -ContainerName "my-container"
# dLogsContainer -ContainerName "my-container" -Follow
function dLogsContainer {
    param(
        [string]$ContainerName,
        [switch]$Follow
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers:" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to view logs"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    # Get all containers
    $allContainers = docker ps -a --format "{{.Names}}"

    # Validate container exists
    if (-not ($allContainers -contains $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "📝 Displaying logs for container '$ContainerName':" -ForegroundColor Cyan

    # Build argument list safely (NO Invoke-Expression)
    $args = @("logs")

    if ($Follow) {
        $args += "-f"
    }

    $args += $ContainerName

    # Execute safely
    docker @args
}


