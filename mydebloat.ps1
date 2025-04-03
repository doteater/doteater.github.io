$scriptname = 'mydebloat'

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


param (
    [switch]$Silent,
    [switch]$Verbose,
    [switch]$Sysprep,
    [switch]$RunAppConfigurator,
    [switch]$RunDefaults, [switch]$RunWin11Defaults,
    [switch]$RunSavedSettings,
    [switch]$RemoveApps, 
    [switch]$RemoveAppsCustom,
    [switch]$RemoveGamingApps,
    [switch]$RemoveCommApps,
    [switch]$RemoveDevApps,
    [switch]$RemoveW11Outlook,
    [switch]$ForceRemoveEdge,
    [switch]$DisableDVR,
    [switch]$DisableTelemetry,
    [switch]$DisableBingSearches, [switch]$DisableBing,
    [switch]$DisableDesktopSpotlight,
    [switch]$DisableLockscrTips, [switch]$DisableLockscreenTips,
    [switch]$DisableWindowsSuggestions, [switch]$DisableSuggestions,
    [switch]$ShowHiddenFolders,
    [switch]$ShowKnownFileExt,
    [switch]$HideDupliDrive,
    [switch]$TaskbarAlignLeft,
    [switch]$HideSearchTb, [switch]$ShowSearchIconTb, [switch]$ShowSearchLabelTb, [switch]$ShowSearchBoxTb,
    [switch]$HideTaskview,
    [switch]$DisableStartRecommended,
    [switch]$DisableCopilot,
    [switch]$DisableRecall,
    [switch]$DisableWidgets, [switch]$HideWidgets,
    [switch]$DisableChat, [switch]$HideChat,
    [switch]$ClearStart,
    [switch]$ClearStartAllUsers,
    [switch]$RevertContextMenu,
    [switch]$DisableMouseAcceleration,
    [switch]$HideHome,
    [switch]$HideGallery,
    [switch]$ExplorerToHome,
    [switch]$ExplorerToThisPC,
    [switch]$ExplorerToDownloads,
    [switch]$ExplorerToOneDrive,
    [switch]$DisableOnedrive, [switch]$HideOnedrive,
    [switch]$Disable3dObjects, [switch]$Hide3dObjects,
    [switch]$DisableMusic, [switch]$HideMusic,
    [switch]$DisableIncludeInLibrary, [switch]$HideIncludeInLibrary,
    [switch]$DisableGiveAccessTo, [switch]$HideGiveAccessTo,
    [switch]$DisableShare, [switch]$HideShare
)

# Show error if current powershell environment does not have LanguageMode set to FullLanguage 
if ($ExecutionContext.SessionState.LanguageMode -ne "FullLanguage") {
   Write-Host "Error: Win11Debloat is unable to run on your system. Powershell execution is restricted by security policies" -ForegroundColor Red
   Write-Output ""
   Write-Output "Press enter to exit..."
   Read-Host | Out-Null
   Exit
}

Clear-Host
Write-Output "-------------------------------------------------------------------------------------------"
Write-Output " Win11Debloat Script - Get"
Write-Output "-------------------------------------------------------------------------------------------"

Write-Output "> Downloading Win11Debloat..."

# Download latest version of Win11Debloat from github as zip archive
Invoke-WebRequest http://github.com/raphire/win11debloat/archive/master.zip -OutFile "$env:TEMP/win11debloat-temp.zip"

# Remove old script folder if it exists, except for CustomAppsList and SavedSettings files
if (Test-Path "$env:TEMP/Win11Debloat/Win11Debloat-master") {
    Write-Output ""
    Write-Output "> Cleaning up old Win11Debloat folder..."
    Get-ChildItem -Path "$env:TEMP/Win11Debloat/Win11Debloat-master" -Exclude CustomAppsList,SavedSettings | Remove-Item -Recurse -Force
}

Write-Output ""
Write-Output "> Unpacking..."

# Unzip archive to Win11Debloat folder
Expand-Archive "$env:TEMP/win11debloat-temp.zip" "$env:TEMP/Win11Debloat"

###
###
# add my SavedSettings
###
###

Set-Content "$env:TEMP/Win11Debloat/Win11Debloat-master/SavedSettings" -Value @"
RemoveApps#- Remove default selection of bloatware apps
RemoveCommApps#- Remove the Mail, Calendar, and People apps
RemoveW11Outlook#- Remove the new Outlook for Windows app
RemoveDevApps#- Remove developer-related apps
RemoveGamingApps#- Remove the Xbox App and Xbox Gamebar
DisableDVR#- Disable Xbox game/screen recording
DisableTelemetry#- Disable telemetry, diagnostic data, activity history, app-launch tracking & targeted ads
DisableSuggestions#- Disable tips, tricks, suggestions and ads in start, settings, notifications and File Explorer
DisableDesktopSpotlight#- Disable the Windows Spotlight desktop background option.
DisableLockscreenTips#- Disable tips & tricks on the lockscreen
DisableBing#- Disable & remove bing web search, bing AI & cortana in Windows search
DisableCopilot#- Disable and remove Windows Copilot
DisableRecall#- Disable Windows Recall snapshots
ClearStartAllUsers#- Remove all pinned apps from the start menu for all existing and new users
DisableStartRecommended#- Disable & hide the recommended section in the start menu.
HideTaskview#- Hide the taskview button from the taskbar
DisableWidgets#- Disable the widget service & hide the widget (news and interests) icon from the taskbar
ShowHiddenFolders#- Show hidden files, folders and drives
ShowKnownFileExt#- Show file extensions for known file types
"@

Set-Content "$env:TEMP/Win11Debloat/Win11Debloat-master/CustomAppsList" -Value @"
ACGMediaPlayer
ActiproSoftwareLLC
AdobeSystemsIncorporated.AdobePhotoshopExpress
Amazon.com.Amazon
AmazonVideo.PrimeVideo
Asphalt8Airborne
AutodeskSketchBook
CaesarsSlotsFreeCasino
Clipchamp.Clipchamp
COOKINGFEVER
CyberLinkMediaSuiteEssentials
Disney
DisneyMagicKingdoms
DrawboardPDF
Duolingo-LearnLanguagesforFree
EclipseManager
Facebook
FarmVille2CountryEscape
fitbit
Flipboard
HiddenCity
HULULLC.HULUPLUS
iHeartRadio
Instagram
king.com.BubbleWitch3Saga
king.com.CandyCrushSaga
king.com.CandyCrushSodaSaga
LinkedInforWindows
MarchofEmpires
Microsoft.549981C3F5F10
Microsoft.BingFinance
Microsoft.BingFoodAndDrink
Microsoft.BingHealthAndFitness
Microsoft.BingNews
Microsoft.BingSearch
Microsoft.BingSports
Microsoft.BingTranslator
Microsoft.BingTravel
Microsoft.BingWeather
Microsoft.Copilot
Microsoft.GamingApp
Microsoft.MicrosoftPowerBIForWindows
Microsoft.MicrosoftSolitaireCollection
Microsoft.MixedReality.Portal
Microsoft.NetworkSpeedTest
Microsoft.News
Microsoft.Office.OneNote
Microsoft.Office.Sway
Microsoft.OneConnect
Microsoft.OneDrive
Microsoft.OutlookForWindows
Microsoft.People
Microsoft.ScreenSketch
Microsoft.SkypeApp
Microsoft.Windows.DevHome
Microsoft.WindowsMaps
Microsoft.YourPhone
Microsoft.ZuneMusic
Microsoft.ZuneVideo
MicrosoftCorporationII.MicrosoftFamily
MicrosoftCorporationII.QuickAssist
MicrosoftTeams
MicrosoftWindows.CrossDevice
MSTeams
Netflix
NYTCrossword
OneCalendar
PandoraMediaInc
PhototasticCollage
PicsArt-PhotoStudio
Plex
PolarrPhotoEditorAcademicEdition
Royal Revolt
Shazam
Sidia.LiveWallpaper
SlingTV
Spotify
TikTok
TuneInRadio
Twitter
Viber
WinZipUniversal
Wunderlist
XING
"@


# Remove archive
Remove-Item "$env:TEMP/win11debloat-temp.zip"

# Make list of arguments to pass on to the script
$arguments = $($PSBoundParameters.GetEnumerator() | ForEach-Object {"-$($_.Key)"})

Write-Output ""
Write-Output "> Running Win11Debloat..."

# Run Win11Debloat script with the provided arguments
$debloatProcess = Start-Process powershell.exe -PassThru -ArgumentList "-executionpolicy bypass -File $env:TEMP\Win11Debloat\Win11Debloat-master\Win11Debloat.ps1 -RunSavedSetting -RemoveAppsCustom -silent $arguments" -Verb RunAs

# Wait for the process to finish before continuing
if ($null -ne $debloatProcess) {
    $debloatProcess.WaitForExit()
}

# Remove all remaining script files, except for CustomAppsList and SavedSettings files
if (Test-Path "$env:TEMP/Win11Debloat/Win11Debloat-master") {
    Write-Output ""
    Write-Output "> Cleaning up..."

    # Cleanup, remove Win11Debloat directory
    Get-ChildItem -Path "$env:TEMP/Win11Debloat/Win11Debloat-master" -Exclude CustomAppsList,SavedSettings | Remove-Item -Recurse -Force
}

#remove MS Store taskbar icon
$appname = "Microsoft Store"
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $appname}).Verbs() | Where-Object {$_.Name.replace('&','') -match 'Unpin from taskbar'} | ForEach-Object {$_.DoIt()}
Write-Output ""

$message = "Windows 10/11 debloat complete`nReport any problems via IT Support Ticket!"
$title = "Windows 10/11 debloat complete"
# Use Start-Process to run the GUI in the user's context
Start-Process powershell -ArgumentList @"
    Add-Type -AssemblyName System.Windows.Forms;
    [System.Windows.Forms.MessageBox]::Show('$message', '$title');
"@ -NoNewWindow
