@echo off
rem Exporte JeuClaude pour Android : export\android\JeuClaude.apk (APK de debug, a installer a la main).
rem Prerequis : outils\jdk-17 et outils\android-sdk (platform-tools, build-tools, platforms),
rem chemins renseignes dans les parametres de l'editeur Godot (export/android/...).
setlocal
chcp 65001 >nul
set "RACINE=%~dp0"
rem Godot : variable JEUCLAUDE_GODOT si elle est definie (worktree Git, autre emplacement), sinon outils\ du depot.
rem (Le JDK et le SDK Android restent cherches dans outils\ du dossier de ce fichier.)
set "GODOT=%RACINE%outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
if defined JEUCLAUDE_GODOT set "GODOT=%JEUCLAUDE_GODOT%"
echo Godot : "%GODOT%"
set "SORTIE=%RACINE%export\android\JeuClaude.apk"
set "JAVA_HOME=%RACINE%outils\jdk-17"
set "ANDROID_HOME=%RACINE%outils\android-sdk"

if not exist "%GODOT%" (
    echo ERREUR : Godot introuvable : "%GODOT%"
    goto :echec
)
if not exist "%JAVA_HOME%\bin\java.exe" (
    echo ERREUR : JDK introuvable : "%JAVA_HOME%"
    goto :echec
)
if not exist "%ANDROID_HOME%\build-tools" (
    echo ERREUR : Android SDK incomplet ^(build-tools manquant^) : "%ANDROID_HOME%"
    goto :echec
)
if not exist "%RACINE%export\android" mkdir "%RACINE%export\android"
if exist "%SORTIE%" del /q "%SORTIE%"

echo Import du projet...
"%GODOT%" --headless --path "%RACINE%godot" --import
echo Export Android en cours...
"%GODOT%" --headless --path "%RACINE%godot" --export-debug "Android" "%SORTIE%"
if errorlevel 1 goto :echec
if not exist "%SORTIE%" goto :echec

echo.
echo ===== SUCCES : %SORTIE% =====
for %%F in ("%SORTIE%") do echo Taille : %%~zF octets
echo Copiez l'APK sur le telephone puis ouvrez-le (autoriser les sources inconnues),
echo ou branchez le telephone en debogage USB et lancez :
echo   "%ANDROID_HOME%\platform-tools\adb.exe" install -r "%SORTIE%"
endlocal
if "%~1"=="" pause
exit /b 0

:echec
echo.
echo ===== ECHEC de l'export Android (voir les messages ci-dessus) =====
endlocal
if "%~1"=="" pause
exit /b 1
