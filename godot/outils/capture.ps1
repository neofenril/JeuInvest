# Capture d'écran du jeu Godot, enregistrée en PNG dans godot\captures\.
# Usage (depuis n'importe quel dossier) :
#   powershell -ExecutionPolicy Bypass -File godot\outils\capture.ps1 -Etape krach -Nom krach_pc
#   ... -Telephone (téléphone simulé 1440 × 648 à 240 dpi, comme F10)  -Telephone169 (1280 × 720 à 320 dpi)  -Taille 1280x720  -Frames 10  -Attente 0.5
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
#   carnet_pel (fiche du PEL), automatique (versement automatique sur la SICAV), automatique_pel,
#   courrier_relu_echap (T16 : fermeture d'un courrier pendant le vol de l'enveloppe, Échap sur un courrier relu),
#   PX2 (lignes « UI ») : planche_cadres (texels nets), cibles (cibles tactiles, débordements, Pixelify),
#   hud (bouton HISTORIQUE), polices_jeu (accents), etiquettes_bord / etiquettes_aller / etiquettes_banque / etiquettes_gazette,
#   raccourcis (F6-F10, triple toucher ; avec -Joueur : version du joueur, aucun raccourci de test),
#   lot 02 (bouton COURRIER) : courrier_repos, courrier_saut, courrier_saut_pause (saut lancé depuis la pause),
#   courrier_inactif (fenêtre ouverte), courrier_bulle (bulle de la 1re apparition), notifs_saut, badge_non_lus,
#   historique_nouveau, integrale_saut (toute la partie par le bouton COURRIER, environ 3 min).
#   Série complète : capture_interface.ps1 -Serie.
# -Joueur : ajoute « --joueur » (Reglages.raccourcis_test() faux, comme l'exe et l'APK).
# La partie des captures est sauvegardée dans user://capture_<pid>.sav (effacé à la sortie) ; sauver_fermer et
# reprise : user://capture_reprise_<empreinte du dossier du projet>.sav (un par worktree). Le nom est imprimé.
# Godot : voir trouver_godot.ps1 (variable JEUCLAUDE_GODOT, dépôt, ou dépôt principal depuis un worktree Git).
# Si l'exécution de scripts est bloquée, lancer Godot directement :
#   & $godot --path godot --resolution 1280x720 -- --capture=captures/x.png --frames=10 --etape=crash_anim
param(
    [string]$Scene = "",
    [string]$Etape = "",
    [string]$Nom = "capture",
    [string]$Taille = "1280x720",
    [int]$Frames = 10,
    [double]$Attente = 0,
    [switch]$Telephone,
    [switch]$Telephone169,
    [switch]$Joueur
)
. (Join-Path $PSScriptRoot "trouver_godot.ps1")   # $godot, $projet (variable JEUCLAUDE_GODOT, dépôt ou worktree)
if (-not $godot) { exit 3 }
Write-Host "Godot : $godot ($godotSource)"
$argsGodot = @("--path", $projet, "--resolution", $Taille)
if ($Scene -ne "") { $argsGodot += $Scene }
$argsGodot += @("--", "--capture=captures/$Nom.png", "--frames=$Frames", "--attente=$Attente")
if ($Etape -ne "") { $argsGodot += "--etape=$Etape" }
if ($Telephone) { $argsGodot += "--telephone" }
if ($Telephone169) { $argsGodot += "--telephone=169" }
if ($Joueur) { $argsGodot += "--joueur" }
& $godot @argsGodot
exit $LASTEXITCODE
