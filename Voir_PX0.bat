@echo off
rem Preuve de concept pixel art (lot PX0) : ouvre la scene en plein ecran.
rem Touches : J jour / nuit, S humeur de Sylvie, C carte du banquier, P police des chiffres,
rem           F10 format telephone, H aide, Echap quitter.
rem Godot : variable JEUCLAUDE_GODOT si elle est definie, sinon outils\ de ce dossier.
rem Arguments en plus transmis a Godot (ex. : Voir_PX0.bat -- --px0-quitter-apres=5).
setlocal
set "GODOT=%JEUCLAUDE_GODOT%"
if "%GODOT%"=="" set "GODOT=%~dp0outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
if not exist "%GODOT%" (
    echo Godot est introuvable : "%GODOT%"
    echo Definir JEUCLAUDE_GODOT avec le chemin de Godot_v4.7.2-stable_win64_console.exe,
    echo ou placer Godot 4.7.2 dans outils\Godot_v4.7.2-stable_win64.exe\ a cote de ce fichier.
    pause
    exit /b 3
)
rem Version sans console a cote de la version console (sinon, la console sert aussi au jeu)
set "GODOT_JEU=%GODOT:_console.exe=.exe%"
if not exist "%GODOT_JEU%" set "GODOT_JEU=%GODOT%"
echo Preparation (import des polices et des scripts, quelques secondes)...
"%GODOT%" --headless --path "%~dp0godot" --import >nul 2>&1
"%GODOT_JEU%" --path "%~dp0godot" res://scenes/px0.tscn --fullscreen %*
exit /b %ERRORLEVEL%
