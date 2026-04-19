. "$HOME\.config\alias\docker-commandes\docs.ps1"
. "$HOME\.config\alias\docker-commandes\image.ps1"
. "$HOME\.config\alias\docker-commandes\container.ps1"
. "$HOME\.config\alias\docker-commandes\compose.ps1"
. "$HOME\.config\alias\docker-commandes\volume.ps1"


# Description:
# Displays the installed Docker version.

# Usage:
# dVersion
function dVersion {
    docker --version
}


# Description:
# Displays detailed Docker information (containers, images, volumes, etc.)

# Usage:
# dInfo
function dInfo {
    docker info
}


# Description:
# Displays Docker disk usage (images, containers, volumes)

# Usage:
# dDiskSystem
function dDiskSystem {
    Write-Host "📊 Docker disk usage:" -ForegroundColor Cyan
    docker system df
}


# Description:
# Cleans up Docker system by removing unused resources
# (stopped containers, unused images, volumes, and networks)
# Prompts for confirmation before execution

# Usage:
# dPruneSystem
function dPruneSystem {
    Write-Host "⚠️ This will remove unused containers, images, volumes, and networks." -ForegroundColor Yellow
    Write-Host "Do you want to continue? (Y/N)" -ForegroundColor Yellow

    $confirm = Read-Host

    if ($confirm -match "^[Yy]$") {
        Write-Host "🧹 Cleaning Docker system..." -ForegroundColor Cyan
        docker system prune -a -f
        Write-Host "✅ Docker system cleaned successfully." -ForegroundColor Green
    } else {
        Write-Host "❌ Operation cancelled." -ForegroundColor Red
    }
}


# Description:
# Logs in to a Docker registry (Docker Hub by default)
# Includes basic validation and user feedback

# Usage:
# dLogin
# dLogin
# dLogin "ghcr.io"
# dLogin -Registry "ghcr.io"
function dLogin {
    param(
        [string]$Registry = "docker.io"
    )

    if ([string]::IsNullOrWhiteSpace($Registry)) {
        $Registry = Read-Host "Enter the Docker registry (default: docker.io)"
        if ([string]::IsNullOrWhiteSpace($Registry)) {
            $Registry = "docker.io"
        }
    }

    Write-Host "🔑 Logging in to registry '$Registry'..." -ForegroundColor Cyan

    docker login $Registry

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Logged in successfully to '$Registry'." -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to log in to '$Registry'." -ForegroundColor Red
    }
}


# Description:
# Logs out from a Docker registry (Docker Hub by default)
# Includes basic validation and user feedback

# Usage:
# dLogout
# dLogout
# dLogout "ghcr.io"
# dLogout -Registry "ghcr.io"
function dLogout {
    param(
        [string]$Registry = "docker.io"
    )

    if ([string]::IsNullOrWhiteSpace($Registry)) {
        $Registry = Read-Host "Enter the Docker registry to log out from (default: docker.io)"
        if ([string]::IsNullOrWhiteSpace($Registry)) {
            $Registry = "docker.io"
        }
    }

    Write-Host "🔓 Logging out from registry '$Registry'..." -ForegroundColor Cyan

    docker logout $Registry

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Logged out successfully from '$Registry'." -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to log out from '$Registry'." -ForegroundColor Red
    }
}
