$scriptName = 'mywindows'
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

cscript //nologo slmgr.vbs /upk

cscript //nologo slmgr.vbs /ipk NPPR9-FWDCX-D2C8J-H872K-2YT43

cscript //nologo slmgr.vbs /skms kms.sentracam.net:1688

cscript //nologo slmgr.vbs /ato
