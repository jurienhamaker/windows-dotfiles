# Self elevating
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Change this to your yasb path
$YasbPath = "D:\Software\yasb"
$Env:WHKD_CONFIG_HOME = "$Env:USERPROFILE\.komorebi";

Write-Output "Killing processes"
taskkill /f /im whkd.exe
taskkill /IM komorebi.exe /F

Set-Location -Path $PSScriptRoot
$PidFile = "$PSScriptRoot/yasb_pid.txt"

if (Test-Path $PidFile) {
    $YasbPids = Get-Content -Path $PidFile -Raw

    foreach ($line in $YasbPids) {
        if (-not $line -or $line -ne "") {
            taskkill /F /PID $line
        }
    }

    Remove-Item $PidFile
}

Write-Output $Env:WHKD_CONFIG_HOME
Write-Output "Starting processes"
komorebic start -c "$Env:USERPROFILE/.komorebi/komorebi.json"
Start-Process whkd -WindowStyle hidden
Start-Process -WindowStyle hidden -FilePath python -ArgumentList $YasbPath/src/main.py