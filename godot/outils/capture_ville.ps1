# Captures de la rue pixel du jeu (lot PX1, docs/lots/lot_px1.md §5 et §6), dans godot\captures\.
# Usage (depuis n'importe quel dossier) :
#   powershell -File godot\outils\capture_ville.ps1 -Etape rue -Nom px1_rue -Taille 1920x1080 -Controle -SansHud
#   ... -Telephone (téléphone simulé, fenêtre 1600 x 720, facteur 1,7)  -Facteur 4  -Attente 1.5  -Passer 0.3
#   ... -Montages : refait seulement les trois montages (captures déjà faites)
#   ... -Montages : refait seulement les trois montages (captures déjà faites)
#   ... -Serie : toute la série PX1 (préfixe px1_), ses trois montages et le journal godot\captures\px1_serie.log
# Étapes : celles de la scène principale (capture.ps1) ; famille « ville » : rue, rue_nuit, rue_banque, rue_gazette,
#   rue_libre, defilement, saison_hiver, saison_automne, saison_printemps, pluie, banquier_anim, banquier_signal,
#   journal_anim, krach_anim, crash_anim, crash_fin, naissance_anim, jumeaux_anim, news, sylvie_0..2,
#   planche_personnages, voisins, trafic, fps.
# 1920 x 1080 : plein écran (taille exacte). Journal de Godot hors de user:// (--log-file).
# Code de sortie 0 seulement si chaque lancement rend 0, sans erreur de script, et si tous les contrôles sont à
# zéro (hors_palette=0, irreguliers=0). 3 : Godot introuvable.
param(
    [string]$Etape = "rue",
    [string]$Nom = "px1",
    [string]$Taille = "1920x1080",
    [switch]$Telephone,
    [int]$Facteur = 0,
    [switch]$SansHud,
    [switch]$Controle,
    [double]$Attente = 0,
    [double]$Passer = 0,
    [switch]$Serie,
    [switch]$Montages
)
$ErrorActionPreference = "Continue"
$projet = Split-Path -Parent $PSScriptRoot
$captures = Join-Path $projet "captures"
New-Item -ItemType Directory -Force $captures | Out-Null
$exe = & { . (Join-Path $PSScriptRoot "trouver_godot.ps1"); $godot }
if (-not $exe) { Write-Host "Godot introuvable (JEUCLAUDE_GODOT, outils\ du dépôt ou du dépôt principal)."; exit 3 }
$depot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $exe))

$motifsErreur = @("SCRIPT ERROR", "Parse Error", "Failed to load", "Invalid call", "Invalid access", "Cannot call method",
    "PalettePixel : couleur inconnue", "GrillePixel : image inconnue")
$journal = $null
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("px1_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force $tmp | Out-Null
$script:resumes = @()

function Ecrire([string]$texte) {
    Write-Host $texte
    if ($script:journal) { Add-Content -LiteralPath $script:journal -Value $texte -Encoding UTF8 }
}

function Lancer([string[]]$arguments) {
    $out = Join-Path $tmp "out.txt"; $err = Join-Path $tmp "err.txt"
    $liste = ($arguments | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join " "
    $p = Start-Process -FilePath $exe -ArgumentList $liste -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
    $lignes = @()
    if (Test-Path $out) { $lignes += Get-Content -LiteralPath $out -Encoding UTF8 }
    if (Test-Path $err) { $lignes += Get-Content -LiteralPath $err -Encoding UTF8 }
    return @{ code = $p.ExitCode; sortie = $lignes }
}

function Capturer([hashtable]$o) {
    $taille = $(if ($o.Taille) { $o.Taille } else { "1920x1080" })
    $a = @("--log-file", (Join-Path $tmp "godot.log"), "--path", $projet, "--resolution", $taille)
    if ($taille -eq "1920x1080" -and -not $o.Telephone) { $a += "--fullscreen" }
    $att = [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0}', $o.Attente)
    $a += @("--", "--capture=captures/$($o.Nom).png", "--frames=10", "--attente=$att", "--etape=$($o.Etape)")
    if ($o.Telephone) { $a += "--telephone" }
    if ($o.Facteur -gt 0) { $a += "--rue-facteur=$($o.Facteur)" }
    if ($o.SansHud) { $a += "--rue-sans-hud" }
    if ($o.Controle) { $a += "--controle" }
    if ($o.Passer -gt 0) { $a += ("--rue-passer=" + [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0}', $o.Passer)) }
    $r = Lancer $a
    $rue = @($r.sortie | Where-Object { $_ -like "RUE *" -or $_ -like "Images par seconde*" -or $_ -like "Capture enregistr*" })
    $erreurs = @($r.sortie | Where-Object { $l = $_; $motifsErreur | Where-Object { $l -like "*$_*" } })
    $ko = @($rue | Where-Object { ($_ -match 'hors_palette=(\d+)' -and [int]$matches[1] -ne 0) -or ($_ -match 'irreguliers=(\d+)' -and [int]$matches[1] -ne 0) })
    $ok = ($r.code -eq 0) -and ($erreurs.Count -eq 0) -and ($ko.Count -eq 0)
    Ecrire ("--- {0} ({1}, {2}{3}) : code {4}{5}" -f $o.Nom, $o.Etape, $(if ($o.Telephone) { "téléphone" } else { $taille }), $(if ($o.Facteur) { " x$($o.Facteur)" } else { "" }), $r.code, $(if ($ok) { "" } else { "  ** ECHEC **" }))
    foreach ($l in $r.sortie) {
        if ($l -like "RUE *" -or $l -like "Images par seconde*" -or $l -like "Trafic*" -or ($motifsErreur | Where-Object { $l -like "*$_*" }) -or $l -like "ERROR*" -or $l -like "*at: *") { Ecrire "    $l" }
    }
    $script:resumes += ("{0,-28} {1}" -f $o.Nom, $(if ($ok) { "OK" } else { "ECHEC" }))
    return $ok
}

function Monter([string[]]$images, [string]$sortie) {
    # Montage côte à côte, à la hauteur de la dernière image (bicubique pour une photo, plus proche voisin sinon)
    foreach ($i in $images) { if (-not (Test-Path -LiteralPath $i)) { Ecrire "    montage non produit (image absente) : $i"; return $false } }
    Add-Type -AssemblyName System.Drawing
    $imgs = @($images | ForEach-Object { [Drawing.Image]::FromFile($_) })
    $h = $imgs[$imgs.Count - 1].Height
    $largeurs = @($imgs | ForEach-Object { [int][math]::Round($_.Width * $h / $_.Height) })
    $total = [int](($largeurs | Measure-Object -Sum).Sum + 16 * ($imgs.Count - 1))
    $h = [int]$h
    $m = New-Object Drawing.Bitmap $total, $h
    $gr = [Drawing.Graphics]::FromImage($m)
    $gr.Clear([Drawing.Color]::FromArgb(0x1C, 0x16, 0x26))
    $gr.PixelOffsetMode = 'Half'
    $x = 0
    for ($k = 0; $k -lt $imgs.Count; $k++) {
        $gr.InterpolationMode = $(if ($images[$k] -like "*.jpg" -or $imgs[$k].Height -ne $h) { 'HighQualityBicubic' } else { 'NearestNeighbor' })
        $gr.DrawImage($imgs[$k], (New-Object Drawing.Rectangle $x, 0, $largeurs[$k], $h))
        $x += $largeurs[$k] + 16
    }
    try { $m.Save($sortie, [Drawing.Imaging.ImageFormat]::Png) } catch { Ecrire "    montage impossible : $sortie"; return $false }
    $gr.Dispose(); $m.Dispose(); $imgs | ForEach-Object { $_.Dispose() }
    Ecrire ("montage : {0} ({1}x{2})" -f (Split-Path -Leaf $sortie), $total, $h)
    return $true
}

function Faire-Montages {
    # Montages : référence | rue_1080, PX0 quater | rue_1080, rue_720 | rue_tel | rue_1080
    $p = "px1_"
    $ref = Join-Path $depot "docs\sources\graphisme\references\rue_pixel_v2.jpg"
    $rue = Join-Path $captures "${p}rue_1080.png"
    $px0 = Join-Path $captures "px0_quater_jour_1080.png"
    if (-not (Test-Path -LiteralPath $px0)) { $px0 = Join-Path $depot "godot\captures\px0_quater_jour_1080.png" }
    $ok = Monter @($ref, $rue) (Join-Path $captures "${p}montage_ref.png")
    $ok = (Monter @($px0, $rue) (Join-Path $captures "${p}montage_px0.png")) -and $ok
    $ok = (Monter @((Join-Path $captures "${p}rue_720.png"), (Join-Path $captures "${p}rue_tel.png"), $rue) (Join-Path $captures "${p}montage_formats.png")) -and $ok
    return $ok
}

$debut = Get-Date
$imp = Lancer @("--headless", "--log-file", (Join-Path $tmp "import.log"), "--path", $projet, "--import")
$errImp = @($imp.sortie | Where-Object { $l = $_; $motifsErreur | Where-Object { $l -like "*$_*" } })
$toutOk = ($imp.code -eq 0) -and ($errImp.Count -eq 0)

if ($Serie) {
    $script:journal = Join-Path $captures "px1_serie.log"
    Set-Content -LiteralPath $script:journal -Value ("Série PX1 du {0:yyyy-MM-dd HH:mm:ss}, Godot : {1}" -f $debut, $exe) -Encoding UTF8
    Ecrire ("import : code {0}{1}" -f $imp.code, $(if ($errImp.Count) { " ; " + ($errImp -join " / ") } else { "" }))
    $p = "px1_"
    $liste = @(
        @{ Nom = "${p}rue_1080"; Etape = "rue"; Controle = $true },
        @{ Nom = "${p}rue_720"; Etape = "rue"; Taille = "1280x720"; Controle = $true },
        @{ Nom = "${p}rue_1366"; Etape = "rue"; Taille = "1366x768"; Controle = $true },
        @{ Nom = "${p}rue_tel"; Etape = "rue"; Telephone = $true; Controle = $true },
        @{ Nom = "${p}rue_nuit"; Etape = "rue_nuit"; Controle = $true; SansHud = $true },
        @{ Nom = "${p}rue_banque"; Etape = "rue_banque"; Controle = $true },
        @{ Nom = "${p}rue_gazette"; Etape = "rue_gazette"; Controle = $true },
        @{ Nom = "${p}rue_banque_720"; Etape = "rue_banque"; Taille = "1280x720"; Controle = $true },
        @{ Nom = "${p}rue_gazette_720"; Etape = "rue_gazette"; Taille = "1280x720"; Controle = $true },
        @{ Nom = "${p}rue_banque_1366"; Etape = "rue_banque"; Taille = "1366x768"; Controle = $true },
        @{ Nom = "${p}rue_gazette_1366"; Etape = "rue_gazette"; Taille = "1366x768"; Controle = $true },
        @{ Nom = "${p}rue_banque_tel"; Etape = "rue_banque"; Telephone = $true; Controle = $true },
        @{ Nom = "${p}rue_gazette_tel"; Etape = "rue_gazette"; Telephone = $true; Controle = $true },
        @{ Nom = "${p}rue_libre_1080"; Etape = "rue_libre"; Controle = $true },
        @{ Nom = "${p}rue_libre_720"; Etape = "rue_libre"; Taille = "1280x720"; Controle = $true },
        @{ Nom = "${p}rue_libre_1366"; Etape = "rue_libre"; Taille = "1366x768"; Controle = $true },
        @{ Nom = "${p}rue_libre_tel"; Etape = "rue_libre"; Telephone = $true; Controle = $true },
        @{ Nom = "${p}rue_libre_x4"; Etape = "rue_libre"; Facteur = 4; Controle = $true },
        @{ Nom = "${p}defilement"; Etape = "defilement"; Controle = $true },
        @{ Nom = "${p}saison_hiver"; Etape = "saison_hiver"; Controle = $true },
        @{ Nom = "${p}saison_automne"; Etape = "saison_automne"; Controle = $true },
        @{ Nom = "${p}saison_printemps"; Etape = "saison_printemps"; Controle = $true },
        @{ Nom = "${p}pluie"; Etape = "pluie"; Controle = $true },
        @{ Nom = "${p}pause"; Etape = "pause" },
        @{ Nom = "${p}titre"; Etape = "titre" },
        @{ Nom = "${p}jouer"; Etape = "jouer" },
        @{ Nom = "${p}banquier_anim"; Etape = "banquier_anim"; Controle = $true },
        @{ Nom = "${p}banquier_signal"; Etape = "banquier_signal"; Controle = $true },
        @{ Nom = "${p}banquier"; Etape = "presentation_emprunt"; Controle = $true },
        @{ Nom = "${p}journal_anim"; Etape = "journal_anim"; Controle = $true },
        @{ Nom = "${p}krach_anim"; Etape = "krach_anim"; Controle = $true; SansHud = $true },
        @{ Nom = "${p}krach_anim_hud"; Etape = "krach_anim"; Controle = $true },
        @{ Nom = "${p}courrier"; Etape = "courrier"; Controle = $true },
        @{ Nom = "${p}crash_anim"; Etape = "crash_anim"; Controle = $true },
        @{ Nom = "${p}crash_fin"; Etape = "crash_fin"; Controle = $true },
        @{ Nom = "${p}naissance_anim"; Etape = "naissance_anim"; Controle = $true },
        @{ Nom = "${p}jumeaux_anim"; Etape = "jumeaux_anim"; Controle = $true },
        @{ Nom = "${p}news"; Etape = "news"; Controle = $true },
        @{ Nom = "${p}passe_banquier"; Etape = "banquier_anim"; Controle = $true; Passer = 0.3; Attente = 0.6 },
        @{ Nom = "${p}passe_krach"; Etape = "krach_anim"; Controle = $true; Passer = 0.3; Attente = 0.6 },
        @{ Nom = "${p}passe_crash"; Etape = "crash_anim"; Controle = $true; Passer = 0.3; Attente = 0.6 },
        @{ Nom = "${p}passe_naissance"; Etape = "naissance_anim"; Controle = $true; Passer = 0.3; Attente = 0.6 },
        @{ Nom = "${p}sylvie_0"; Etape = "sylvie_0"; Controle = $true },
        @{ Nom = "${p}sylvie_1"; Etape = "sylvie_1"; Controle = $true },
        @{ Nom = "${p}sylvie_2"; Etape = "sylvie_2"; Controle = $true },
        @{ Nom = "${p}planche_personnages"; Etape = "planche_personnages"; Controle = $true },
        @{ Nom = "${p}voisins"; Etape = "voisins"; Controle = $true },
        @{ Nom = "${p}trafic"; Etape = "trafic"; Controle = $true },
        @{ Nom = "${p}fps"; Etape = "fps"; Controle = $true },
        @{ Nom = "${p}fps_tel"; Etape = "fps"; Telephone = $true; Controle = $true }
    )
    foreach ($o in $liste) {
        if (-not $o.ContainsKey("Attente")) { $o.Attente = 0 }
        if (-not (Capturer $o)) { $toutOk = $false }
    }
    $ref = Join-Path $depot "docs\sources\graphisme\references\rue_pixel_v2.jpg"
    $rue = Join-Path $captures "${p}rue_1080.png"
    $px0 = Join-Path $captures "px0_quater_jour_1080.png"
    if (-not (Test-Path -LiteralPath $px0)) { $px0 = Join-Path $depot "godot\captures\px0_quater_jour_1080.png" }
    if (-not (Faire-Montages)) { $toutOk = $false }
} elseif ($Montages) {
    $script:journal = Join-Path $captures "px1_serie.log"
    if (-not (Faire-Montages)) { $toutOk = $false }
} else {
    if ($errImp.Count) { Write-Host ("import : " + ($errImp -join " / ")) }
    $o = @{ Nom = $Nom; Etape = $Etape; Taille = $Taille; Telephone = [bool]$Telephone; Facteur = $Facteur; SansHud = [bool]$SansHud;
            Controle = [bool]$Controle; Attente = $Attente; Passer = $Passer }
    if (-not (Capturer $o)) { $toutOk = $false }
}

Ecrire ""
Ecrire ("Résumé ({0:N0} s) :" -f ((Get-Date) - $debut).TotalSeconds)
foreach ($r in $script:resumes) { Ecrire "  $r" }
Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
if ($toutOk) { Ecrire "PX1 : tout est vert"; exit 0 }
Ecrire "PX1 : au moins un échec (voir ci-dessus)"
exit 1