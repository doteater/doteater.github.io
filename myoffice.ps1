Start-Transcript C:\windows\temp\myoffice.log
$DebugPreference = 'Continue'


$tempFile = [System.IO.Path]::GetTempFileName() + '.ps1'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/doteater/doteater.github.io/refs/heads/master/myoffice.ps1' -OutFile $tempFile

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

# Your script's main code goes here

####
# INSTALL OFFICE
####

write-output "Installing Office..."

$odtBootstrap = "$env:TEMP\odt.exe"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19029-20278.exe" -OutFile $odtBootstrap

$extractPath = "$env:TEMP\ODT"
Start-Process -FilePath $odtBootstrap -ArgumentList "/quiet /extract:$extractPath" -Wait

$configXml = @"
<Configuration>
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
      <ExcludeApp ID="Outlook" />
      <ExcludeApp ID="Teams" />
      <ExcludeApp ID="OneDrive" />
    </Product>
  </Add>
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@

$configPath = Join-Path $extractPath "config.xml"
$configXml | Out-File -FilePath $configPath -Encoding UTF8

$realSetup = Join-Path $extractPath "setup.exe"
Start-Process -FilePath $realSetup -ArgumentList "/configure `"$configPath`"" -Wait -NoNewWindow #-Priority BelowNormal if cpu is too much?


#pause briefly needed?
start-sleep 5

write-output "DONE Installing Office"


####
# ACTIVATE OFFICE
####

write-output "Activating Office..."

# Change directory to Office16
$pathx64 = "C:\Program Files\Microsoft Office\root\Office16"
$pathx86 = "C:\Program Files (x86)\Microsoft Office\root\Office16"
if (Test-Path $pathx64) { Set-Location $pathx64 } `
elseif (Test-Path $pathx86) { Set-Location $pathx86 } `
else { Write-Error "No office installation found, failed to activate"; exit 1 }

# Convert retail to VLK by installing VLK licenses
Get-ChildItem "..\Licenses16\ProPlus2019VL*.xrm-ms" | ForEach-Object {
    cscript //nologo //B ospp.vbs /inslic:"..\Licenses16\$($_.Name)"
}

# Check and remove existing product key
$dstatusOutput = cscript //nologo ospp.vbs /dstatus
$productKeyLine = $dstatusOutput | Select-String -Pattern "Last 5 characters of installed product key"
if ($productKeyLine) {
    $productKey = ($productKeyLine -split ":")[1].Trim()
    $productKey = $productKey.Substring($productKey.Length - 5)
    Write-Host "Last 5 characters of product key: $productKey"
    cscript //nologo ospp.vbs /unpkey:$productKey
}

# Check status again (should be nothing)
#cscript //nologo ospp.vbs /dstatus

# Add temporary GVLK key
cscript //nologo ospp.vbs /inpkey:NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP

# Set KMS info and activate
cscript //nologo ospp.vbs /sethst:kms.sentracam.net
cscript //nologo ospp.vbs /setprt:1688
cscript //nologo ospp.vbs /act

# Banner check and registry updates
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\0ff1ce15-a989-479d-af46-f275c6370663" -Name "KeyManagementServiceName" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name "KeyManagementServiceName" -Value "kms.sentracam.net"

write-output "DONE Activating Office"

write-output "disabling ms acct sign in"

function Set-RegistryValue {
    param (
        [string]$Hive, #String, DWord, 
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [Microsoft.Win32.RegistryValueKind]$Kind
        #[string]$Kind
        #[string]$User
    )

    get-item -Path "Registry::$Hive`\$Path" -ErrorAction SilentlyContinue -ErrorVariable 'found' | out-null
    if(-not [string]::IsNullOrWhiteSpace($found)) {
        #doesn't exist, create
        New-Item -Path "Registry::$Hive`\$Path" -Force | Out-Null
    }
    Set-ItemProperty -Path "Registry::$Hive`\$Path" -Name $Name -Value $Value -type $Kind
}

Set-RegistryValue "HKEY_CURRENT_USER" "SOFTWARE\Microsoft\Office\16.0\Common\SignIn" "SignInOptions" 3 DWord

write-output "DONE disabling ms acct sign in"

$message = "Office Install and Activation Complete!`nPlease close any remaining command prompt windows.`nReport any problems via IT Support Ticket!"
$title = "Office Install and Activation Complete"
# Use Start-Process to run the GUI in the user's context
Start-Process powershell -ArgumentList @"
    Add-Type -AssemblyName System.Windows.Forms;
    [System.Windows.Forms.MessageBox]::Show('$message', '$title');
"@ -NoNewWindow
