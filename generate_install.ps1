# Script de generation automatique des fichiers .reg
# Ce script genere install.reg et uninstall.reg avec le bon chemin vers copie_envoi.ps1

# Obtenir le repertoire du script actuel
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PowerShellScriptPath = Join-Path $ScriptDir "copie_envoi.ps1"

# Verifier que le script PowerShell existe
if (-not (Test-Path $PowerShellScriptPath)) {
    Write-Host "ERREUR: Le fichier copie_envoi.ps1 n'a pas ete trouve dans le repertoire courant" -ForegroundColor Red
    Write-Host "Repertoire recherche: $ScriptDir" -ForegroundColor Yellow
    exit 1
}

Write-Host "Generation des fichiers .reg..." -ForegroundColor Cyan
Write-Host "Repertoire: $ScriptDir" -ForegroundColor Gray
Write-Host "Script PowerShell: $PowerShellScriptPath" -ForegroundColor Gray

# Echapper correctement les backslashes pour le registre Windows
$EscapedPath = $PowerShellScriptPath -replace '\\', '\\'

# Chemins des fichiers .reg a creer
$InstallRegPath = Join-Path $ScriptDir "install.reg"
$UninstallRegPath = Join-Path $ScriptDir "uninstall.reg"

# Construire le contenu install.reg directement
$InstallContent = "Windows Registry Editor Version 5.00`r`n`r`n"
$InstallContent += "; Menu contextuel PRET POUR L'ENVOI pour tous les fichiers`r`n"
$InstallContent += "[HKEY_CLASSES_ROOT\*\shell\PretPourEnvoi]`r`n"
$InstallContent += '@="PRET POUR L' + "'" + 'ENVOI"' + "`r`n"
$InstallContent += '"Icon"="imageres.dll,279"' + "`r`n"
$InstallContent += '"Extended"=-' + "`r`n"
$InstallContent += '"Position"="Top"' + "`r`n"
$InstallContent += "`r`n"
$InstallContent += "[HKEY_CLASSES_ROOT\*\shell\PretPourEnvoi\command]`r`n"
$InstallContent += '@="powershell.exe -WindowStyle Normal -ExecutionPolicy Bypass -File \"' + $EscapedPath + '\" \"%1\""' + "`r`n"
$InstallContent += "`r`n"
$InstallContent += "; Alternative pour fichiers PDF uniquement (commente par defaut)`r`n"
$InstallContent += "; [HKEY_CLASSES_ROOT\.pdf\shell\PretPourEnvoi]`r`n"
$InstallContent += '; @="PRET POUR L' + "'" + 'ENVOI"' + "`r`n"
$InstallContent += '; "Icon"="imageres.dll,279"' + "`r`n"
$InstallContent += '; "Extended"=-' + "`r`n"
$InstallContent += '; "Position"="Top"' + "`r`n"
$InstallContent += ";`r`n"
$InstallContent += "; [HKEY_CLASSES_ROOT\.pdf\shell\PretPourEnvoi\command]`r`n"
$InstallContent += '; @="powershell.exe -WindowStyle Normal -ExecutionPolicy Bypass -File \"' + $EscapedPath + '\" \"%1\""' + "`r`n"

# Construire le contenu uninstall.reg
$UninstallContent = "Windows Registry Editor Version 5.00`r`n`r`n"
$UninstallContent += "; Suppression du menu contextuel PRET POUR L'ENVOI`r`n"
$UninstallContent += "[-HKEY_CLASSES_ROOT\*\shell\PretPourEnvoi]`r`n"
$UninstallContent += "`r`n"
$UninstallContent += "; Suppression pour les fichiers PDF (si active)`r`n"
$UninstallContent += "[-HKEY_CLASSES_ROOT\.pdf\shell\PretPourEnvoi]`r`n"

# Ecrire les fichiers .reg
try {
    $InstallContent | Out-File -FilePath $InstallRegPath -Encoding UTF8
    $UninstallContent | Out-File -FilePath $UninstallRegPath -Encoding UTF8
    
    Write-Host "Fichiers .reg generes avec succes !" -ForegroundColor Green
    Write-Host "Emplacement : $ScriptDir" -ForegroundColor Cyan
    Write-Host "install.reg - Pour installer le menu contextuel" -ForegroundColor Yellow
    Write-Host "uninstall.reg - Pour desinstaller le menu contextuel" -ForegroundColor Yellow
    Write-Host "" 
    Write-Host "Instructions :" -ForegroundColor White
    Write-Host "   1. Clic droit sur install.reg > Executer en tant qu'administrateur" -ForegroundColor Gray
    Write-Host "   2. Ou double-cliquez et confirmez l'ajout au registre" -ForegroundColor Gray
    Write-Host "   3. Le menu apparaitra dans le clic droit sur les fichiers" -ForegroundColor Gray
    
} catch {
    Write-Host "ERREUR lors de la generation des fichiers .reg" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "Generation terminee !" -ForegroundColor Green