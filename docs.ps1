# Description:
# Displays a unified documentation reference for the entire Docker PowerShell toolkit.
# Acts as a CLI-style help center for all Docker-related helper commands.
#
# Usage:
# dDocs
function dDocs {

    $colCommandWidth = 45
    $colDescWidth    = 75

    # -----------------------------
    # Command registry (CLI index)
    # -----------------------------
    $commands = @(

        # ---------------- SYSTEM ----------------
        @{Command="dHelp"; Description="Display interactive help documentation"},
        @{Command="dVersion"; Description="Show installed Docker version"},
        @{Command="dInfo"; Description="Display Docker system information"},
        @{Command="dDiskSystem"; Description="Show Docker disk usage statistics"},
        @{Command="dPruneSystem"; Description="Perform full Docker cleanup (containers, images, volumes, networks)"},

        @{Command="dLogin [registry]"; Description="Authenticate to a Docker registry (default: docker.io)"},
        @{Command="dLogout [registry]"; Description="Logout from a Docker registry (default: docker.io)"},

        # ---------------- VOLUMES ----------------
        @{Command="dVolumes"; Description="List all Docker volumes"},
        @{Command="dCreateVolume [name]"; Description="Create a new Docker volume"},
        @{Command="dInspectVolume [name]"; Description="Show detailed information about a Docker volume"},
        @{Command="dRemoveVolume [name] [-Force]"; Description="Remove a Docker volume (use -Force to force deletion)"},
        @{Command="dPruneVolume"; Description="Remove all unused Docker volumes"},

        # ---------------- IMAGES ----------------
        @{Command="dImages"; Description="List all local Docker images"},
        @{Command="dBuildImage <folder> [tag]"; Description="Build a Docker image from a project folder"},
        @{Command="dGetImage <image[:tag]>"; Description="Pull a Docker image from a registry"},
        @{Command="dPushImage <image[:tag]>"; Description="Push a Docker image to a registry"},
        @{Command="dRemoveImage <image[:tag]> [-Force]"; Description="Remove a local Docker image (use -Force to force deletion)"},
        @{Command="dTagImage <source[:tag]> <target[:tag]>"; Description="Create a new tag for an existing image"},
        @{Command="dSaveImage <image[:tag]> [file]"; Description="Export a Docker image to a .tar file"},
        @{Command="dLoadImage <file.tar>"; Description="Import a Docker image from a .tar file"},
        @{Command="dHistoryImage <image[:tag]>"; Description="Show image build history"},
        @{Command="dInspectImage <image[:tag]>"; Description="Show detailed image metadata"},

        # ---------------- COMPOSE ----------------
        @{Command="dComposes [path]"; Description="List Docker Compose services"},
        @{Command="dComposeUp [path] [-Detached]"; Description="Start Docker Compose services (use -Detached for background mode)"},
        @{Command="dComposeDown [path]"; Description="Stop and remove Docker Compose services"},
        @{Command="dComposeBuild [path]"; Description="Build Docker Compose services"},
        @{Command="dComposeLogs [path] [service] [-Follow]"; Description="Show service logs (use -Follow for streaming)"},
        @{Command="dComposeExec [path] [service] [command]"; Description="Execute a command inside a service (default: bash)"},
        @{Command="dComposeRestart [path]"; Description="Restart Docker Compose services"},

        # ---------------- CONTAINERS ----------------
        @{Command="dContainers [-all]"; Description="List Docker containers (running by default, all with -all)"},
        @{Command="dRunContainer <image> [name] [-Detach]"; Description="Run a new container from an image"},

        @{Command="dCreateContainer <image> [name]"; Description="Create a container without starting it"},
        @{Command="dStartContainer [name]"; Description="Start a stopped container"},
        @{Command="dStopContainer [name]"; Description="Stop a running container"},
        @{Command="dRestartContainer [name]"; Description="Restart a container"},
        @{Command="dKillContainer [name]"; Description="Forcefully stop a container"},
        @{Command="dRemoveContainer [name] [-Force]"; Description="Remove a container"},
        @{Command="dLogsContainer [name] [-Follow]"; Description="Display container logs (use -Follow for live stream)"},
        @{Command="dExecContainer [name] [command]"; Description="Execute a command inside a running container"},
        @{Command="dAttachContainer [name]"; Description="Attach to a running container terminal"},
        @{Command="dTopContainer [name]"; Description="Show running processes inside a container"},
        @{Command="dStatsContainer"; Description="Show real-time container resource usage"},
        @{Command="dWaitContainer [name]"; Description="Wait until a container stops"},
        @{Command="dRenameContainer [name] [newName]"; Description="Rename a container"},
        @{Command="dUpdateContainer [name] [options]"; Description="Update container resource limits (CPU, memory, etc.)"},
        @{Command="dPauseContainer [name]"; Description="Pause a running container"},
        @{Command="dUnpauseContainer [name]"; Description="Resume a paused container"},
        @{Command="dExportContainer [name] [file]"; Description="Export container filesystem to a tar archive"},
        @{Command="dCommitContainer [name] [image]"; Description="Create a new image from a container state"},
        @{Command="dDiffContainer [name]"; Description="Show filesystem changes inside a container"},
        @{Command="dCpContainer <source> <destination>"; Description="Copy files between host and container"},

        # ---------------- NETWORKS ----------------
        @{Command="dNetworks"; Description="List all Docker networks"},
        @{Command="dCreateNetwork [name]"; Description="Create a new Docker network"},
        @{Command="dInspectNetwork [name]"; Description="Show detailed network information"},
        @{Command="dConnectNetwork [network] [container]"; Description="Connect a container to a network"},
        @{Command="dDisconnectNetwork [network] [container]"; Description="Disconnect a container from a network"},
        @{Command="dRemoveNetwork [name]"; Description="Remove a Docker network"},
        @{Command="dPruneNetwork"; Description="Remove all unused Docker networks"},

        # ---------------- SWARM ----------------
        @{Command="dInitSwarm"; Description="Initialize a Docker Swarm cluster"},
        @{Command="dJoinSwarm [token] [managerIP]"; Description="Join a Swarm cluster using token and manager IP"},
        @{Command="dNodes"; Description="List all Swarm nodes"},
        @{Command="dServices"; Description="List all Swarm services"},
        @{Command="dCreateService [name] [image]"; Description="Create a Swarm service (default image: nginx)"},
        @{Command="dRemoveService [name]"; Description="Remove a Swarm service"},
        @{Command="dStackDeploy [stackName] [composeFile]"; Description="Deploy a Swarm stack using a compose file"}
    )

    # ---------------- HEADER ----------------
    $headerCommand = "COMMAND".PadRight($colCommandWidth)
    $headerDesc    = "DESCRIPTION".PadRight($colDescWidth)

    Write-Host $headerCommand$headerDesc -ForegroundColor Cyan
    Write-Host ("-" * ($colCommandWidth + $colDescWidth))

    # ---------------- OUTPUT ----------------
    foreach ($cmd in $commands) {
        $cmdName = $cmd.Command.PadRight($colCommandWidth)
        $cmdDesc = $cmd.Description.PadRight($colDescWidth)
        Write-Host "$cmdName$cmdDesc"
    }
}