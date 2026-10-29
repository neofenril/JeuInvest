# Capture d'écran du jeu Godot, enregistrée en PNG dans godot\captures\.
# Usage (depuis n'importe quel dossier) :
#   powershell -ExecutionPolicy Bypass -File godot\outils\capture.ps1 -Etape krach -Nom krach_pc
#   ... -Telephone (format téléphone simulé, comme F10)  -Taille 1280x720  -Frames 10  -Attente 0.5
#   ... -Scene res://scenes/vide.tscn (une autre scène que la scène principale)
# Étapes de la scène principale (démo V2) : titre, titre_continuer, titre_confirmer, jouer,
#   sauver_fermer puis reprise (deux lancements : fermeture pendant une carte du banquier, puis « Continuer »),
#   presentation_livret, presentation_livret_plus, presentation_emprunt, presentation_sicav, presentation_av, heritage,
#   carnet, banque_ordre (avertissement F03), f01 (3 piles), releve, releve_notif,
#   rue, rue_nuit, foyer, marche_banque, pause, panneau, krach_anim, krach, courrier, news, fin, polices,
#   trafic (vitesse mesurée des voitures), clic_dehors (fermeture des pop-ups par un clic à côté),
#   integrale (60 mois à ×3, réponses automatiques par l'interface, environ 4 min),
#   comparaison / comparaison_info, crash_anim / crash_fin / crash_courrier, naissance_anim / naissance_pose / naissance,
#   jumeaux_anim / jumeaux_pose / jumeaux (touche F7), f10, fps,
#   historique, historique_filtre, historique_entree (carte D08 relue), historique_journal, historique_courrier,
#   carnet_pel (fiche du PEL), automatique (versement automatique sur la SICAV), automatique_pel.
# Si l'exécution de scripts est bloquée, lancer Godot directement :
#   & $godot --path godot --resolution 1280x720 -- --capture=captures/x.png --frames=10 --etape=crash_anim
param(
    [string]$Scene = "",
    [string]$Etape = "",
    [string]$Nom = "capture",
    [string]$Taille = "1280x720",
    [int]$Frames = 10,
    [double]$Attente = 0,
    [switch]$Telephone
)
$projet = Split-Path -Parent $PSScriptRoot
$racine = Split-Path -Parent $projet
$godot = Join-Path $racine "outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
$argsGodot = @("--path", $projet, "--resolution", $Taille)
if ($Scene -ne "") { $argsGodot += $Scene }
$argsGodot += @("--", "--capture=captures/$Nom.png", "--frames=$Frames", "--attente=$Attente")
if ($Etape -ne "") { $argsGodot += "--etape=$Etape" }
if ($Telephone) { $argsGodot += "--telephone" }
& $godot @argsGodot
exit $LASTEXITCODE
