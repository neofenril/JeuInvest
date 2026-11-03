# Captures de l'interface pixel (lot PX2, docs/lots/lot_px2.md §5 et §6), dans godot\captures\ (préfixe px2_).
# Usage (depuis n'importe quel dossier) :
#   powershell -ExecutionPolicy Bypass -File godot\outils\capture_interface.ps1 -Etape cibles -Nom essai -Telephone
#   ... -Serie : toute la série PX2 (écrans de CA-I10 en PC 1920 × 1080 et au téléphone simulé, hud_720 / hud_1366 /
#       hud_1080 / hud_tel, planche_cadres sur 4 formats, cibles sur 3 formats, polices_jeu, courrier_relu_echap,
#       fps sur 2 formats, montages). Journal : godot\captures\px2_serie.log.
# Code 0 seulement si chaque lancement rend 0, sans erreur de script, et si tous les contrôles « UI » sont à
# zéro (irreguliers=0, sous_seuil=0, debordements=0, hors_cadre=0, hors_ecran=0, recouvert=non, recouvre=non,
# contenu_coupe=non, dans_ecran=oui, boutons_visibles=oui, chiffres_pixelify=0, atkinson_min ≥ 20, clic à
# côté conforme, au moins 55 images par seconde). Téléphones : -Telephone (1440 × 648 à 240 dpi) et
# -Telephone169 (1280 × 720 à 320 dpi). Les lignes « Images par seconde » et « Clic … » sont recopiées. 1920 × 1080 : plein écran (--fullscreen),
# pour avoir la vraie taille même avec la barre des tâches. user:// : la sauvegarde du joueur
# (partie_en_cours.sav) est contrôlée avant et après (empreinte), jamais effacée.
# Godot : voir trouver_godot.ps1 (variable JEUCLAUDE_GODOT, dépôt, ou dépôt principal depuis un worktree Git).
param(
    [string]$Etape = "",
    [string]$Nom = "capture",
    [string]$Taille = "1280x720",
    [switch]$Telephone,
    [switch]$Telephone169,
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
function Lancer([string]$etape, [string]$nom, [string]$taille, [string]$tel) {
    $a = @("--path", $projet, "--resolution", $taille)
    if ($taille -eq "1920x1080" -and $tel -eq "") { $a += "--fullscreen" }
    $a += @("--", "--capture=captures/$nom.png", "--frames=10", "--attente=0", "--etape=$etape")
    if ($tel -eq "1") { $a += "--telephone" }
    if ($tel -eq "169") { $a += "--telephone=169" }
    $sortie = & $godot @a 2>&1 | ForEach-Object { "$_" }
    $code = $LASTEXITCODE
    $erreurs = @($sortie | Where-Object { $_ -match 'SCRIPT ERROR|Parse Error|Failed to load script|Invalid call|Invalid access|Cannot call method' })
    $ui = @($sortie | Where-Object { $_ -match '^UI |^Images par seconde|^Clic ' } | ForEach-Object { if ($_ -match '^Clic ') { "UI clic_dehors $_" } else { $_ } })
    $fautes = @($ui | Where-Object { $_ -match 'irreguliers=[1-9]|sous_seuil=[1-9]|debordements=[1-9]|hors_cadre=[1-9]|hors_ecran=[1-9]|recouvert=oui|recouvre=oui|contenu_coupe=oui|dans_ecran=non|boutons_visibles=non|chiffres_pixelify=[1-9]|hud_focalisables=[1-9]|fermee=non|echap_ignore=non|atkinson=non|: False' })
    foreach ($l in ($ui | Where-Object { $_ -match 'atkinson_min=(\d+)' })) { if ([int]([regex]::Match($l, 'atkinson_min=(\d+)').Groups[1].Value) -lt 20) { $fautes += "atkinson_min < 20" } }
    foreach ($l in ($ui | Where-Object { $_ -match '^Images par seconde.*: ([\d.,]+)' })) { if ([double]([regex]::Match($l, ': ([\d.,]+)').Groups[1].Value.Replace(',','.')) -lt 55) { $fautes += "moins de 55 images par seconde" } }
    $pix = $ui | Where-Object { $_ -match 'pixelify_min=(\d+)' } | ForEach-Object { [int]([regex]::Match($_, 'pixelify_min=(\d+)').Groups[1].Value) }
    foreach ($p in $pix) { if ($p -lt 28) { $fautes += "pixelify_min=$p < 28" } }
    return [pscustomobject]@{ Nom = $nom; Etape = $etape; Code = $code; Erreurs = $erreurs; Fautes = $fautes; Lignes = $ui }
}

function Monter([string[]]$sources, [string]$sortie) {
    Add-Type -AssemblyName System.Drawing
    foreach ($s in $sources) { if (-not (Test-Path $s)) { return $false } }
    $imgs = @($sources | ForEach-Object { [System.Drawing.Image]::FromFile($_) })
    $l = ($imgs | Measure-Object -Property Width -Sum).Sum + 20 * ($imgs.Count - 1)
    $h = ($imgs | Measure-Object -Property Height -Maximum).Maximum
    $m = New-Object System.Drawing.Bitmap ([int]$l), ([int]$h)
    $g = [System.Drawing.Graphics]::FromImage($m)
    $g.Clear([System.Drawing.Color]::FromArgb(45, 40, 64))
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $x = 0
    foreach ($im in $imgs) { $g.DrawImage($im, $x, 0, $im.Width, $im.Height); $x += $im.Width + 20; $im.Dispose() }
    $m.Save($sortie, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $m.Dispose()
    return $true
}
if (-not $Serie) {
    $r = Lancer $Etape $Nom $Taille $(if ($Telephone169) { "169" } elseif ($Telephone) { "1" } else { "" })
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
# Formats : PC 1920 × 1080 (plein écran), téléphone simulé principal (1440 × 648) et 16:9 (1280 × 720)
foreach ($e in $ecrans) {
    $plan.Add(@($e, "px2_${e}_1080", "1920x1080", ""))
    $plan.Add(@($e, "px2_${e}_tel", "1440x648", "1"))
    $plan.Add(@($e, "px2_${e}_tel169", "1280x720", "169"))
}
foreach ($t in @(@("hud_720", "1280x720", ""), @("hud_1366", "1366x768", ""), @("hud_1080", "1920x1080", ""), @("hud_1009", "1920x1009", ""), @("hud_1152", "1152x648", ""), @("hud_tel", "1440x648", "1"), @("hud_tel169", "1280x720", "169"))) {
    $plan.Add(@("hud", ("px2_" + $t[0]), $t[1], $t[2]))
}
foreach ($t in @(@("720", "1280x720", ""), @("1366", "1366x768", ""), @("1080", "1920x1080", ""), @("tel", "1440x648", "1"), @("tel169", "1280x720", "169"))) {
    $plan.Add(@("planche_cadres", ("px2_planche_cadres_" + $t[0]), $t[1], $t[2]))
}
foreach ($t in @(@("720", "1280x720", ""), @("1366", "1366x768", ""), @("1009", "1920x1009", ""), @("tel", "1440x648", "1"), @("tel169", "1280x720", "169"))) {
    $plan.Add(@("cibles", ("px2_cibles_" + $t[0]), $t[1], $t[2]))
}
$plan.Add(@("polices_jeu", "px2_polices_jeu", "1920x1080", ""))
$plan.Add(@("courrier_relu_echap", "px2_courrier_relu_echap", "1280x720", ""))
$plan.Add(@("fps", "px2_fps_1080", "1920x1080", ""))
$plan.Add(@("fps", "px2_fps_tel", "1440x648", "1"))
$echecs = 0
$i = 0
foreach ($p in $plan) {
    $i++
    $r = Lancer $p[0] $p[1] $p[2] $p[3]
    $etat = if ($r.Code -eq 0 -and $r.Erreurs.Count -eq 0 -and $r.Fautes.Count -eq 0) { "OK" } else { "ÉCHEC"; $echecs++ }
    $ligne = "[{0}/{1}] {2} {3} ({4}{5}) code {6}" -f $i, $plan.Count, $etat, $r.Nom, $p[2], $(if ($p[3] -eq "1") { ", téléphone" } elseif ($p[3] -eq "169") { ", téléphone 16:9" } else { "" }), $r.Code
    Write-Host $ligne
    $ligne | Out-File $journal -Append -Encoding utf8
    foreach ($l in $r.Lignes) { "    $l" | Out-File $journal -Append -Encoding utf8 }
    foreach ($l in $r.Erreurs) { "    ERREUR $l" | Out-File $journal -Append -Encoding utf8; Write-Host "    ERREUR $l" }
    foreach ($l in $r.Fautes) { "    FAUTE $l" | Out-File $journal -Append -Encoding utf8; Write-Host "    FAUTE $l" }
}
# Montages : avant / après, et les téléphones (hud_tel | hud_tel169 | heritage_tel | banque_ordre_tel)
$v3 = Join-Path $captures "v3_rue.png"
$px0 = Join-Path $captures "px0_carte_1080.png"
foreach ($m in @(@(@($v3, (Join-Path $captures "px2_hud_1080.png")), "px2_montage_pc.png"), @(@($px0, (Join-Path $captures "px2_heritage_1080.png")), "px2_montage_carte.png"),
        @(@((Join-Path $captures "px2_hud_tel.png"), (Join-Path $captures "px2_hud_tel169.png"), (Join-Path $captures "px2_heritage_tel.png"), (Join-Path $captures "px2_banque_ordre_tel.png")), "px2_montage_telephones.png"))) {
    $ok = Monter $m[0] (Join-Path $captures $m[1])
    $t = if ($ok) { "montage $($m[1]) : écrit" } else { "montage $($m[1]) : source absente ($($m[0] -join ', ')) ; copier la capture de référence dans godot\captures\" }
    Write-Host $t; $t | Out-File $journal -Append -Encoding utf8
}$apres = Empreinte
$t = "user:// : sauvegarde du joueur {0} (avant {1}, après {2})" -f $(if ($avant -eq $apres) { "inchangée" } else { "MODIFIÉE" }), $avant.Substring(0, [Math]::Min(12, $avant.Length)), $apres.Substring(0, [Math]::Min(12, $apres.Length))
if ($avant -ne $apres) { $echecs++ }
Write-Host $t; $t | Out-File $journal -Append -Encoding utf8
$fin = "Série PX2 : {0} lancement(s), {1} échec(s), durée {2:N0} s" -f $plan.Count, $echecs, ((Get-Date) - $debut).TotalSeconds
Write-Host $fin; $fin | Out-File $journal -Append -Encoding utf8
if ($echecs -gt 0) { exit 1 }
exit 0
