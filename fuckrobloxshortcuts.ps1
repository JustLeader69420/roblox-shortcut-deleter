#        Configuration (:

# Define the directories and file names to monitor
$monitorConfigs = @(
    @{ Path = "$env:USERPROFILE\Desktop"; Filter = "Shortcut1.lnk" },
    @{ Path = "$env:USERPROFILE\Desktop"; Filter = "Shortcut2.lnk" }
)
# The delay, how often the script checks for filesystem changes
$delay = 5






# End of Configuration section, proceed at your own risk, I am not helping you with this.



# Check if the script is running as a hidden instance
if ($MyInvocation.Line.Trim() -notmatch '-windowstyle hidden') {
    # Relaunch the script as hidden
    Start-Process powershell -ArgumentList '-WindowStyle Hidden -ExecutionPolicy Bypass -File', "`"$PSCommandPath`"" -NoNewWindow
    exit
}


# Create a script block that accepts parameters for the action
$createAction = {
    param ($path, $filter)

    $action = {
        param ($source, $eventArgs)

        # Extract the filename from the event
        $fileName = [System.IO.Path]::GetFileName($eventArgs.FullPath)

        # Check if the detected file matches the filter
        if ($fileName -eq $filter) {
            Start-Sleep -Seconds 2  # Optional: delay to ensure the file is fully created
            if (Test-Path $eventArgs.FullPath) {
                Remove-Item $eventArgs.FullPath
                Write-Output "File deleted: $fileName at $(Get-Date)"
            }
        }
    }

    return $action
}

# Create and configure FileSystemWatcher instances
foreach ($config in $monitorConfigs) {
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $config.Path
    $watcher.Filter = $config.Filter
    $watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'
    
    # Get the action script block with the current configuration
    $action = $createAction.Invoke($config.Path, $config.Filter)
    
    Register-ObjectEvent $watcher "Created" -Action $action
    Write-Output "Created new watcher, Path: $($config.Path), Filter: $($config.Filter)"
}



# Keep the script running indefinitely, fucking the shortcuts in the process
while ($true) {
    Start-Sleep -Seconds $delay
}