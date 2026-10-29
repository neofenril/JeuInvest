@echo off
rem Lance JeuClaude (version Godot) sans installation, hors ligne.
rem Godot : variable JEUCLAUDE_GODOT si elle est definie (chemin de la version console : la version
rem sans console du meme dossier est utilisee si elle existe), sinon outils\ du depot.
setlocal
set "GODOT_FENETRE=%~dp0outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
if defined JEUCLAUDE_GODOT set "GODOT_FENETRE=%JEUCLAUDE_GODOT%"
if defined JEUCLAUDE_GODOT if exist "%JEUCLAUDE_GODOT:_console.exe=.exe%" set "GODOT_FENETRE=%JEUCLAUDE_GODOT:_console.exe=.exe%"
start "" "%GODOT_FENETRE%" --path "%~dp0godot"
endlocal
