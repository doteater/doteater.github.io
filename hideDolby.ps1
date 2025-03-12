$scriptName = 'hidedolby'
Start-Transcript "C:\windows\temp\$scriptName.log"
$DebugPreference = 'Continue'


$tempFile = [System.IO.Path]::GetTempFileName() + '.ps1'
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/doteater/doteater.github.io/refs/heads/master/$scriptName.ps1" -OutFile $tempFile

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


Install-PackageProvider -Name NuGet -force
Install-Module pswindowsupdate -force
Import-Module PSWindowsUpdate -force
# $x = Get-WUList -title "Dolby*"
#Hide-WindowsUpdate -Title $x.title -Confirm:$false
#this might work
Hide-WindowsUpdate -Title "Dolby - SoftwareComponent - 3.30702.720.0" -confirm:$false
