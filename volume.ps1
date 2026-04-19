# Description:
# Lists all Docker volumes on the system
#
# Usage:
# dVolumes
function dVolumes {
    docker volume ls
}


# Description:
# Creates a new Docker volume
# Used for persistent storage in containers
#
# Usage:
# dCreateVolume
# dCreateVolume -VolumeName "my-volume"
function dCreateVolume {
    param(
        [string]$VolumeName
    )

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        $VolumeName = Read-Host "Enter the name for the new Docker volume"
    }

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "❌ No volume name provided." -ForegroundColor Red
        return
    }

    Write-Host "📦 Creating volume '$VolumeName'..." -ForegroundColor Cyan

    docker volume create $VolumeName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Volume '$VolumeName' created successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create volume '$VolumeName'." -ForegroundColor Red
    }
}


# Description:
# Displays detailed information about a Docker volume
#
# Usage:
# dInspectVolume
# dInspectVolume -VolumeName "my-volume"
function dInspectVolume {
    param(
        [string]$VolumeName
    )

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "📦 Available volumes:" -ForegroundColor Cyan
        docker volume ls
        Write-Host ""

        $VolumeName = Read-Host "Enter the name of the volume to inspect"
    }

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "❌ No volume name provided." -ForegroundColor Red
        return
    }

    Write-Host "🔍 Inspecting volume '$VolumeName'..." -ForegroundColor Cyan

    docker volume inspect $VolumeName
}


# Description:
# Removes a Docker volume
# Use -Force to force removal even if in use
#
# Usage:
# dRemoveVolume
# dRemoveVolume -VolumeName "my-volume"
# dRemoveVolume -VolumeName "my-volume" -Force
function dRemoveVolume {
    param(
        [string]$VolumeName,
        [switch]$Force
    )

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "📦 Available volumes:" -ForegroundColor Cyan
        docker volume ls
        Write-Host ""

        $VolumeName = Read-Host "Enter the name of the volume to remove"
    }

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "❌ No volume name provided." -ForegroundColor Red
        return
    }

    Write-Host "🗑️ Removing volume '$VolumeName'..." -ForegroundColor Yellow

    if ($Force) {
        docker volume rm -f $VolumeName
    } else {
        docker volume rm $VolumeName
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Volume removed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to remove volume '$VolumeName'." -ForegroundColor Red
    }
}


# Description:
# Removes all unused Docker volumes from the system
# Prompts for confirmation before executing destructive operation
#
# Usage:
# dPruneVolume
function dPruneVolume {
    Write-Host "⚠️ This will remove all unused Docker volumes. Proceed? (Y/N)" -ForegroundColor Yellow
    $confirm = Read-Host

    if ($confirm -match "^[Yy]$") {
        Write-Host "🧹 Removing unused Docker volumes..." -ForegroundColor Cyan

        docker volume prune -f

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Unused Docker volumes removed successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to prune Docker volumes." -ForegroundColor Red
        }
    }
    else {
        Write-Host "❌ Operation cancelled." -ForegroundColor Red
    }
}


# Description:
# Displays a reference documentation for all Docker volume helper commands
# Acts as an in-terminal cheat sheet for the volume management toolkit
#
# Usage:
# dVolumeDocs
function dVolumeDocs {
    $colCommandWidth = 45
    $colDescWidth    = 75

    $commands = @(
        @{Command="dVolumes"; Description="List all Docker volumes"},
        @{Command="dCreateVolume [name]"; Description="Create a new Docker volume"},
        @{Command="dInspectVolume [name]"; Description="Inspect a Docker volume and show detailed information"},
        @{Command="dRemoveVolume [name] [-Force]"; Description="Remove a Docker volume (use -Force to force removal)"},
        @{Command="dPruneVolume"; Description="Remove all unused Docker volumes"}
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