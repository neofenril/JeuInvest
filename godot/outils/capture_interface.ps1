# Captures de l'interface pixel (lot PX2, docs/lots/lot_px2.md §5 et §6), dans godot\captures\ (préfixe px2_).
# Usage (depuis n'importe quel dossier) :
#   powershell -ExecutionPolicy Bypass -File godot\outils\capture_interface.ps1 -Etape cibles -Nom essai -Telephone
#   ... -Serie : toute la série PX2 (écrans de CA-I10 en PC 1920 × 1080 et au téléphone simulé, hud_720 / hud_1366 /
#       hud_1080 / hud_tel, planche_cadres sur 4 formats, cibles sur 3 formats, polices_jeu, courrier_relu_echap,
#       fps sur 2 formats, montages). Journal : godot\captures\px2_serie.log.
# Code 0 seulement si chaque lancement rend 0, sans erreur de script, et si tous les contrôles « UI » sont à
# zéro (irreguliers=0, sous_seuil=0, debordements=0, recouvert=non). 1920 × 1080 : plein écran (--fullscreen),
# pour avoir la vraie taille même avec la barre des tâches. user:// : la sauvegarde du joueur
# (partie_en_cours.sav) est contrôlée avant et après (empreinte), jamais effacée.
# Godot : voir trouver_godot.ps1 (variable JEUCLAUDE_GODOT, dépôt, ou dépôt principal depuis un worktree Git).
param(
    [string]$Etape = "",
    [string]$Nom = "capture",
    [string]$Taille = "1280x720",
    [switch]$Telephone,
    [switch]$Serie
)
. (Join-Path $PSScriptRoot "trouver_godot.ps1")   # $godot, $projet
if (-not $godot) { exit 3 }
$captures = Join-Path $projet "captures"
New-Item -ItemType Directory -Force $captures | Out-Null
$journal = Join-Path $captures "px2_serie.log"
$sauvegarde = Join-Path $env:APPDATA "Godot\app_userdata\JeuClaude\partie_en_cours.sav"

function Empreinte {
    if (Test-Path $sauvegarde) { return (Get-FileHash $sauvegarde -Algorithm SHA256).Hash }
    return "absente"
}

# Un lancement : renvoie un objet { Nom, Code, Erreurs, Fautes, Lignes }
function Lancer([string]$etape, [string]$nom, [string]$taille, [bool]$tel) {
    $a = @("--path", $projet, "--resolution", $taille)
    if ($taille -eq "1920x1080" -and -not $tel) { $a += "--fullscreen" }
    $a += @("--", "--capture=captures/$nom.png", "--frames=10", "--attente=0", "--etape=$etape")
    if ($tel) { $a += "--telephone" }
    $sortie = & $godot @a 2>&1 | ForEach-Object { "$_" }
    $code = $LASTEXITCODE
    $erreurs = @($sortie | Where-Object { $_ -match 'SCRIPT ERROR|Parse Error|Failed to load script|Invalid call|Invalid access|Cannot call method' })
    $ui = @($sortie | Where-Object { $_ -match '^UI ' })
    $fautes = @($ui | Where-Object { $_ -match 'irreguliers=[1-9]|sous_seuil=[1-9]|debordements=[1-9]|recouvert=oui|fermee=non|echap_ignore=non|atkinson=non' })
    $pix = $ui | Where-Object { $_ -match 'pixelify_min=(\d+)' } | ForEach-Object { [int]([regex]::Match($_, 'pixelify_min=(\d+)').Groups[1].Value) }
    foreach ($p in $pix) { if ($p -lt 28) { $fautes += "pixelify_min=$p < 28" } }
    return [pscustomobject]@{ Nom = $nom; Etape = $etape; Code = $code; Erreurs = $erreurs; Fautes = $fautes; Lignes = $ui }
}

function Monter([string]$gauche, [string]$droite, [string]$sortie) {
    Add-Type -AssemblyName System.Drawing
    if (-not (Test-Path $gauche) -or -not (Test-Path $droite)) { return $false }
    $a = [System.Drawing.Image]::FromFile($gauche); $b = [System.Drawing.Image]::FromFile($droite)
    $h = [Math]::Max($a.Height, $b.Height)
    $m = New-Object System.Drawing.Bitmap ($a.Width + $b.Width + 20), $h
    $g = [System.Drawing.Graphics]::FromImage($m)
    $g.Clear([System.Drawing.Color]::FromArgb(45, 40, 64))
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g.DrawImage($a, 0, 0, $a.Width, $a.Height); $g.DrawImage($b, $a.Width + 20, 0, $b.Width, $b.Height)
    $m.Save($sortie, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $m.Dispose(); $a.Dispose(); $b.Dispose()
    return $true
}

if (-not $Serie) {
    $r = Lancer $Etape $Nom $Taille $Telephone.IsPresent
    $r.Lignes | ForEach-Object { Write-Host $_ }
    $r.Erreurs | ForEach-Object { Write-Host "ERREUR : $_" }
    if ($r.Code -ne 0 -or $r.Erreurs.Count -gt 0 -or $r.Fautes.Count -gt 0) { exit 1 }
    exit 0
}

# ===== Série PX2 =====
$debut = Get-Date
$avant = Empreinte
"Série PX2 du $debut (Godot : $godot)" | Out-File $journal -Encoding utf8
$ecrans = @("titre", "titre_confirmer", "jouer", "pause", "panneau", "presentation_livret", "presentation_av", "heritage", "krach",
    "courrier", "releve", "f01", "fin", "historique", "historique_filtre", "historique_entree", "carnet", "carnet_pel", "banque_ordre",
    "automatique", "foyer", "comparaison_info", "clic_dehors")
$plan = New-Object System.Collections.Generic.List[object]
foreach ($e in $ecrans) {
    $plan.Add(@($e, "px2_${e}_1080", "1920x1080", $false))
    $plan.Add(@($e, "px2_${e}_tel", "1600x720", $true))
}
foreach ($t in @(@("hud_720", "1280x720", $false), @("hud_1366", "1366x768", $false), @("hud_1080", "1920x1080", $false), @("hud_tel", "1600x720", $true))) {
    $plan.Add(@("hud", "px2_" + $t[0], $t[1], $t[2]))
}
foreach ($t in @(@("720", "1280x720", $false), @("1366", "1366x768", $false), @("1080", "1920x1080", $false), @("tel", "1600x720", $true))) {
    $plan.Add(@("planche_cadres", "px2_planche_cadres_" + $t[0], $t[1], $t[2]))
}
foreach ($t in @(@("720", "1280x720", $false), @("1366", "1366x768", $false), @("tel", "1600x720", $true))) {
    $plan.Add(@("cibles", "px2_cibles_" + $t[0], $t[1], $t[2]))
}
$plan.Add(@("polices_jeu", "px2_polices_jeu", "1920x1080", $false))
$plan.Add(@("courrier_relu_echap", "px2_courrier_relu_echap", "1280x720", $false))
$plan.Add(@("fps", "px2_fps_1080", "1920x1080", $false))
$plan.Add(@("fps", "px2_fps_tel", "1600x720", $true))

$echecs = 0
$i = 0
foreach ($p in $plan) {
    $i++
    $r = Lancer $p[0] $p[1] $p[2] $p[3]
    $etat = if ($r.Code -eq 0 -and $r.Erreurs.Count -eq 0 -and $r.Fautes.Count -eq 0) { "OK" } else { "ÉCHEC"; $echecs++ }
    $ligne = "[{0}/{1}] {2} {3} ({4}{5}) code {6}" -f $i, $plan.Count, $etat, $r.Nom, $p[2], $(if ($p[3]) { ", téléphone" } else { "" }), $r.Code
    Write-Host $ligne
    $ligne | Out-File $journal -Append -Encoding utf8
    foreach ($l in $r.Lignes) { "    $l" | Out-File $journal -Append -Encoding utf8 }
    foreach ($l in $r.Erreurs) { "    ERREUR $l" | Out-File $journal -Append -Encoding utf8; Write-Host "    ERREUR $l" }
    foreach ($l in $r.Fautes) { "    FAUTE $l" | Out-File $journal -Append -Encoding utf8; Write-Host "    FAUTE $l" }
}
# Montages : avant / après
$v3 = Join-Path $captures "v3_rue.png"
$px0 = Join-Path $captures "px0_carte_1080.png"
foreach ($m in @(@($v3, (Join-Path $captures "px2_hud_1080.png"), "px2_montage_pc.png"), @($px0, (Join-Path $captures "px2_heritage_1080.png"), "px2_montage_carte.png"))) {
    $ok = Monter $m[0] $m[1] (Join-Path $captures $m[2])
    $t = if ($ok) { "montage $($m[2]) : écrit" } else { "montage $($m[2]) : source absente ($($m[0])), copier la capture de référence dans godot\captures\" }
    Write-Host $t; $t | Out-File $journal -Append -Encoding utf8
}
$apres = Empreinte
$t = "user:// : sauvegarde du joueur {0} (avant {1}, après {2})" -f $(if ($avant -eq $apres) { "inchangée" } else { "MODIFIÉE" }), $avant.Substring(0, [Math]::Min(12, $avant.Length)), $apres.Substring(0, [Math]::Min(12, $apres.Length))
if ($avant -ne $apres) { $echecs++ }
Write-Host $t; $t | Out-File $journal -Append -Encoding utf8
$fin = "Série PX2 : {0} lancement(s), {1} échec(s), durée {2:N0} s" -f $plan.Count, $echecs, ((Get-Date) - $debut).TotalSeconds
Write-Host $fin; $fin | Out-File $journal -Append -Encoding utf8
if ($echecs -gt 0) { exit 1 }
exit 0
