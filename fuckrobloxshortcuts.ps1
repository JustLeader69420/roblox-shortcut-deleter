#          Configuration (:

# Define the directories and file names to monitor, comment to disable.
# Make sure the last entry does not have a colon (,) behind it to prevent errors.
$monitorConfigs = @(
	@{ Path = "$env:USERPROFILE\Desktop"; Filter = "Roblox Player.lnk" },
	@{ Path = "$env:USERPROFILE\Desktop"; Filter = "Roblox Studio.lnk" },
#	@{ Path = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Roblox"; Filter = "Roblox Player.lnk" },
#	@{ Path = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Roblox"; Filter = "Roblox Studio.lnk" }
)

# The delay in seconds, how often the script checks for the files
$delay = 10

# If the script should run hidden (0 = false; 1 = true)
$hidden = 1

# If running multiple instances should be possible (0 = false; 1 = true)
$multipleinstances = 0

# Define the lock file path - this makes sure only one instance of the script runs
$lockFilePath = "$env:USERPROFILE\robloxshortcutremover.lock"

# End of Configuration section, proceed at your own risk, I am not helping you with this.







Add-Type @'
using System;
using System.Runtime.InteropServices;

public class API {

    public enum SW : int {
        Hide            = 0,
        Normal          = 1,
        ShowMinimized   = 2,
        Maximize        = 3,
        ShowNoActivate  = 4,
        Show            = 5,
        Minimize        = 6,
        ShowMinNoActive = 7,
        ShowNA          = 8,
        Restore         = 9,
        Showdefault     = 10,
        Forceminimize   = 11
    }

    [DllImport("user32.dll")]
    public static extern int ShowWindow(IntPtr hwnd, SW nCmdShow);
}
'@
# Hide the script
# useful: https://superuser.com/questions/1740074/looking-to-hide-a-window-by-sending-it-to-background-or-detatching-it-from-a
if ($hidden -eq 1) {
Write-Output "Hiding..."
$ThisWindow = [System.Diagnostics.Process]::GetCurrentProcess().MainwindowHandle
[API]::ShowWindow($ThisWindow,'Hide')
# to unhide: [API]::ShowWindow($ThisWindow,'Show')
}


# Function to check if another instance is running
function Check-ForExistingInstance {
    if (Test-Path $lockFilePath) {
        $lockFileContent = Get-Content $lockFilePath
        if ($lockFileContent) {
            $oldPid = [int]$lockFileContent
            if (Get-Process -Id $oldPid -ErrorAction SilentlyContinue) {
                Write-Output "An instance is already running with PID $oldPid. Terminating it..."
                Stop-Process -Id $oldPid -Force
                Start-Sleep -Seconds 2 # Give time for the old process to terminate
            }
        }
    }
    # Create or update the lock file with the current process ID
    #$pid = $PID
    $PID | Out-File -FilePath $lockFilePath -Force
}

# Function to clean up the lock file
function Cleanup-LockFile {
    if (Test-Path $lockFilePath) {
        Remove-Item $lockFilePath -Force
    }
}

# Check for existing instance and manage lock file
if (!$multipleinstances -eq 1) {Check-ForExistingInstance}

# Ensure the lock file is cleaned up on exit
Register-EngineEvent PowerShell.Exiting -Action { Cleanup-LockFile } | Out-Null


# Keep the script running indefinitely
Write-Output "Script is now running. Press Ctrl+C to stop."
while ($true) {
    foreach ($config in $monitorConfigs) {
        $filePath = Join-Path -Path $config.Path -ChildPath $config.Filter
        
        # Check if the file exists
        if (Test-Path $filePath) {
            try {
                # Delete the file
                Remove-Item "$filePath" -Force
                Write-Output "File deleted: $filePath at $(Get-Date)"
            } catch {
                Write-Output "Failed to delete file: $filePath. Error: $_"
            }
        }
    }
    
    # Sleep before the next check
    Start-Sleep -Seconds $delay
}
