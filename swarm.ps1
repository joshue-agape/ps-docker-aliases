# Description:
# Initializes a Docker Swarm cluster on the current machine
# This node becomes the Swarm manager
#
# Usage:
# dInitSwarm
function dInitSwarm {
    Write-Host "🚀 Initializing Docker Swarm cluster..." -ForegroundColor Cyan

    docker swarm init

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker Swarm initialized successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to initialize Docker Swarm." -ForegroundColor Red
    }
}


# Description:
# Joins an existing Docker Swarm cluster as a worker or manager node
#
# Usage:
# dJoinSwarm
# dJoinSwarm -JoinToken "<token>" -ManagerIP "192.168.1.10:2377"
function dJoinSwarm {
    param(
        [string]$JoinToken,
        [string]$ManagerIP
    )

    if ([string]::IsNullOrWhiteSpace($JoinToken)) {
        $JoinToken = Read-Host "Enter the join token for the Swarm cluster"
    }

    if ([string]::IsNullOrWhiteSpace($ManagerIP)) {
        $ManagerIP = Read-Host "Enter the manager IP:Port (e.g., 192.168.1.10:2377)"
    }

    if ([string]::IsNullOrWhiteSpace($JoinToken) -or [string]::IsNullOrWhiteSpace($ManagerIP)) {
        Write-Host "❌ Missing join token or manager address." -ForegroundColor Red
        return
    }

    Write-Host "🌐 Joining Docker Swarm cluster..." -ForegroundColor Cyan

    docker swarm join --token $JoinToken $ManagerIP

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully joined Docker Swarm cluster!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to join Docker Swarm cluster." -ForegroundColor Red
    }
}


# Description:
# Lists all nodes in the Docker Swarm cluster
#
# Usage:
# dNodes
function dNodes {
    Write-Host "📦 Listing Docker Swarm nodes..." -ForegroundColor Cyan

    docker node ls
}


# Description:
# Lists all Docker Swarm services running in the cluster
#
# Usage:
# dServices
function dServices {
    docker service ls
}


# Description:
# Creates a new Docker Swarm service
# Default image is nginx if not specified
#
# Usage:
# dCreateService
# dCreateService "web"
# dCreateService -ServiceName "web" -Image "nginx:latest"
function dCreateService {
    param(
        [string]$ServiceName,
        [string]$Image = "nginx"
    )

    if ([string]::IsNullOrWhiteSpace($ServiceName)) {
        $ServiceName = Read-Host "Enter the service name"
    }

    if ([string]::IsNullOrWhiteSpace($ServiceName)) {
        Write-Host "❌ Service name is required." -ForegroundColor Red
        return
    }

    Write-Host "🚀 Creating Swarm service '$ServiceName' using image '$Image'..." -ForegroundColor Cyan

    docker service create --name $ServiceName $Image

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Service '$ServiceName' created successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create service '$ServiceName'." -ForegroundColor Red
    }
}


# Description:
# Removes a Docker Swarm service from the cluster
#
# Usage:
# dRemoveService
# dRemoveService -ServiceName "web"
function dRemoveService {
    param(
        [string]$ServiceName
    )

    if ([string]::IsNullOrWhiteSpace($ServiceName)) {
        Write-Host "📦 Available services:" -ForegroundColor Cyan
        docker service ls --format "{{.Name}}"
        Write-Host ""

        $ServiceName = Read-Host "Enter the service name to remove"
    }

    if ([string]::IsNullOrWhiteSpace($ServiceName)) {
        Write-Host "❌ Service name is required." -ForegroundColor Red
        return
    }

    Write-Host "🗑️ Removing service '$ServiceName'..." -ForegroundColor Yellow

    docker service rm $ServiceName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Service '$ServiceName' removed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to remove service '$ServiceName'." -ForegroundColor Red
    }
}


# Description:
# Deploys a Docker stack using a docker-compose file in Swarm mode
#
# Usage:
# dStackDeploy
# dStackDeploy "mystack"
# dStackDeploy -StackName "mystack" -ComposeFile "docker-compose.yml"
function dStackDeploy {
    param(
        [string]$StackName,
        [string]$ComposeFile = "docker-compose.yml"
    )

    if ([string]::IsNullOrWhiteSpace($StackName)) {
        $StackName = Read-Host "Enter the stack name"
    }

    if ([string]::IsNullOrWhiteSpace($StackName)) {
        Write-Host "❌ Stack name is required." -ForegroundColor Red
        return
    }

    if (-not (Test-Path $ComposeFile)) {
        Write-Host "❌ Compose file '$ComposeFile' not found." -ForegroundColor Red
        return
    }

    Write-Host "🚀 Deploying stack '$StackName' using '$ComposeFile'..." -ForegroundColor Cyan

    docker stack deploy -c $ComposeFile $StackName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Stack '$StackName' deployed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to deploy stack '$StackName'." -ForegroundColor Red
    }
}


# Description:
# Displays a reference documentation for all Docker Swarm helper commands
# Acts as an in-terminal cheat sheet for Swarm cluster, services, and stack operations
#
# Usage:
# dSwarmDocs
function dSwarmDocs {
    $colCommandWidth = 45
    $colDescWidth    = 75

    $commands = @(
        @{Command="dInitSwarm"; Description="Initialize a Docker Swarm cluster"},
        @{Command="dJoinSwarm [token] [managerIP]"; Description="Join a Docker Swarm cluster using a token and manager IP"},
        @{Command="dNodes"; Description="List all nodes in the Docker Swarm cluster"},
        @{Command="dServices"; Description="List all Docker Swarm services"},
        @{Command="dCreateService [name] [image]"; Description="Create a new Docker Swarm service (default image: nginx)"},
        @{Command="dRemoveService [name]"; Description="Remove a Docker Swarm service"},
        @{Command="dStackDeploy [stackName] [composeFile]"; Description="Deploy a Docker stack using a compose file (default: docker-compose.yml)"}
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