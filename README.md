# 📁➡️ Prêt pour l'envoi - Guide d'utilisation complet

## 📋 Description

Ce projet permet d'ajouter une option **"PRET POUR L'ENVOI"** dans le menu contextuel (clic droit) de Windows pour copier rapidement n'importe quel fichier vers le dossier central d'envoi de l'entreprise.

**🆕 Nouvelle fonctionnalité** : Numérotation automatique des pages PDF avec l'option **"NUMEROTER PDF"**.

## 🎯 Fonctionnalités

### 📤 Copie Envoi
- ✅ **Menu contextuel personnalisé** : Option "PRET POUR L'ENVOI" avec icône moderne
- ✅ **Copie automatique** vers `Y:\#Envoie` ou `Z:\#Envoie` (selon disponibilité)
- ✅ **Extraction intelligente du nom de projet** : Remonte jusqu'à 4 niveaux dans l'arborescence
- ✅ **Gestion des doublons** : Renommage automatique si le fichier existe déjà
- ✅ **Feedback utilisateur** : Fenêtre de confirmation avec détails de la copie
- ✅ **Gestion des erreurs** : Messages d'erreur clairs en cas de problème
- ✅ **Chemins avec espaces** : Support complet des noms de fichiers complexes
- ✅ **Position prioritaire** : Affiché en haut du menu contextuel Windows 11
- ✅ **Installation/Désinstallation** : Scripts automatisés pour le déploiement

### 🔢 Numérotation PDF
- ✅ **Menu contextuel PDF** : Option "NUMEROTER PDF" pour les fichiers PDF
- ✅ **Numérotation automatique** : Ajoute "page/total" en bas à droite de chaque page
- ✅ **Détection intelligente** : Traite uniquement les fichiers contenant "_original" ou "ORIGINAL_"
- ✅ **Génération propre** : Crée un nouveau fichier sans le suffixe "_original"
- ✅ **Police standard** : Utilise Helvetica pour une compatibilité maximale
- ✅ **Feedback détaillé** : Affiche le nombre de pages traitées et la taille du fichier

## 📁 Structure du projet

```
123structure-copie_envoi/
├── copie_envoi/
│   └── copie_envoi.ps1           # Script PowerShell principal
├── numerotation_pdf/
│   ├── main.py                   # Script Python de numérotation
│   ├── requirements.txt          # Dépendances Python
│   ├── build.bat                 # Script de compilation
│   └── pdf_numerotation.exe      # Exécutable compilé
├── generate_install.ps1          # 🆕 Générateur automatique des fichiers .reg
├── install.reg                   # Fichier d'installation (généré automatiquement)
├── uninstall.reg                 # Fichier de désinstallation (généré automatiquement)
└── README.md                     # Ce guide complet
```

## 🚀 Installation

### Prérequis

- Windows 10/11
- Droits administrateur pour modifier le registre
- PowerShell activé (par défaut sur Windows)
- Python 3.x (pour la compilation du module PDF, optionnel si vous utilisez l'exécutable fourni)

### 🎯 Méthode Recommandée (Automatique)

1. **Placer les fichiers** dans le dossier de votre choix (ex: `C:\Tools\copie_envoi\`, `D:\Scripts\`, etc.)

2. **Générer les fichiers .reg automatiquement** :
   - Clic droit sur `generate_install.ps1` → **"Exécuter avec PowerShell"**
   - Le script génère automatiquement `install.reg` et `uninstall.reg` avec les bons chemins
   - ✅ **Avantage** : Fonctionne peu importe où vous placez le projet

3. **Installer les menus contextuels** :
   - Clic droit sur le `install.reg` généré → **"Fusionner"**
   - Confirmer l'ajout au registre Windows

4. **Vérifier l'installation** :
   - Clic droit sur n'importe quel fichier → L'option **"📤 PRET POUR L'ENVOI"** doit apparaître
   - Clic droit sur un fichier PDF → L'option **"🔢 NUMEROTER PDF"** doit apparaître

### 📝 Méthode Manuelle (Alternative)

1. **Télécharger les fichiers** dans un dossier accessible
2. **Modifier manuellement `install.reg`** pour corriger les chemins vers `copie_envoi.ps1` et `pdf_numerotation.exe`
3. **Exécuter l'installation** comme ci-dessus
4. ⚠️ **Inconvénient** : À refaire si vous déplacez le dossier

## 📖 Utilisation

### 📤 Copie Envoi

1. **Clic droit** sur le fichier à envoyer
2. **Sélectionner** "PRET POUR L'ENVOI"
3. **Attendre** la fenêtre de confirmation
4. Le fichier est copié vers :
   - `Y:\#Envoie\[NomDuProjet]\` (priorité 1)
   - `Z:\#Envoie\[NomDuProjet]\` (si Y: non disponible)

#### Extraction du nom de projet

Le script extrait automatiquement le nom du projet en remontant l'arborescence :

- **Exemple** : `C:\Users\DM\Desktop\DEV\MonProjet\src\fichier.txt`
- **Résultat** : Copie vers `Y:\#Envoie\MonProjet\fichier.txt`
- **Fallback** : Si aucun projet détecté → `Fichier_AAAAMMJJ_HHMMSS`

### 🔢 Numérotation PDF

1. **Renommer votre PDF** pour inclure "_original" ou "ORIGINAL_" dans le nom
   - Exemple : `mon_document_original.pdf` ou `ORIGINAL_rapport.pdf`
2. **Clic droit** sur le fichier PDF
3. **Sélectionner** "NUMEROTER PDF"
4. **Attendre** le traitement (fenêtre de confirmation automatique)
5. Un nouveau fichier est créé sans le suffixe "_original"
   - Exemple : `mon_document_original.pdf` → `mon_document.pdf`

#### Messages de retour

- ✅ **Succès** : Affiche le chemin source, destination, nombre de pages et taille du fichier
- ❌ **Erreur** : Détaille le problème rencontré (fichier inexistant, nom incorrect, etc.)

## 🎨 Personnalisation

### 📤 Icônes Disponibles

#### Icônes Windows Intégrées

| Icône | Code               | Description                 |
| ----- | ------------------ | --------------------------- |
| 📁    | `shell32.dll,16`   | Dossier classique           |
| 📤    | `shell32.dll,132`  | Envoi/Partage               |
| 📋    | `shell32.dll,46`   | Copie                       |
| ⬆️    | `imageres.dll,5`   | Upload moderne (par défaut) |
| 📨    | `imageres.dll,260` | Email/Envoi                 |
| 🔄    | `shell32.dll,239`  | Synchronisation             |
| ✅    | `shell32.dll,297`  | Validation                  |

#### Utiliser une Icône Personnalisée

```reg
; Dans install.reg, remplacez la ligne Icon par :
"Icon"="C:\\chemin\\vers\\votre\\icone.ico"
```

### 🖱️ Configuration Windows 11

Le fichier `install.reg` est déjà configuré pour Windows 11 :

```reg
; Ces lignes forcent l'affichage dans le menu principal :
"Extended"=-          ; Supprime le flag "Extended"
"Position"="Top"       ; Place en haut du menu
```

### 🔧 Instructions de Personnalisation

#### 1. Changer l'Icône

1. **Modifier `install.reg`** :

   ```reg
   "Icon"="imageres.dll,5"  ; Changez le numéro pour une autre icône
   ```

2. **Ou utiliser l'icône personnalisée fournie** :
   ```reg
   "Icon"="C:\\Users\\DM\\Desktop\\DEV\\123structure\\copie_envoi\\icon_envoi.ico"
   ```

#### 2. Réinstaller après Modification

1. **Désinstaller l'ancienne version** :

   ```cmd
   double-clic sur uninstall.reg
   ```

2. **Installer la nouvelle version** :

   ```cmd
   double-clic sur install.reg
   ```

3. **Redémarrer l'Explorateur** :
   ```cmd
   # Dans PowerShell (en tant qu'administrateur) :
   Stop-Process -Name explorer -Force
   Start-Process explorer
   ```

## ⚙️ Configuration avancée

### Limiter aux fichiers PDF uniquement

Pour restreindre l'option aux fichiers PDF :

1. Ouvrir `install.reg` dans un éditeur de texte
2. Commenter les lignes pour "tous les fichiers" (ajouter `;` au début)
3. Décommenter les lignes pour les fichiers PDF (supprimer `;`)
4. Réinstaller avec le fichier modifié

### Modifier les dossiers de destination

Pour changer les dossiers cibles :

1. Ouvrir `copie_envoi/copie_envoi.ps1` dans un éditeur
2. Modifier la variable `$DestinationFolders` (lignes 10-13)
3. Sauvegarder le fichier

### Recompiler le module PDF

Si vous modifiez le script Python :

1. **Installer les dépendances** :
   ```cmd
   cd numerotation_pdf
   pip install -r requirements.txt
   ```

2. **Recompiler l'exécutable** :
   ```cmd
   .\build.bat
   ```

3. **Régénérer les fichiers .reg** :
   ```cmd
   cd ..
   .\generate_install.ps1
   ```

## 🗑️ Désinstallation

1. **Clic droit** sur `uninstall.reg` → **"Fusionner"**
2. **Confirmer** la suppression des entrées du registre
3. **Supprimer** le dossier du projet si souhaité

## 🐛 Dépannage

### Le menu contextuel n'apparaît pas

1. Vérifier que `install.reg` a été exécuté avec les droits administrateur
2. Redémarrer l'Explorateur Windows
3. Vérifier les chemins dans le registre avec `regedit`

### Erreur "Fichier non trouvé" pour la numérotation PDF

1. Vérifier que le nom du fichier contient "_original" ou "ORIGINAL_"
2. S'assurer que `pdf_numerotation.exe` existe dans le dossier `numerotation_pdf/`
3. Recompiler l'exécutable si nécessaire avec `build.bat`

### Erreur de police dans la numérotation

Le script utilise maintenant la police Helvetica (standard). Si vous rencontrez des erreurs :

1. Vérifier que les dépendances Python sont installées : `pip install -r requirements.txt`
2. Recompiler l'exécutable : `.\build.bat`

---

**Développé par [Baptiste LECHAT](https://github.com/baptistelechat)** 👨‍💻 
