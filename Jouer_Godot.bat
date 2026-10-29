@echo off
rem Lance JeuClaude (version Godot) sans installation, hors ligne.
rem Godot : variable JEUCLAUDE_GODOT si elle est definie (chemin de la version console : la version
rem sans console du meme dossier est utilisee si elle existe), sinon outils\ du depot.
setlocal
set "GODOT_FENETRE=%~dp0outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
rem Saut obligatoire : une substitution dans une variable absente est developpee avant le test du if.
if not defined JEUCLAUDE_GODOT goto lancer
set "GODOT_FENETRE=%JEUCLAUDE_GODOT%"
set "CANDIDAT=%JEUCLAUDE_GODOT:_console.exe=.exe%"
if exist "%CANDIDAT%" set "GODOT_FENETRE=%CANDIDAT%"
:lancer
start "" "%GODOT_FENETRE%" --path "%~dp0godot"
endlocal
