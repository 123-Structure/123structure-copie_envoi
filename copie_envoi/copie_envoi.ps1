# Script PowerShell - Prêt pour l'envoi
# Copie un fichier vers le dossier central d'envoi de l'entreprise
# Auteur: Baptiste LECHAT
# Version: 1.0

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

# Configuration de l'encodage pour éviter les problèmes d'affichage
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Variable pour tracker s'il y a eu une erreur
$global:hasError = $false

# Configuration des dossiers de destination (par ordre de priorité)
$DestinationFolders = @(
    "Y:\#Envoie",
    "Z:\#Envoie"
)

# Fonction pour afficher une fenêtre de message
function Show-MessageBox {
    param(
        [string]$Message,
        [string]$Title = "Prêt pour l'envoi",
        [string]$Icon = "Information"
    )
    
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::$Icon)
}

# Fonction pour écrire dans le log
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
}

try {
    # Vérification de l'existence du fichier source
    if (-not (Test-Path -Path $FilePath)) {
        $errorMsg = "[ERREUR] Le fichier source n'existe pas.`nChemin : $FilePath"
        Write-Log $errorMsg
        Show-MessageBox -Message $errorMsg -Icon "Error"
        $global:hasError = $true
        
        # Pause pour permettre à l'utilisateur de lire le message d'erreur
        Write-Host "`nAppuyez sur une touche pour fermer cette fenetre..." -ForegroundColor Red
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    # Obtenir les informations du fichier
    $sourceFile = Get-Item -Path $FilePath
    $fileName = $sourceFile.Name
    Write-Log "Fichier source : $($sourceFile.FullName)"

    # Extraire le nom du projet (4 niveaux en arrière ou le plus haut possible)
    $ProjectName = ""
    try {
        $CurrentPath = Split-Path -Path $FilePath -Parent
        $LevelsUp = 0
        
        # Remonter jusqu'à 4 niveaux ou jusqu'à la racine
        while ($LevelsUp -lt 4 -and $CurrentPath -and $CurrentPath -ne [System.IO.Path]::GetPathRoot($CurrentPath)) {
            $ParentPath = Split-Path -Path $CurrentPath -Parent
            if ($ParentPath -and $ParentPath -ne $CurrentPath) {
                $CurrentPath = $ParentPath
                $LevelsUp++
            } else {
                break
            }
        }
        
        $ProjectName = Split-Path -Path $CurrentPath -Leaf
        
        # Si le nom est vide ou trop court, utiliser un nom par défaut
        if (-not $ProjectName -or $ProjectName.Length -lt 3) {
            $ProjectName = "Fichier_" + (Get-Date -Format "yyyyMMdd_HHmmss")
        }
        
        Write-Log "Nom du projet extrait : $ProjectName (remonte de $LevelsUp niveaux)"
    } catch {
        # En cas d'erreur, utiliser un nom par défaut
        $ProjectName = "Fichier_" + (Get-Date -Format "yyyyMMdd_HHmmss")
        Write-Log "Utilisation du nom par defaut : $ProjectName"
    }

    # Recherche du dossier de destination de base disponible
    $baseDestinationFolder = $null
    foreach ($folder in $DestinationFolders) {
        if (Test-Path -Path $folder) {
            $baseDestinationFolder = $folder
            Write-Log "Dossier de destination de base trouvé : $folder"
            break
        }
    }

    # Vérification de la disponibilité d'un dossier de destination de base
    if (-not $baseDestinationFolder) {
        $errorMsg = "[ERREUR] Aucun dossier de destination n'est accessible.`nDossiers testés :`n" + ($DestinationFolders -join "`n")
        Write-Log $errorMsg
        Show-MessageBox -Message $errorMsg -Icon "Error"
        $global:hasError = $true
        
        # Pause pour permettre à l'utilisateur de lire le message d'erreur
        Write-Host "`nAppuyez sur une touche pour fermer cette fenetre..." -ForegroundColor Red
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    # Créer le dossier du projet dans le dossier de destination
    $destinationFolder = Join-Path -Path $baseDestinationFolder -ChildPath $ProjectName
    if (-not (Test-Path -Path $destinationFolder)) {
        try {
            New-Item -Path $destinationFolder -ItemType Directory -Force | Out-Null
            Write-Log "Dossier créé : $ProjectName"
        } catch {
            $errorMsg = "[ERREUR] Impossible de créer le dossier : $ProjectName`nErreur : $($_.Exception.Message)"
            Write-Log $errorMsg
            Show-MessageBox -Message $errorMsg -Icon "Error"
            $global:hasError = $true
            
            # Pause pour permettre à l'utilisateur de lire le message d'erreur
            Write-Host "`nAppuyez sur une touche pour fermer cette fenetre..." -ForegroundColor Red
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
    } else {
        Write-Log "Dossier du projet existe déjà : $ProjectName"
    }

    # Construction du chemin de destination
    $destinationPath = Join-Path -Path $destinationFolder -ChildPath $fileName
    
    # Gestion des fichiers en doublon
    $counter = 1
    while (Test-Path -Path $destinationPath) {
        $fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $fileExtension = [System.IO.Path]::GetExtension($fileName)
        $newFileName = "$fileBaseName($counter)$fileExtension"
        $destinationPath = Join-Path -Path $destinationFolder -ChildPath $newFileName
        $counter++
    }

    # Copie du fichier
    Write-Log "Copie en cours vers : $destinationPath"
    Copy-Item -Path $FilePath -Destination $destinationPath -Force
    
    # Vérification de la copie
    if (Test-Path -Path $destinationPath) {
        $successMsg = "[SUCCES] Copie reussie !`n`nFichier source :`n$($sourceFile.FullName)`n`nDestination :`n$destinationPath`n`nTaille : $([math]::Round($sourceFile.Length / 1MB, 2)) MB"
        Write-Log "Copie réussie : $destinationPath"
        Show-MessageBox -Message $successMsg -Icon "Information"
    } else {
        throw "La copie a échoué - le fichier de destination n'existe pas"
    }

} catch {
    $errorMsg = "[ERREUR] Erreur lors de la copie !`n`nFichier source :`n$FilePath`n`nErreur :`n$($_.Exception.Message)"
    Write-Log "Erreur : $($_.Exception.Message)"
    Show-MessageBox -Message $errorMsg -Icon "Error"
    $global:hasError = $true
    
    # Pause pour permettre à l'utilisateur de lire le message d'erreur
    Write-Host "`nAppuyez sur une touche pour fermer cette fenêtre..." -ForegroundColor Red
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Log "Script terminé avec succès"

# Fermeture automatique si pas d'erreur, sinon attendre une touche
if (-not $global:hasError) {
    Write-Host "`n[INFO] Fermeture automatique dans 1 seconde..." -ForegroundColor Green
    Start-Sleep -Seconds 1
    exit 0
} else {
    Write-Host "`nAppuyez sur une touche pour fermer cette fenetre..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}