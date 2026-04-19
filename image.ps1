# Description:
# Lists all local Docker images available on the system

# Usage:
# dImages
function dImages {
    docker image ls
}


# Description:
# Builds a Docker image from a folder containing a Dockerfile
# Validates folder and Dockerfile existence before building

# Usage:
# dBuildImage
# dBuildImage -AppName "my-app"
# dBuildImage -AppName "my-app" -Tag "latest"
# dBuildImage -AppName "my-app" -Tag "1.0.0"
# dBuildImage -AppName "my-app" -Tag "dev"
function dBuildImage {
    param(
        [string]$AppName,
        [string]$Tag = "latest"
    )

    # Prompt for app name if not provided
    if ([string]::IsNullOrWhiteSpace($AppName)) {
        $AppName = Read-Host "Enter your app folder name"
    }

    # Validate folder existence
    if (-not (Test-Path $AppName -PathType Container)) {
        Write-Host "❌ Folder '$AppName' does not exist." -ForegroundColor Red
        return
    }

    # Check Dockerfile existence
    $dockerfilePath = Join-Path $AppName "Dockerfile"

    if (-not (Test-Path $dockerfilePath)) {
        Write-Host "❌ No Dockerfile found in '$AppName'." -ForegroundColor Red
        return
    }

    # Build image name
    $fullImageName = "$AppName`:$Tag"

    Write-Host "⬆️ Building Docker image '$fullImageName' from folder '$AppName'..." -ForegroundColor Cyan

    # Build Docker image
    docker build -t $fullImageName $AppName

    # Check result
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Image '$fullImageName' built successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to build image '$fullImageName'." -ForegroundColor Red
    }
}


# Description:
# Pulls a Docker image from a registry (Docker Hub by default)
# If no image name is provided, lists available local images and prompts the user
# Automatically adds ":latest" tag if none is specified
#
# Usage:
# dGetImage
# dGetImage -ImageName "nginx"
# dGetImage -ImageName "nginx:latest"
# dGetImage -ImageName "ubuntu"
# dGetImage -ImageName "ubuntu:22.04"
function dGetImage {
    param(
        [string]$ImageName
    )

    # If no image name is provided, show local images and prompt user
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        docker images

        $ImageName = Read-Host "Enter image name (e.g. nginx or nginx:latest)"
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

    Write-Host "⬇️ Pulling image '$ImageName'..." -ForegroundColor Cyan

    # Pull image
    docker pull $ImageName

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Image '$ImageName' downloaded successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to pull image '$ImageName'." -ForegroundColor Red
    }
}


# Description:
# Pushes a Docker image to a registry (Docker Hub or configured registry)
# If no image name is provided, lists local images and prompts the user
# Validates that the image exists locally before pushing
#
# Usage:
# dPushImage
# dPushImage -ImageName "nginx:latest"
# dPushImage -ImageName "username/app:1.0.0"
# dPushImage -ImageName "my-app:dev"
function dPushImage {
    param(
        [string]$ImageName
    )

    # If no image provided, show local images and prompt user
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        docker images

        $ImageName = Read-Host "Enter the image to push (e.g. username/app:tag)"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    # Get local images list
    $localImages = docker images --format "{{.Repository}}:{{.Tag}}"

    # Check if image exists locally
    if (-not ($localImages -contains $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    Write-Host "⬆️ Pushing image '$ImageName' to registry..." -ForegroundColor Cyan

    # Push image
    docker push $ImageName

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Image '$ImageName' pushed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to push image '$ImageName'." -ForegroundColor Red
    }
}


# Description:
# Removes a Docker image from the local system
# Validates that the image exists before removal
# Supports forced removal using the -Force flag
#
# Usage:
# dRemoveImage
# dRemoveImage -ImageName "myapp:latest"
# dRemoveImage -ImageName "nginx:latest"
# dRemoveImage -ImageName "myapp:1.0.0" -Force
function dRemoveImage {
    param(
        [string]$ImageName,
        [switch]$Force
    )

    # If no image name is provided, show local images and prompt user
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        docker images

        $ImageName = Read-Host "Enter the image name to remove (e.g. myapp:latest)"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    # Get local images list
    $localImages = docker images --format "{{.Repository}}:{{.Tag}}"

    # Check if image exists locally
    if (-not ($localImages -contains $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    # Confirm removal if not forced
    if (-not $Force) {
        Write-Host "⚠️ You are about to remove image '$ImageName'. Continue? (Y/N)" -ForegroundColor Yellow
        $confirm = Read-Host
        if ($confirm -notmatch "^[Yy]$") {
            Write-Host "❌ Operation cancelled." -ForegroundColor Red
            return
        }
    }

    Write-Host "🗑️ Removing image '$ImageName'..." -ForegroundColor Cyan

    # Remove image
    if ($Force) {
        docker rmi -f $ImageName
    } else {
        docker rmi $ImageName
    }

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Image '$ImageName' removed successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to remove image '$ImageName'." -ForegroundColor Red
    }
}


# Description:
# Tags a Docker image by creating a new reference (name:tag)
# Validates that the source image exists locally before tagging
# Automatically adds ":latest" if no tag is provided
#
# Usage:
# dTagImage
# dTagImage -SourceImage "myapp:latest" -TargetImage "username/myapp:latest"
# dTagImage -SourceImage "myapp" -TargetImage "username/myapp"
# dTagImage -SourceImage "myapp:1.0.0" -TargetImage "username/myapp:prod"
function dTagImage {
    param(
        [string]$SourceImage,
        [string]$TargetImage
    )

    # Prompt for source image if not provided
    if ([string]::IsNullOrWhiteSpace($SourceImage)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        docker images
        $SourceImage = Read-Host "Enter source image (name:tag)"
    }

    # Prompt for target image if not provided
    if ([string]::IsNullOrWhiteSpace($TargetImage)) {
        Write-Host ""
        $TargetImage = Read-Host "Enter target image (name:tag)"
    }

    # Validate inputs
    if ([string]::IsNullOrWhiteSpace($SourceImage) -or [string]::IsNullOrWhiteSpace($TargetImage)) {
        Write-Host "❌ Source or target image missing." -ForegroundColor Red
        return
    }

    # Add default tag if missing
    if ($SourceImage -notmatch ":") { $SourceImage += ":latest" }
    if ($TargetImage -notmatch ":") { $TargetImage += ":latest" }

    # Get local images list
    $localImages = docker images --format "{{.Repository}}:{{.Tag}}"

    # Validate source image exists
    if (-not ($localImages -contains $SourceImage)) {
        Write-Host "❌ Source image '$SourceImage' not found locally." -ForegroundColor Red
        return
    }

    Write-Host "🏷️ Tagging image..." -ForegroundColor Cyan
    Write-Host "➡️ $SourceImage ➜ $TargetImage" -ForegroundColor Yellow

    # Tag image
    docker tag $SourceImage $TargetImage

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Image tagged successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to tag image '$SourceImage'." -ForegroundColor Red
    }
}


# Description:
# Saves a Docker image to a tar archive file
# Validates that the image exists locally before exporting
# Automatically generates a safe filename if none is provided
#
# Usage:
# dSaveImage
# dSaveImage -ImageName "myapp:latest"
# dSaveImage -ImageName "nginx:latest" -OutputFile "nginx.tar"
# dSaveImage -ImageName "myapp:1.0.0" -OutputFile "backup.tar"
function dSaveImage {
    param(
        [string]$ImageName,
        [string]$OutputFile
    )

    # Prompt for image name if not provided
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        docker images
        Write-Host ""

        $ImageName = Read-Host "Enter the image name to save (e.g. myapp:latest)"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    # Get local images list
    $localImages = docker images --format "{{.Repository}}:{{.Tag}}"

    # Check if image exists locally
    if (-not ($localImages -contains $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    # Generate output filename if not provided
    if ([string]::IsNullOrWhiteSpace($OutputFile)) {
        $safeName = $ImageName -replace "[:/]", "_"
        $OutputFile = "$safeName.tar"
    }

    Write-Host "💾 Saving image '$ImageName' to file '$OutputFile'..." -ForegroundColor Cyan

    # Save image
    docker save $ImageName -o $OutputFile

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Image saved successfully to '$OutputFile'." -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to save image '$ImageName'." -ForegroundColor Red
    }
}


# Description:
# Loads a Docker image from a tar archive file
# Validates that the file exists before importing
# Lists available .tar files in the current directory if no input is provided
#
# Usage:
# dLoadImage
# dLoadImage -InputFile "myapp.tar"
# dLoadImage -InputFile "./backup/nginx.tar"
function dLoadImage {
    param(
        [string]$InputFile
    )

    # Prompt for input file if not provided
    if ([string]::IsNullOrWhiteSpace($InputFile)) {
        Write-Host "📂 Available .tar files in current directory:" -ForegroundColor Cyan
        Get-ChildItem -Filter *.tar
        Write-Host ""

        $InputFile = Read-Host "Enter the path to the .tar file to load"
    }

    # Validate input
    if ([string]::IsNullOrWhiteSpace($InputFile)) {
        Write-Host "❌ No file path provided." -ForegroundColor Red
        return
    }

    # Check file existence
    if (-not (Test-Path $InputFile -PathType Leaf)) {
        Write-Host "❌ File '$InputFile' does not exist." -ForegroundColor Red
        return
    }

    Write-Host "⬇️ Loading Docker image from '$InputFile'..." -ForegroundColor Cyan

    # Load image
    docker load -i $InputFile

    # Result check
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Image loaded successfully from '$InputFile'." -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to load image from '$InputFile'." -ForegroundColor Red
    }
}


# Description:
# Displays the history (layers) of a Docker image
# Validates that the image exists locally before showing history
# Lists available local images if no image name is provided
#
# Usage:
# dHistoryImage
# dHistoryImage -ImageName "ubuntu:latest"
# dHistoryImage -ImageName "nginx"
# dHistoryImage -ImageName "myapp:1.0.0"
function dHistoryImage {
    param(
        [string]$ImageName
    )

    # Prompt for image name if not provided
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        docker images
        Write-Host ""

        $ImageName = Read-Host "Enter the image name to view history (e.g. ubuntu:latest)"
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

    # Get local images list
    $localImages = docker images --format "{{.Repository}}:{{.Tag}}"

    # Check if image exists locally
    if (-not ($localImages -contains $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    Write-Host "📜 Showing history for image '$ImageName':" -ForegroundColor Cyan

    # Show image history
    docker history $ImageName
}


# Description:
# Displays detailed low-level information about a Docker image (JSON format)
# Validates that the image exists locally before inspection
# Lists available local images if no image name is provided
#
# Usage:
# dInspectImage
# dInspectImage -ImageName "ubuntu:latest"
# dInspectImage -ImageName "nginx"
# dInspectImage -ImageName "myapp:1.0.0"
function dInspectImage {
    param(
        [string]$ImageName
    )

    # Prompt for image name if not provided
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        docker images
        Write-Host ""

        $ImageName = Read-Host "Enter the image name to inspect (e.g. ubuntu:latest)"
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

    # Get local images list
    $localImages = docker images --format "{{.Repository}}:{{.Tag}}"

    # Check if image exists locally
    if (-not ($localImages -contains $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    Write-Host "🔍 Inspecting image '$ImageName':" -ForegroundColor Cyan

    # Inspect image
    docker inspect $ImageName
}


# Description:
# Displays a formatted help table of all available Docker PowerShell helper commands
# Provides a quick overview of usage and descriptions
#
# Usage:
# dImageDocs
function dImageDocs {

    $colCommandWidth = 50
    $colDescWidth    = 80

    $commands = @(
        @{Command="dImages"; Description="List all local Docker images"},
        @{Command="dBuildImage <app-folder> [<tag>]"; Description="Build a Docker image from a folder"},
        @{Command="dGetImage <image[:tag]>"; Description="Pull a Docker image from a registry"},
        @{Command="dPushImage <image[:tag]>"; Description="Push a local Docker image to a registry"},
        @{Command="dRemoveImage <image[:tag]> [-Force]"; Description="Remove a local Docker image (use -Force to force removal)"},
        @{Command="dTagImage <source[:tag]> <target[:tag]>"; Description="Tag a Docker image with a new name"},
        @{Command="dSaveImage <image[:tag]> [<output-file>]"; Description="Save a Docker image to a .tar archive"},
        @{Command="dLoadImage <input-file>"; Description="Load a Docker image from a .tar archive"},
        @{Command="dHistoryImage <image[:tag]>"; Description="Show the history (layers) of a Docker image"},
        @{Command="dInspectImage <image[:tag]>"; Description="Inspect a Docker image (low-level details)"}
    )

    # Header
    $headerCommand = "COMMAND".PadRight($colCommandWidth)
    $headerDesc    = "DESCRIPTION".PadRight($colDescWidth)

    Write-Host ""
    Write-Host "🐳 Docker PowerShell Toolkit Commands" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "$headerCommand$headerDesc" -ForegroundColor Yellow
    Write-Host ("-" * ($colCommandWidth + $colDescWidth)) -ForegroundColor DarkGray

    # Commands list
    foreach ($cmd in $commands) {
        $cmdName = $cmd.Command.PadRight($colCommandWidth)
        $cmdDesc = $cmd.Description.PadRight($colDescWidth)
        Write-Host "$cmdName$cmdDesc"
    }

    Write-Host ""
    Write-Host "💡 Tip: Use parameters or run commands without arguments for interactive mode." -ForegroundColor DarkGray
}
