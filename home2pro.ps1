$scriptname = 'home2pro'

Start-Transcript "C:\windows\temp\$scriptname.log"
$DebugPreference = 'Continue'


$tempFile = [System.IO.Path]::GetTempFileName() + '.ps1'
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/doteater/doteater.github.io/refs/heads/master/$scriptname.ps1" -OutFile $tempFile

# Self-Elevation Function
Function Elevate-Script {
    If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
        $newProcess.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`""
        $newProcess.Verb = "runas"
        [System.Diagnostics.Process]::Start($newProcess) | Out-Null
        Exit
    }
}

# Invoke Self-Elevation
Elevate-Script

changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T
