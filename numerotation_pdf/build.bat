@echo off
REM Script de compilation - Numérotation PDF
REM Compile main.py en exécutable autonome avec environnement virtuel
REM Auteur: Baptiste LECHAT
REM Version: 1.1

echo ========================================
echo   COMPILATION DU SCRIPT DE NUMEROTATION
echo ========================================
echo.

REM Vérification de l'existence du fichier main.py
if not exist "main.py" (
    echo [ERREUR] Le fichier main.py n'existe pas dans le repertoire courant
    echo Repertoire actuel: %CD%
    pause
    exit /b 1
)

REM Vérification de l'installation de Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installe ou n'est pas dans le PATH
    echo Veuillez installer Python 3.10+ et reessayer
    pause
    exit /b 1
)

echo [INFO] Python detecte
python --version

REM Création de l'environnement virtuel s'il n'existe pas
if not exist "venv" (
    echo.
    echo [INFO] Creation de l'environnement virtuel...
    python -m venv venv
    if errorlevel 1 (
        echo [ERREUR] Echec de la creation de l'environnement virtuel
        pause
        exit /b 1
    )
    echo [INFO] Environnement virtuel cree avec succes
)

REM Activation de l'environnement virtuel
echo.
echo [INFO] Activation de l'environnement virtuel...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERREUR] Echec de l'activation de l'environnement virtuel
    pause
    exit /b 1
)

REM Installation des dépendances dans le venv
if exist "requirements.txt" (
    echo.
    echo [INFO] Installation des dependances dans le venv...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo [ERREUR] Echec de l'installation des dependances
        pause
        exit /b 1
    )
) else (
    echo.
    echo [INFO] Installation manuelle des dependances dans le venv...
    pip install pypdf reportlab pyinstaller
    if errorlevel 1 (
        echo [ERREUR] Echec de l'installation des dependances
        pause
        exit /b 1
    )
)

echo.
echo [INFO] Compilation en cours...
echo Commande: pyinstaller --onefile --noconsole --name="pdf_numerotation" --distpath "./" main.py

REM Compilation avec PyInstaller
pyinstaller --onefile --noconsole --name="pdf_numerotation" --distpath "./" main.py

if errorlevel 1 (
    echo.
    echo [ERREUR] Echec de la compilation
    pause
    exit /b 1
)

REM Vérification de la création de l'exécutable
if exist ".\pdf_numerotation.exe" (
    echo.
    echo [SUCCES] Compilation reussie !
    echo Executable genere: .\pdf_numerotation.exe
    echo.
    echo Prochaines etapes:
    echo 1. Executer generate_install.ps1 pour creer les fichiers .reg
    echo 2. Executer install.reg pour ajouter les menus contextuels
    echo.
    echo Note: L'executable ne doit pas etre deplace apres la compilation pour generate_install.ps1
) else (
    echo.
    echo [ERREUR] L'executable n'a pas ete cree
)

echo.
pause