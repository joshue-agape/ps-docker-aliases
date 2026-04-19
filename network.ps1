# Description:
# Lists all Docker networks available on the system
#
# Usage:
# dNetworks
function dNetworks {
    docker network ls
}


# Description:
# Creates a new Docker network
# Used to connect containers within an isolated network
#
# Usage:
# dCreateNetwork
# dCreateNetwork -NetworkName "my-network"
function dCreateNetwork {
    param(
        [string]$NetworkName
    )

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        $NetworkName = Read-Host "Enter the name for the new Docker network"
    }

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "❌ No network name provided." -ForegroundColor Red
        return
    }

    Write-Host "🌐 Creating network '$NetworkName'..." -ForegroundColor Cyan

    docker network create $NetworkName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Network '$NetworkName' created successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create network '$NetworkName'." -ForegroundColor Red
    }
}


# Description:
# Displays detailed information about a Docker network
#
# Usage:
# dInspectNetwork
# dInspectNetwork -NetworkName "my-network"
function dInspectNetwork {
    param(
        [string]$NetworkName
    )

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "📦 Available networks:" -ForegroundColor Cyan
        docker network ls
        Write-Host ""

        $NetworkName = Read-Host "Enter the name of the network to inspect"
    }

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "❌ No network name provided." -ForegroundColor Red
        return
    }

    Write-Host "🔍 Inspecting network '$NetworkName'..." -ForegroundColor Cyan

    docker network inspect $NetworkName
}


# Description:
# Connects a Docker container to a specific network
#
# Usage:
# dConnectNetwork
# dConnectNetwork -NetworkName "my-net" -ContainerName "api"
function dConnectNetwork {
    param(
        [string]$NetworkName,
        [string]$ContainerName
    )

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "📦 Available networks:" -ForegroundColor Cyan
        docker network ls
        Write-Host ""
        $NetworkName = Read-Host "Enter the network name to connect"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Running containers:" -ForegroundColor Cyan
        docker ps --format "{{.Names}}"
        Write-Host ""
        $ContainerName = Read-Host "Enter the container name or ID to connect"
    }

    if ([string]::IsNullOrWhiteSpace($NetworkName) -or [string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ Network or container name is missing." -ForegroundColor Red
        return
    }

    Write-Host "🔗 Connecting '$ContainerName' to network '$NetworkName'..." -ForegroundColor Cyan

    docker network connect $NetworkName $ContainerName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container '$ContainerName' connected to '$NetworkName'." -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to connect container '$ContainerName' to '$NetworkName'." -ForegroundColor Red
    }
}


# Description:
# Disconnects a Docker container from a network
#
# Usage:
# dDisconnectNetwork
# dDisconnectNetwork -NetworkName "my-net" -ContainerName "api"
function dDisconnectNetwork {
    param(
        [string]$NetworkName,
        [string]$ContainerName
    )

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "📦 Available networks:" -ForegroundColor Cyan
        docker network ls
        Write-Host ""
        $NetworkName = Read-Host "Enter the network name to disconnect"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Connected containers:" -ForegroundColor Cyan
        docker network inspect $NetworkName --format '{{range .Containers}}{{.Name}} {{end}}'
        Write-Host ""
        $ContainerName = Read-Host "Enter the container name or ID to disconnect"
    }

    if ([string]::IsNullOrWhiteSpace($NetworkName) -or [string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ Network or container name is missing." -ForegroundColor Red
        return
    }

    Write-Host "🔌 Disconnecting '$ContainerName' from '$NetworkName'..." -ForegroundColor Yellow

    docker network disconnect $NetworkName $ContainerName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container '$ContainerName' disconnected from '$NetworkName'." -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to disconnect container '$ContainerName'." -ForegroundColor Red
    }
}


# Description:
# Removes a Docker network
#
# Usage:
# dRemoveNetwork
# dRemoveNetwork -NetworkName "my-net"
function dRemoveNetwork {
    param(
        [string]$NetworkName
    )

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "📦 Available networks:" -ForegroundColor Cyan
        docker network ls
        Write-Host ""
        $NetworkName = Read-Host "Enter the network name to remove"
    }

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "❌ No network name provided." -ForegroundColor Red
        return
    }

    Write-Host "🗑️ Removing network '$NetworkName'..." -ForegroundColor Yellow

    docker network rm $NetworkName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Network '$NetworkName' removed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to remove network '$NetworkName'." -ForegroundColor Red
    }
}


# Description:
# Removes all unused Docker networks
# WARNING: this will clean dangling networks
#
# Usage:
# dPruneNetwork
function dPruneNetwork {
    Write-Host "⚠️ This will remove all unused Docker networks. Proceed? (Y/N)" -ForegroundColor Yellow
    $confirm = Read-Host

    if ($confirm -match "^[Yy]$") {
        Write-Host "🧹 Pruning unused Docker networks..." -ForegroundColor Cyan

        docker network prune -f

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Unused Docker networks removed successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to prune Docker networks." -ForegroundColor Red
        }
    }
    else {
        Write-Host "❌ Operation cancelled." -ForegroundColor Red
    }
}


# Description:
# Displays a reference documentation for all Docker network helper commands
# Acts as an in-terminal cheat sheet for the networking toolkit section
#
# Usage:
# dNetworkDocs
function dNetworkDocs {
    $colCommandWidth = 45
    $colDescWidth    = 75

    $commands = @(
        @{Command="dNetworks"; Description="List all Docker networks"},
        @{Command="dCreateNetwork [name]"; Description="Create a new Docker network"},
        @{Command="dInspectNetwork [name]"; Description="Inspect a Docker network and show details"},
        @{Command="dConnectNetwork [network] [container]"; Description="Connect a container to a network"},
        @{Command="dDisconnectNetwork [network] [container]"; Description="Disconnect a container from a network"},
        @{Command="dRemoveNetwork [name]"; Description="Remove a Docker network"},
        @{Command="dPruneNetwork"; Description="Remove all unused Docker networks"}
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
