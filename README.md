# 📁➡️ Prêt pour l'envoi - Guide d'utilisation complet

## 📋 Description

Ce projet permet d'ajouter une option **"PRET POUR L'ENVOI"** dans le menu contextuel (clic droit) de Windows pour copier rapidement n'importe quel fichier vers le dossier central d'envoi de l'entreprise.

## 🎯 Fonctionnalités

- ✅ **Menu contextuel personnalisé** : Option "PRET POUR L'ENVOI" avec icône moderne
- ✅ **Copie automatique** vers `Y:\#Envoie` ou `Z:\#Envoie` (selon disponibilité)
- ✅ **Extraction intelligente du nom de projet** : Remonte jusqu'à 4 niveaux dans l'arborescence
- ✅ **Gestion des doublons** : Renommage automatique si le fichier existe déjà
- ✅ **Feedback utilisateur** : Fenêtre de confirmation avec détails de la copie
- ✅ **Gestion des erreurs** : Messages d'erreur clairs en cas de problème
- ✅ **Chemins avec espaces** : Support complet des noms de fichiers complexes
- ✅ **Position prioritaire** : Affiché en haut du menu contextuel Windows 11
- ✅ **Installation/Désinstallation** : Scripts automatisés pour le déploiement

## 📁 Structure du projet

```
copie_envoi/
├── copie_envoi.ps1           # Script PowerShell principal
├── generate_install.ps1      # 🆕 Générateur automatique des fichiers .reg
├── install.reg               # Fichier d'installation (généré automatiquement)
├── uninstall.reg             # Fichier de désinstallation (généré automatiquement)
├── icon_envoi.ico            # Icône personnalisée SVG
└── README.md                 # Ce guide complet
```

## 🚀 Installation

### Prérequis

- Windows 10/11
- Droits administrateur pour modifier le registre
- PowerShell activé (par défaut sur Windows)

### 🎯 Méthode Recommandée (Automatique)

1. **Placer les fichiers** dans le dossier de votre choix (ex: `C:\Tools\copie_envoi\`, `D:\Scripts\`, etc.)

2. **Générer les fichiers .reg automatiquement** :
   - Clic droit sur `generate_install.ps1` → **"Exécuter avec PowerShell"**
   - Le script génère automatiquement `install.reg` et `uninstall.reg` avec le bon chemin
   - ✅ **Avantage** : Fonctionne peu importe où vous placez le projet

3. **Installer le menu contextuel** :
   - Clic droit sur le `install.reg` généré → **"Fusionner"**
   - Confirmer l'ajout au registre Windows

4. **Vérifier l'installation** :
   - Clic droit sur n'importe quel fichier
   - L'option **"📤 PRET POUR L'ENVOI"** doit apparaître en haut du menu

### 📝 Méthode Manuelle (Alternative)

1. **Télécharger les fichiers** dans un dossier accessible
2. **Modifier manuellement `install.reg`** pour corriger le chemin vers `copie_envoi.ps1`
3. **Exécuter l'installation** comme ci-dessus
4. ⚠️ **Inconvénient** : À refaire si vous déplacez le dossier

## 📖 Utilisation

1. **Clic droit** sur le fichier à envoyer
2. **Sélectionner** "PRET POUR L'ENVOI"
3. **Attendre** la fenêtre de confirmation
4. Le fichier est copié vers :
   - `Y:\#Envoie\[NomDuProjet]\` (priorité 1)
   - `Z:\#Envoie\[NomDuProjet]\` (si Y: non disponible)

### Extraction du nom de projet

Le script extrait automatiquement le nom du projet en remontant l'arborescence :

- **Exemple** : `C:\Users\DM\Desktop\DEV\MonProjet\src\fichier.txt`
- **Résultat** : Copie vers `Y:\#Envoie\MonProjet\fichier.txt`
- **Fallback** : Si aucun projet détecté → `Fichier_AAAAMMJJ_HHMMSS`

### Messages de retour

- ✅ **Succès** : Affiche le chemin source, destination et taille du fichier
- ❌ **Erreur** : Détaille le problème rencontré (fichier inexistant, dossier inaccessible, etc.)

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

1. Ouvrir `copie_envoi.ps1` dans un éditeur
2. Modifier la variable `$DestinationFolders` (lignes 10-13)
3. Sauvegarder le fichier

## 🗑️ Désinstallation

1. **Clic droit** sur `uninstall.reg` → **"Fusionner"**
2. **Confirmer** la suppression du registre
3. **Supprimer** le dossier contenant les fichiers du projet

## 🔧 Dépannage

### L'option n'apparaît pas dans le menu contextuel

- Vérifier que `install.reg` a été exécuté avec les droits administrateur
- Redémarrer l'explorateur Windows (`Ctrl+Shift+Échap` → Redémarrer "Explorateur Windows")
- Vérifier que le chemin du script est correct dans le registre

### La fenêtre se ferme immédiatement sans afficher de message

- Le script utilise maintenant `-WindowStyle Normal` pour rester visible
- Une pause "Appuyez sur une touche" permet de lire les messages

### Erreur "Fichier de script introuvable"
- **Solution rapide** : Exécuter `generate_install.ps1` puis réinstaller avec le nouveau `install.reg`
- Vérifier que `copie_envoi.ps1` est dans le même dossier que lors de l'installation
- Le chemin dans le registre doit correspondre à l'emplacement réel du script

### Projet déplacé vers un autre dossier
- **Solution automatique** : Exécuter `generate_install.ps1` dans le nouveau dossier
- Désinstaller l'ancienne version avec `uninstall.reg`
- Installer la nouvelle version avec le `install.reg` fraîchement généré

### Erreur "Dossier de destination inaccessible"

- Vérifier la connectivité réseau
- Contrôler les droits d'accès aux dossiers `Y:\#Envoie` et `Z:\#Envoie`
- Vérifier que les lecteurs réseau sont montés

### L'icône ne s'affiche pas

- Vérifiez le chemin de l'icône dans `install.reg`
- Utilisez des barres obliques inversées doubles `\\`
- Testez avec une icône système d'abord

### Menu toujours dans "Afficher d'autres options" (Windows 11)

- La configuration actuelle avec `"Position"="Top"` devrait résoudre le problème
- Redémarrez complètement Windows si nécessaire
- Vérifiez les permissions du registre

### Politique d'exécution PowerShell

Si PowerShell refuse d'exécuter le script :

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🌐 Ressources pour les Icônes Windows

Pour explorer toutes les icônes Windows disponibles :

**🔗 Site recommandé** : [Windows Icons Gallery](https://www.nirsoft.net/utils/iconsext.html)

- Outil gratuit NirSoft IconsExtract
- Permet d'extraire et visualiser toutes les icônes des DLL Windows
- Support de `shell32.dll`, `imageres.dll`, `wmploc.dll`, etc.

**Alternative en ligne** : [Icon Archive - Windows Icons](https://www.iconarchive.com/show/windows-8-icons-by-icons8.html)

## 📝 Notes techniques

- **Sécurité** : Le script utilise `-ExecutionPolicy Bypass` pour éviter les restrictions
- **Performance** : Copie directe sans compression pour préserver la vitesse
- **Compatibilité** : Testé sur Windows 10 et Windows 11
- **Encodage** : Support UTF-8 pour les caractères spéciaux
- **Architecture** : Extraction intelligente du nom de projet sur 4 niveaux
- **Interface** : Icône moderne et position prioritaire dans le menu contextuel

## 🎯 Résultat Final

✅ **Menu principal** : "📤 PRET POUR L'ENVOI" avec icône moderne  
✅ **Position** : En haut du menu contextuel Windows 11  
✅ **Fonctionnement** : Clic direct sans "Afficher d'autres options"  
✅ **Organisation** : Création automatique de dossiers par projet  
✅ **Feedback** : Messages clairs de succès ou d'erreur

## 🤝 Support

Pour toute question ou problème :

1. Vérifier la section **Dépannage** ci-dessus
2. Consulter les logs PowerShell en cas d'erreur
3. Contacter l'administrateur système si nécessaire

---

**Auteur** : Baptiste LECHAT  
**Version** : 2.0  
**Dernière mise à jour** : 09/01/2025
