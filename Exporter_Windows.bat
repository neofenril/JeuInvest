@echo off
rem Exporte JeuClaude pour Windows : export\windows\JeuClaude.exe (un seul fichier, donnees integrees).
setlocal
chcp 65001 >nul
set "RACINE=%~dp0"
set "GODOT=%RACINE%outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
set "SORTIE=%RACINE%export\windows\JeuClaude.exe"

if not exist "%GODOT%" (
    echo ERREUR : Godot introuvable : "%GODOT%"
    goto :echec
)
if not exist "%RACINE%export\windows" mkdir "%RACINE%export\windows"
if exist "%SORTIE%" del /q "%SORTIE%"

echo Import du projet...
"%GODOT%" --headless --path "%RACINE%godot" --import
echo Export Windows en cours...
"%GODOT%" --headless --path "%RACINE%godot" --export-release "Windows" "%SORTIE%"
if errorlevel 1 goto :echec
if not exist "%SORTIE%" goto :echec

echo.
echo ===== SUCCES : %SORTIE% =====
for %%F in ("%SORTIE%") do echo Taille : %%~zF octets
echo Ce fichier suffit pour jouer : il peut etre copie et partage tel quel.
endlocal
if "%~1"=="" pause
exit /b 0

:echec
echo.
echo ===== ECHEC de l'export Windows (voir les messages ci-dessus) =====
endlocal
if "%~1"=="" pause
exit /b 1
