<#
.SYNOPSIS
Automatisiert tägliche Updates aller installierten Pakete via winget im Benutzerkontext.

.DESCRIPTION
Dieses Skript erstellt einen geplanten Task, der täglich um 03:00 Uhr `winget upgrade --all --silent` ausführt.
Der Task wird mit den höchsten Rechten im Benutzerkontext erstellt.

.NOTES
Autor: Hossein Aliyoldashi
#>

# Interaktiven Benutzer ermitteln
$interactiveUser = (Get-WmiObject -Class Win32_ComputerSystem).UserName
$domain, $username = $interactiveUser -split '\\'

# Pfad zum Benutzerprofil finden
$userProfilePath = (Get-CimInstance Win32_UserProfile | Where-Object {
    $_.LocalPath -like "*\$username" -and $_.Loaded
}).LocalPath

# Pfad zu winget zusammensetzen
$wingetPath = "$userProfilePath\AppData\Local\Microsoft\WindowsApps\winget.exe"

# Parameter für den geplanten Task
$taskName = "WingetUserUpdate"
$arguments = "upgrade --all --silent"
$fullCommand = "`"$wingetPath`" $arguments"

# Geplanten Task erstellen
schtasks /create /tn $taskName /tr "$fullCommand" /sc daily /st 03:00 /rl HIGHEST /ru "$username" /f

# Task sofort starten
Start-ScheduledTask -TaskName $taskName
