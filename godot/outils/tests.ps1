# Lance les tests headless de la logique. Code de sortie 0 si tout passe.
# Usage : powershell -ExecutionPolicy Bypass -File godot\outils\tests.ps1
$projet = Split-Path -Parent $PSScriptRoot
$racine = Split-Path -Parent $projet
$godot = Join-Path $racine "outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
if (-not (Test-Path (Join-Path $projet ".godot\global_script_class_cache.cfg"))) {
    & $godot --headless --path $projet --import | Out-Null   # premier lancement : enregistre les classes globales
}
& $godot --headless --path $projet --script res://tests/test_logique.gd
$code1 = $LASTEXITCODE
& $godot --headless --path $projet --script res://tests/test_demo.gd     # démo V2 : banquier, produits, frais, sauvegarde
$code3 = $LASTEXITCODE
& $godot --headless --path $projet res://tests/test_partie.tscn   # autoload Partie (environ 4 s)
$code2 = $LASTEXITCODE
if ($code1 -ne 0 -or $code2 -ne 0 -or $code3 -ne 0) { exit 1 }
exit 0
