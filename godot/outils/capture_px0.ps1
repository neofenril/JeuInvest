# Captures de la preuve de concept pixel (lot PX0, docs/lots/lot_px0.md §2.6 et §5), dans godot\captures\.
# Usage (depuis n'importe quel dossier) :
#   powershell -File godot\outils\capture_px0.ps1 -Etape jour -Nom px0_a -Taille 1920x1080 -Controle -SansInterface
#   ... -Telephone (facteur 1,7 ; fenêtre 1600 x 720 sans -Taille)  -Facteur 4  -Libre  -Fps  -Attente 1.5
#   ... -Montage <png de référence>  -Godot <chemin de Godot console>
#   ... -Serie : toute la série PX0 ter (docs/lots/lot_px0_bis.md §7, préfixe px0_ter_ depuis PX0 ter), ses montages et le
#       journal godot\captures\px0_ter_serie.log
#   ... -Reference <image> : montage côté à côte (référence à gauche, à la hauteur de la capture) ; par défaut,
#       avec -Serie : docs\sources\graphisme\references\rue_pixel_v2.jpg du dépôt principal
# Étapes : jour, nuit, sylvie_0, sylvie_1, sylvie_2, planche (ville) ; carte, carte_fermee, jersey, polices
# (interface : sans elle, la rue est capturée seule et le journal le signale).
# Code de sortie 0 seulement si chaque lancement rend 0, sans erreur de script, et si tous les contrôles
# sont à zéro (hors_palette=0, irreguliers=0). 3 : Godot introuvable.
# Si l'exécution de scripts est bloquée, lancer Godot directement :
#   & $godot --path godot res://scenes/px0.tscn -- --px0-taille=1920x1080 --px0-controle --px0-capture=captures/x.png
param(
    [string]$Etape = "jour",
    [string]$Nom = "px0",
    [string]$Taille = "",
    [switch]$Telephone,
    [int]$Facteur = 0,
    [switch]$SansInterface,
    [switch]$Libre,
    [switch]$Controle,
    [switch]$Fps,
    [double]$Attente = 0,
    [string]$Montage = "",
    [string]$Godot = "",
    [switch]$Serie,
    [string]$Reference = ""
)
$ErrorActionPreference = "Continue"
$projet = Split-Path -Parent $PSScriptRoot
$racine = Split-Path -Parent $projet
$captures = Join-Path $projet "captures"
New-Item -ItemType Directory -Force $captures | Out-Null

# --- Godot : -Godot, sinon trouver_godot.ps1 (JEUCLAUDE_GODOT, dépôt, dépôt principal d'un worktree) -----------------------------------
$exe = $null
if ($Godot -and (Test-Path -LiteralPath $Godot -PathType Leaf)) {
    $exe = (Resolve-Path -LiteralPath $Godot).Path
} else {
    # Même recherche que tests.ps1 : JEUCLAUDE_GODOT, dépôt, dépôt principal d'un worktree
    # ($Godot, paramètre typé [string], masquerait la variable $godot de trouver_godot.ps1 : on le retire)
    Remove-Variable -Name Godot -Scope Script -ErrorAction SilentlyContinue
    # (bloc à part : le paramètre $Godot, typé [string], masquerait la variable $godot du script inclus)
    $exe = & { . (Join-Path $PSScriptRoot "trouver_godot.ps1"); $godot }
}
if (-not $exe) {
    Write-Host "Godot introuvable. Donner -Godot <chemin de Godot_v4.7.2-stable_win64_console.exe> ou définir JEUCLAUDE_GODOT."
    exit 3
}
# Dépôt principal = dossier parent de outils\ dans le chemin de Godot (références v3_rue*.png)
$depot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $exe))
$refs = Join-Path $depot "godot\captures"

$motifsErreur = @("SCRIPT ERROR", "Parse Error", "Failed to load", "Invalid call", "Invalid access", "Cannot call method",
    "PalettePixel : couleur inconnue", "GrillePixel : image inconnue")
$journal = $null
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("px0_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force $tmp | Out-Null

function Ecrire([string]$texte) {
    Write-Host $texte
    if ($script:journal) { Add-Content -LiteralPath $script:journal -Value $texte -Encoding UTF8 }
}

function Lancer([string[]]$arguments) {
    # Lance Godot, renvoie @{ code; sortie (lignes stdout + stderr) }
    $out = Join-Path $tmp "out.txt"; $err = Join-Path $tmp "err.txt"
    $liste = ($arguments | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join " "
    $p = Start-Process -FilePath $exe -ArgumentList $liste -NoNewWindow -Wait -PassThru `
        -RedirectStandardOutput $out -RedirectStandardError $err
    $lignes = @()
    if (Test-Path $out) { $lignes += Get-Content -LiteralPath $out -Encoding UTF8 }
    if (Test-Path $err) { $lignes += Get-Content -LiteralPath $err -Encoding UTF8 }
    return @{ code = $p.ExitCode; sortie = $lignes }
}

function Capturer([hashtable]$o) {
    # o : Nom, Etape, Taille, Telephone, Facteur, SansInterface, Libre, Controle, Fps, Attente, Montage
    # Journal de Godot hors de user:// (sinon user://logs change à chaque lancement : CA-V11)
    $a = @("--log-file", (Join-Path $tmp "godot.log"), "--path", $projet, "res://scenes/px0.tscn", "--","--px0-etape=$($o.Etape)", "--px0-capture=captures/$($o.Nom).png")
    if ($o.Taille) { $a += "--px0-taille=$($o.Taille)" }
    if ($o.Telephone) { $a += "--px0-telephone" }
    if ($o.Facteur -gt 0) { $a += "--px0-facteur=$($o.Facteur)" }
    if ($o.SansInterface) { $a += "--px0-sans-interface" }
    if ($o.Libre) { $a += "--px0-libre" }
    if ($o.Controle) { $a += "--px0-controle" }
    if ($o.Fps) { $a += "--px0-fps" }
    if ($o.Attente -gt 0) { $a += "--px0-attente=$([string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0}', $o.Attente))" }
    if ($o.Montage) { $a += "--px0-montage=$($o.Montage)" }
    $r = Lancer $a
    $px0 = @($r.sortie | Where-Object { $_ -like "PX0 *" })
    $erreurs = @($r.sortie | Where-Object { $l = $_; $motifsErreur | Where-Object { $l -like "*$_*" } })
    $controlesKo = @($px0 | Where-Object { ($_ -match 'hors_palette=(\d+)' -and [int]$matches[1] -ne 0) -or ($_ -match 'irreguliers=(\d+)' -and [int]$matches[1] -ne 0) })
    $ok = ($r.code -eq 0) -and ($erreurs.Count -eq 0) -and ($controlesKo.Count -eq 0)
    Ecrire ("--- {0} : code {1}{2}" -f $o.Nom, $r.code, $(if ($ok) { "" } else { "  ** ECHEC **" }))
    foreach ($l in $r.sortie) {
        if ($l -like "PX0 *" -or ($motifsErreur | Where-Object { $l -like "*$_*" }) -or $l -like "ERROR*" -or $l -like "WARNING*" -or $l -like "*at: *") { Ecrire "    $l" }
    }
    $resume = ($px0 | Where-Object { $_ -match '^PX0 (fenetre|grille|palette|images_par_seconde|etape)' } | ForEach-Object { $_.Substring(4) }) -join " | "
    $script:resumes += ("{0,-18} {1} {2}" -f $o.Nom, $(if ($ok) { "OK   " } else { "ECHEC" }), $resume)
    return $ok
}

$script:resumes = @()
$debut = Get-Date

# Import (les polices et les scripts doivent être importés)
$imp = Lancer @("--headless", "--log-file", (Join-Path $tmp "import.log"), "--path", $projet, "--import")
$errImp = @($imp.sortie | Where-Object { $l = $_; $motifsErreur | Where-Object { $l -like "*$_*" } })
$toutOk = ($imp.code -eq 0) -and ($errImp.Count -eq 0)

function Monter([string]$gauche, [string]$droite, [string]$sortie) {
    # Montage côte à côte : image de gauche mise à la hauteur de celle de droite (bilinéaire pour une photo,
    # plus proche voisin pour une capture pixel), 16 px de séparation couleur encre.
    if (-not (Test-Path -LiteralPath $gauche) -or -not (Test-Path -LiteralPath $droite)) {
        Ecrire "    montage non produit (image absente) : $gauche + $droite"; return $false
    }
    Add-Type -AssemblyName System.Drawing
    $g = [Drawing.Image]::FromFile($gauche); $d = [Drawing.Image]::FromFile($droite)
    $h = $d.Height; $lg = [int][math]::Round($g.Width * $h / $g.Height)
    $m = New-Object Drawing.Bitmap ($lg + 16 + $d.Width), $h
    $gr = [Drawing.Graphics]::FromImage($m)
    $gr.Clear([Drawing.Color]::FromArgb(0x1C, 0x16, 0x26))
    $gr.InterpolationMode = $(if ($gauche -like "*.jpg") { 'HighQualityBicubic' } else { 'NearestNeighbor' })
    $gr.PixelOffsetMode = 'Half'
    $gr.DrawImage($g, (New-Object Drawing.Rectangle 0, 0, $lg, $h))
    $gr.InterpolationMode = 'NearestNeighbor'
    $gr.DrawImage($d, (New-Object Drawing.Rectangle ($lg + 16), 0, $d.Width, $h))
    $m.Save($sortie, [Drawing.Imaging.ImageFormat]::Png)
    $largeur = $m.Width
    $gr.Dispose(); $m.Dispose(); $g.Dispose(); $d.Dispose()
    Ecrire ("montage : {0} ({1}x{2})" -f (Split-Path -Leaf $sortie), $largeur, $h)
    return $true
}

if ($Serie) {
    $journal = Join-Path $captures "px0_ter_serie.log"
    Set-Content -LiteralPath $journal -Value ("Série PX0 ter du {0:yyyy-MM-dd HH:mm:ss}, Godot : {1}" -f $debut, $exe) -Encoding UTF8
    Ecrire ("import : code {0}{1}" -f $imp.code, $(if ($errImp.Count) { " ; " + ($errImp -join " / ") } else { "" }))
    $p = "px0_ter_"
    $liste = @(
        @{ Nom = "${p}jour_1080"; Etape = "jour"; Taille = "1920x1080"; Controle = $true; Fps = $true },
        @{ Nom = "${p}nuit_1080"; Etape = "nuit"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "${p}carte_1080"; Etape = "carte"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "${p}jersey_1080"; Etape = "jersey"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "${p}sylvie_0"; Etape = "sylvie_0"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "${p}sylvie_1"; Etape = "sylvie_1"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "${p}sylvie_2"; Etape = "sylvie_2"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "${p}jour_720"; Etape = "jour"; Taille = "1280x720"; Controle = $true },
        @{ Nom = "${p}jour_1366"; Etape = "jour"; Taille = "1366x768"; Controle = $true },
        @{ Nom = "${p}jour_tel"; Etape = "jour"; Telephone = $true; Controle = $true },
        @{ Nom = "${p}nuit_tel"; Etape = "nuit"; Telephone = $true; Controle = $true },
        @{ Nom = "${p}grille_x2"; Etape = "jour"; Taille = "1280x720"; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "${p}grille_x3"; Etape = "jour"; Taille = "1920x1080"; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "${p}grille_x4"; Etape = "jour"; Taille = "1920x1080"; Facteur = 4; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "${p}grille_1366"; Etape = "jour"; Taille = "1366x768"; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "${p}grille_tel"; Etape = "jour"; Telephone = $true; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "${p}libre_0"; Etape = "jour"; Taille = "1920x1080"; Libre = $true },
        @{ Nom = "${p}libre_15"; Etape = "jour"; Taille = "1920x1080"; Libre = $true; Attente = 1.5 },
        @{ Nom = "${p}planche"; Etape = "planche"; Taille = "1920x1080"; Controle = $true }
    )
    foreach ($o in $liste) {
        if (-not (Capturer $o)) { $toutOk = $false }
    }
    # Montages (référence ou capture de PX0 à gauche, capture PX0 bis à droite)
    if (-not $Reference) { $Reference = Join-Path $depot "docs\sources\graphisme\references\rue_pixel_v2.jpg" }
    $jour = Join-Path $captures "${p}jour_1080.png"
    $px0 = Join-Path $captures "px0_bis_jour_1080.png"
    if (-not (Test-Path -LiteralPath $px0)) { $px0 = Join-Path $captures "px0_jour_1080.png" }
    [void](Monter $Reference $jour (Join-Path $captures "${p}montage_ref.png"))
    [void](Monter $px0 $jour (Join-Path $captures "${p}montage_px0.png"))
    [void](Monter (Join-Path $refs "v3_rue.png") $jour (Join-Path $captures "${p}montage_pc.png"))
} else {
    if ($errImp.Count) { Write-Host ("import : " + ($errImp -join " / ")) }
    $o = @{ Nom = $Nom; Etape = $Etape; Taille = $Taille; Telephone = [bool]$Telephone; Facteur = $Facteur;
            SansInterface = [bool]$SansInterface; Libre = [bool]$Libre; Controle = [bool]$Controle; Fps = [bool]$Fps;
            Attente = $Attente; Montage = $Montage }
    if (-not (Capturer $o)) { $toutOk = $false }
    if ($Reference) {
        [void](Monter $Reference (Join-Path $captures "$Nom.png") (Join-Path $captures "${Nom}_montage_ref.png"))
    }
}

Ecrire ""
Ecrire ("Résumé ({0:N0} s) :" -f ((Get-Date) - $debut).TotalSeconds)
foreach ($r in $script:resumes) { Ecrire "  $r" }
Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
if ($toutOk) { Ecrire "PX0 : tout est vert"; exit 0 }
Ecrire "PX0 : au moins un échec (voir ci-dessus)"
exit 1
