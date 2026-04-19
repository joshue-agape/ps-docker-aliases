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


# Description:
# Executes a command inside a running Docker container
# Defaults to opening an interactive bash shell
# Lists running containers if no container is provided
# Validates that the container is currently running before execution
#
# Usage:
# dExecContainer
# dExecContainer "my-container"
# dExecContainer -ContainerName "my-container" -Command "bash"
# dExecContainer -ContainerName "my-container" -Command "sh"
# dExecContainer -ContainerName "my-container" -Command "ls"
function dExecContainer {
    param(
        [string]$ContainerName,
        [string]$Command = "bash"
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Running containers:" -ForegroundColor Cyan
        docker ps --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to execute a command"
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
        Write-Host "❌ Container '$ContainerName' is not running." -ForegroundColor Red
        return
    }

    Write-Host "💻 Executing command in container '$ContainerName': $Command" -ForegroundColor Cyan

    # Execute command
    docker exec -it $ContainerName $Command
}


# Description:
# Attaches the current terminal to a running Docker container
# Allows viewing real-time container output (stdout/stderr)
# Lists running containers if no container is provided
# Validates that the container is currently running before attaching
#
# Usage:
# dAttachContainer
# dAttachContainer "my-container"
function dAttachContainer {
    param(
        [string]$ContainerName
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Running containers:" -ForegroundColor Cyan
        docker ps --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to attach"
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
        Write-Host "❌ Container '$ContainerName' is not running." -ForegroundColor Red
        return
    }

    Write-Host "🔗 Attaching to container '$ContainerName'..." -ForegroundColor Cyan

    # Attach to container
    docker attach $ContainerName
}


# Description:
# Displays running processes inside a Docker container
# Uses 'docker top' to show process information
# Lists containers if no name or ID is provided
# Validates that the container exists before executing
#
# Usage:
# dTopContainer
# dTopContainer -ContainerName "my-container"
function dTopContainer {
    param(
        [string]$ContainerName
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Running containers:" -ForegroundColor Cyan
        docker ps --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to view processes"
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

    Write-Host "📊 Processes for container '$ContainerName':" -ForegroundColor Cyan

    # Show processes
    docker top $ContainerName
}


# Description:
# Displays live resource usage statistics for all Docker containers
# Equivalent to 'docker stats' (CPU, memory, network, IO)
# Runs continuously until manually stopped (Ctrl + C)
#
# Usage:
# dStatsContainer
function dStatsContainer {
    Write-Host "📊 Docker container stats (Press Ctrl + C to exit)..." -ForegroundColor Cyan
    docker stats
}


# Description:
# Waits until a Docker container stops running
# Blocks execution until the container exits
# Useful for monitoring batch jobs or one-shot containers
# Lists all containers if no name or ID is provided
#
# Usage:
# dWaitContainer
# dWaitContainer -ContainerName "my-container"
function dWaitContainer {
    param(
        [string]$ContainerName
    )

    # Prompt if no container provided
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Running containers:" -ForegroundColor Cyan
        docker ps --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to wait for"
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

    Write-Host "⏳ Waiting for container '$ContainerName' to stop..." -ForegroundColor Yellow

    # Wait for container to stop
    docker wait $ContainerName | Out-Null

    Write-Host "✅ Container '$ContainerName' has stopped." -ForegroundColor Green
}


# Description:
# Renames an existing Docker container
# Lists all containers if no name is provided
# Validates that the container exists before renaming
#
# Usage:
# dRenameContainer
# dRenameContainer -ContainerName "old-name" -NewName "new-name"
function dRenameContainer {
    param(
        [string]$ContainerName,
        [string]$NewName
    )

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers:" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""
        $ContainerName = Read-Host "Enter the container name or ID to rename"
    }

    if ([string]::IsNullOrWhiteSpace($NewName)) {
        $NewName = Read-Host "Enter the new container name"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName) -or [string]::IsNullOrWhiteSpace($NewName)) {
        Write-Host "❌ Missing container name or new name." -ForegroundColor Red
        return
    }

    $allContainers = docker ps -a --format "{{.Names}}"

    if (-not ($allContainers -contains $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "✏️ Renaming '$ContainerName' → '$NewName'..." -ForegroundColor Cyan

    docker rename $ContainerName $NewName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container renamed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to rename container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Updates a Docker container configuration (CPU, memory, restart policy, etc.)
# Uses 'docker update' command
# Lists containers if none provided
#
# Usage:
# dUpdateContainer
# dUpdateContainer -ContainerName "my-container" -Options "--memory 512m"
function dUpdateContainer {
    param(
        [string]$ContainerName,
        [string]$Options
    )

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers:" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""
        $ContainerName = Read-Host "Enter the container name or ID to update"
    }

    if ([string]::IsNullOrWhiteSpace($Options)) {
        $Options = Read-Host "Enter update options (e.g. --memory 512m)"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName) -or [string]::IsNullOrWhiteSpace($Options)) {
        Write-Host "❌ Missing container name or options." -ForegroundColor Red
        return
    }

    $allContainers = docker ps -a --format "{{.Names}}"

    if (-not ($allContainers -contains $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "⚙️ Updating container '$ContainerName'..." -ForegroundColor Cyan

    docker update $Options $ContainerName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to update container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Pauses a running Docker container (freezes all processes)
# Container remains in memory but execution is suspended
# Lists running containers if none provided
#
# Usage:
# dPauseContainer
# dPauseContainer -ContainerName "my-container"
function dPauseContainer {
    param(
        [string]$ContainerName
    )

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Running containers:" -ForegroundColor Cyan
        docker ps --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""
        $ContainerName = Read-Host "Enter the container name or ID to pause"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    $runningContainers = docker ps --format "{{.Names}}"

    if (-not ($runningContainers -contains $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' is not running." -ForegroundColor Red
        return
    }

    Write-Host "⏸️ Pausing container '$ContainerName'..." -ForegroundColor Cyan

    docker pause $ContainerName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container paused successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to pause container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Resumes a paused Docker container
# Lists paused containers if no name is provided
#
# Usage:
# dUnpauseContainer
# dUnpauseContainer "my-container"
function dUnpauseContainer {
    param(
        [string]$ContainerName
    )

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Paused containers:" -ForegroundColor Cyan

        $paused = docker ps --filter "status=paused" --format "table {{.Names}}\t{{.Status}}"

        if ($paused) {
            Write-Host $paused
        } else {
            Write-Host "❌ No paused containers found." -ForegroundColor Yellow
        }

        Write-Host ""
        $ContainerName = Read-Host "Enter the container name or ID to unpause"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    Write-Host "▶️ Resuming container '$ContainerName'..." -ForegroundColor Cyan

    docker unpause $ContainerName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container '$ContainerName' resumed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to unpause container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Exports a Docker container filesystem into a .tar archive
# Does NOT include image metadata (use docker commit for images)
#
# Usage:
# dExportContainer
# dExportContainer "my-container"
# dExportContainer -ContainerName "my-container" -OutputFile "backup.tar"
function dExportContainer {
    param(
        [string]$ContainerName,
        [string]$OutputFile
    )

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers:" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to export"
    }

    if ([string]::IsNullOrWhiteSpace($OutputFile)) {
        $OutputFile = "$ContainerName.tar"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    Write-Host "📤 Exporting container '$ContainerName'..." -ForegroundColor Cyan

    docker export $ContainerName -o $OutputFile

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container exported to '$OutputFile' successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to export container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Creates a new Docker image from a container state
# Equivalent to saving container changes as a new image
#
# Usage:
# dCommitContainer
# dCommitContainer -ContainerName "my-container" -ImageName "myapp:latest"
function dCommitContainer {
    param(
        [string]$ContainerName,
        [string]$ImageName
    )

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers:" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to commit"
    }

    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        $ImageName = Read-Host "Enter the new image name (e.g. myapp:latest)"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName) -or [string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ Missing container name or image name." -ForegroundColor Red
        return
    }

    Write-Host "📸 Committing container '$ContainerName' → '$ImageName'..." -ForegroundColor Cyan

    docker commit $ContainerName $ImageName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container committed successfully as '$ImageName'!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to commit container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Shows changes made to a container’s filesystem since it was created
# Equivalent to 'docker diff'
# Lists containers if no name is provided
#
# Usage:
# dDiffContainer
# dDiffContainer "my-container"
function dDiffContainer {
    param(
        [string]$ContainerName
    )

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Available containers:" -ForegroundColor Cyan
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""

        $ContainerName = Read-Host "Enter the container name or ID to diff"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    Write-Host "📊 Showing filesystem changes for '$ContainerName'..." -ForegroundColor Cyan

    docker diff $ContainerName
}


# Description:
# Copies files or folders between host and Docker container
# Supports both directions (host ↔ container)
#
# Usage:
# dCpContainer
# dCpContainer -Source "file.txt" -Destination "container:/app/file.txt"
# dCpContainer -Source "container:/app/file.txt" -Destination "./file.txt"
function dCpContainer {
    param(
        [string]$Source,
        [string]$Destination
    )

    if ([string]::IsNullOrWhiteSpace($Source)) {
        $Source = Read-Host "Enter source path (host or container)"
    }

    if ([string]::IsNullOrWhiteSpace($Destination)) {
        $Destination = Read-Host "Enter destination path (host or container)"
    }

    if ([string]::IsNullOrWhiteSpace($Source) -or [string]::IsNullOrWhiteSpace($Destination)) {
        Write-Host "❌ Missing source or destination path." -ForegroundColor Red
        return
    }

    Write-Host "📁 Copying:" -ForegroundColor Cyan
    Write-Host "$Source → $Destination"

    docker cp $Source $Destination

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Copy completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Copy operation failed." -ForegroundColor Red
    }
}


# Description:
# Displays a complete reference documentation for all Docker container helper commands
# Provides a formatted table with command usage and descriptions
# Acts as an in-terminal cheat sheet for the Docker PowerShell toolkit
#
# Usage:
# dContainerDocs
function dContainerDocs {
    $colCommandWidth = 45
    $colDescWidth    = 75

    $commands = @(
        @{Command="dContainers [-all]"; Description="List Docker containers (running by default, all with -all)"},
        @{Command="dRunContainer <image> [name] [-Detach] [-Ports] [-Volumes]"; Description="Run a container from a local image with optional configuration"},
        @{Command="dCreateContainer <image> [name]"; Description="Create a container without starting it"},
        @{Command="dStartContainer [name]"; Description="Start a container"},
        @{Command="dStopContainer [name]"; Description="Stop a running container"},
        @{Command="dRestartContainer [name]"; Description="Restart a container"},
        @{Command="dKillContainer [name]"; Description="Force stop (kill) a container"},
        @{Command="dRemoveContainer [name] [-Force]"; Description="Remove a container"},
        @{Command="dLogsContainer [name] [-Follow]"; Description="Show container logs (use -Follow to stream)"},
        @{Command="dExecContainer [name] [command]"; Description="Execute a command inside a running container"},
        @{Command="dAttachContainer [name]"; Description="Attach to a container terminal"},
        @{Command="dTopContainer [name]"; Description="Show running processes inside a container"},
        @{Command="dStatsContainer"; Description="Show real-time resource usage stats for all containers"},
        @{Command="dWaitContainer [name]"; Description="Wait until a container stops"},
        @{Command="dRenameContainer [name] [newName]"; Description="Rename a container"},
        @{Command="dUpdateContainer [name] [options]"; Description="Update container resources (CPU, memory, etc.)"},
        @{Command="dPauseContainer [name]"; Description="Pause a running container"},
        @{Command="dUnpauseContainer [name]"; Description="Resume a paused container"},
        @{Command="dExportContainer [name] [file]"; Description="Export container filesystem to a tar file"},
        @{Command="dCommitContainer [name] [image]"; Description="Create a new image from a container"},
        @{Command="dDiffContainer [name]"; Description="Show filesystem changes inside a container"},
        @{Command="dCpContainer <source> <destination>"; Description="Copy files between host and container"}
    )

    $headerCommand = "COMMAND".PadRight($colCommandWidth)
    $headerDesc    = "DESCRIPTION".PadRight($colDescWidth)

    Write-Host $headerCommand$headerDesc -ForegroundColor Cyan
    Write-Host ("-" * ($colCommandWidth + $colDescWidth))

    foreach ($cmd in $commands) {
        $cmdName = $cmd.Command.PadRight($colCommandWidth)
        $cmdDesc = $cmd.Description.PadRight($colDescWidth)
        Write-Host "$cmdName$cmdDesc"
    }
}
