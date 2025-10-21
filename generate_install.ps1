# Script de generation automatique des fichiers .reg
# Ce script genere install.reg et uninstall.reg avec les bons chemins vers:
# - copie_envoi.ps1 (menu "PRET POUR L'ENVOI")
# - pdf_numerotation.exe (menu "NUMEROTER PDF")

# Obtenir le repertoire du script actuel (maintenant à la racine)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = $ScriptDir
$PowerShellScriptPath = Join-Path $ProjectRoot "copie_envoi\copie_envoi.ps1"
$PdfNumerotationExePath = Join-Path $ProjectRoot "numerotation_pdf\pdf_numerotation.exe"

# Verifier que le script PowerShell existe
if (-not (Test-Path $PowerShellScriptPath)) {
    Write-Host "ERREUR: Le fichier copie_envoi.ps1 n'a pas ete trouve dans le repertoire courant" -ForegroundColor Red
    Write-Host "Repertoire recherche: $ScriptDir" -ForegroundColor Yellow
    exit 1
}

# Verifier que l'executable PDF existe (optionnel, avec avertissement)
$PdfExeExists = Test-Path $PdfNumerotationExePath
if (-not $PdfExeExists) {
    Write-Host "AVERTISSEMENT: L'executable pdf_numerotation.exe n'a pas ete trouve" -ForegroundColor Yellow
    Write-Host "Chemin recherche: $PdfNumerotationExePath" -ForegroundColor Yellow
    Write-Host "Le menu de numerotation PDF ne sera pas ajoute au registre" -ForegroundColor Yellow
    Write-Host "Executez d'abord build.bat pour compiler l'executable" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "Generation des fichiers .reg..." -ForegroundColor Cyan
Write-Host "Repertoire: $ScriptDir" -ForegroundColor Gray
Write-Host "Script PowerShell: $PowerShellScriptPath" -ForegroundColor Gray
if ($PdfExeExists) {
    Write-Host "Executable PDF: $PdfNumerotationExePath" -ForegroundColor Gray
}

# Echapper correctement les backslashes pour le registre Windows
$EscapedPowerShellPath = $PowerShellScriptPath -replace '\\', '\\'
$EscapedPdfExePath = $PdfNumerotationExePath -replace '\\', '\\'

# Chemins des fichiers .reg a creer
$InstallRegPath = Join-Path $ScriptDir "install.reg"
$UninstallRegPath = Join-Path $ScriptDir "uninstall.reg"

# Construire le contenu install.reg directement
$InstallContent = "Windows Registry Editor Version 5.00`r`n`r`n"

# Menu contextuel PRET POUR L'ENVOI pour tous les fichiers
$InstallContent += "; Menu contextuel PRET POUR L'ENVOI pour tous les fichiers`r`n"
$InstallContent += "[HKEY_CLASSES_ROOT\*\shell\PretPourEnvoi]`r`n"
$InstallContent += '@="PRET POUR L' + "'" + 'ENVOI"' + "`r`n"
$InstallContent += '"Icon"="imageres.dll,279"' + "`r`n"
$InstallContent += '"Position"="Top"' + "`r`n"
$InstallContent += "`r`n"
$InstallContent += "[HKEY_CLASSES_ROOT\*\shell\PretPourEnvoi\command]`r`n"
$InstallContent += '@="powershell.exe -WindowStyle Normal -ExecutionPolicy Bypass -File \"' + $EscapedPowerShellPath + '\" \"%1\""' + "`r`n"
$InstallContent += "`r`n"

# Menu contextuel NUMEROTER PDF pour les fichiers PDF uniquement (si l'executable existe)
if ($PdfExeExists) {
    $InstallContent += "; Menu contextuel NUMEROTER PDF pour les fichiers PDF uniquement`r`n"
    $InstallContent += "[HKEY_CLASSES_ROOT\*\shell\NumerotationPdf]`r`n"
    $InstallContent += '@="NUMEROTER PDF"' + "`r`n"
    $InstallContent += '"Icon"="imageres.dll,14"' + "`r`n"
    $InstallContent += '"Position"="Top"' + "`r`n"
    $InstallContent += "`r`n"
    $InstallContent += "[HKEY_CLASSES_ROOT\*\shell\NumerotationPdf\command]`r`n"
    $InstallContent += '@="\"' + $EscapedPdfExePath + '\" \"%1\""' + "`r`n"
    $InstallContent += "`r`n"
}

# Commentaires pour les alternatives
$InstallContent += "; Alternative pour fichiers PDF uniquement (commente par defaut)`r`n"
$InstallContent += "; [HKEY_CLASSES_ROOT\*\shell\PretPourEnvoi]`r`n"
$InstallContent += '; @="PRET POUR L' + "'" + 'ENVOI"' + "`r`n"
$InstallContent += '; "Icon"="imageres.dll,279"' + "`r`n"
$InstallContent += '; "Extended"=-' + "`r`n"
$InstallContent += '; "Position"="Top"' + "`r`n"
$InstallContent += ";`r`n"
$InstallContent += "; [HKEY_CLASSES_ROOT\*\shell\PretPourEnvoi\command]`r`n"
$InstallContent += '; @="powershell.exe -WindowStyle Normal -ExecutionPolicy Bypass -File \"' + $EscapedPowerShellPath + '\" \"%1\""' + "`r`n"

# Construire le contenu uninstall.reg
$UninstallContent = "Windows Registry Editor Version 5.00`r`n`r`n"
$UninstallContent += "; Suppression du menu contextuel PRET POUR L'ENVOI`r`n"
$UninstallContent += "[-HKEY_CLASSES_ROOT\*\shell\PretPourEnvoi]`r`n"
$UninstallContent += "`r`n"

# Suppression du menu PDF si l'executable existe
if ($PdfExeExists) {
    $UninstallContent += "; Suppression du menu contextuel NUMEROTER PDF`r`n"
    $UninstallContent += "[-HKEY_CLASSES_ROOT\*\shell\NumerotationPdf]`r`n"
    $UninstallContent += "`r`n"
}

$UninstallContent += "; Suppression pour les fichiers PDF (si active)`r`n"
$UninstallContent += "[-HKEY_CLASSES_ROOT\*\shell\PretPourEnvoi]`r`n"

# Ecrire les fichiers .reg
try {
    $InstallContent | Out-File -FilePath $InstallRegPath -Encoding UTF8
    $UninstallContent | Out-File -FilePath $UninstallRegPath -Encoding UTF8
    
    Write-Host "Fichiers .reg generes avec succes !" -ForegroundColor Green
    Write-Host "Emplacement : $ScriptDir" -ForegroundColor Cyan
    Write-Host "install.reg - Pour installer les menus contextuels" -ForegroundColor Yellow
    Write-Host "uninstall.reg - Pour desinstaller les menus contextuels" -ForegroundColor Yellow
    Write-Host "" 
    Write-Host "Menus ajoutes :" -ForegroundColor White
    Write-Host "   - PRET POUR L'ENVOI (tous les fichiers)" -ForegroundColor Gray
    if ($PdfExeExists) {
        Write-Host "   - NUMEROTER PDF (fichiers PDF uniquement)" -ForegroundColor Gray
    } else {
        Write-Host "   - NUMEROTER PDF (non ajoute - executable manquant)" -ForegroundColor Red
    }
    Write-Host "" 
    Write-Host "Instructions :" -ForegroundColor White
    Write-Host "   1. Clic droit sur install.reg > Executer en tant qu'administrateur" -ForegroundColor Gray
    Write-Host "   2. Ou double-cliquez et confirmez l'ajout au registre" -ForegroundColor Gray
    Write-Host "   3. Les menus apparaitront dans le clic droit sur les fichiers" -ForegroundColor Gray
    
} catch {
    Write-Host "ERREUR lors de la generation des fichiers .reg" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "Generation terminee !" -ForegroundColor Green