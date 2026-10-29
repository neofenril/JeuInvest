# Captures de la preuve de concept pixel (lot PX0, docs/lots/lot_px0.md §2.6 et §5), dans godot\captures\.
# Usage (depuis n'importe quel dossier) :
#   powershell -File godot\outils\capture_px0.ps1 -Etape jour -Nom px0_a -Taille 1920x1080 -Controle -SansInterface
#   ... -Telephone (facteur 1,7 ; fenêtre 1600 x 720 sans -Taille)  -Facteur 4  -Libre  -Fps  -Attente 1.5
#   ... -Montage <png de référence>  -Godot <chemin de Godot console>
#   ... -Serie : toute la série du §5 et le journal godot\captures\px0_serie.log
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
    [switch]$Serie
)
$ErrorActionPreference = "Continue"
$projet = Split-Path -Parent $PSScriptRoot
$racine = Split-Path -Parent $projet
$captures = Join-Path $projet "captures"
New-Item -ItemType Directory -Force $captures | Out-Null

# --- Godot : -Godot, sinon JEUCLAUDE_GODOT, sinon outils\ du dépôt -----------------------------------
$candidats = @($Godot, $env:JEUCLAUDE_GODOT, (Join-Path $racine "outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"))
$exe = $null
foreach ($c in $candidats) {
    if ($c -and (Test-Path -LiteralPath $c -PathType Leaf)) { $exe = (Resolve-Path -LiteralPath $c).Path; break }
}
if (-not $exe) {
    Write-Host "Godot introuvable. Donner -Godot <chemin de Godot_v4.7.2-stable_win64_console.exe> ou définir JEUCLAUDE_GODOT."
    exit 3
}
# Dépôt principal = dossier parent de outils\ dans le chemin de Godot (références v3_rue*.png)
$depot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $exe))
$refs = Join-Path $depot "godot\captures"

$motifsErreur = @("SCRIPT ERROR", "Parse Error", "Failed to load", "Invalid call", "Invalid access", "Cannot call method")
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
    $a = @("--path", $projet, "res://scenes/px0.tscn", "--", "--px0-etape=$($o.Etape)", "--px0-capture=captures/$($o.Nom).png")
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
$imp = Lancer @("--headless", "--path", $projet, "--import")
$errImp = @($imp.sortie | Where-Object { $l = $_; $motifsErreur | Where-Object { $l -like "*$_*" } })
$toutOk = ($imp.code -eq 0) -and ($errImp.Count -eq 0)

if ($Serie) {
    $journal = Join-Path $captures "px0_serie.log"
    Set-Content -LiteralPath $journal -Value ("Série PX0 du {0:yyyy-MM-dd HH:mm:ss}, Godot : {1}" -f $debut, $exe) -Encoding UTF8
    Ecrire ("import : code {0}{1}" -f $imp.code, $(if ($errImp.Count) { " ; " + ($errImp -join " / ") } else { "" }))
    $refPc = Join-Path $refs "v3_rue.png"; $refTel = Join-Path $refs "v3_rue_tel.png"
    $liste = @(
        @{ Nom = "px0_jour_1080"; Etape = "jour"; Taille = "1920x1080"; Controle = $true; Fps = $true; Montage = $refPc },
        @{ Nom = "px0_nuit_1080"; Etape = "nuit"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "px0_carte_1080"; Etape = "carte"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "px0_jersey_1080"; Etape = "jersey"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "px0_sylvie_1"; Etape = "sylvie_1"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "px0_sylvie_2"; Etape = "sylvie_2"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "px0_jour_720"; Etape = "jour"; Taille = "1280x720"; Controle = $true },
        @{ Nom = "px0_jour_1366"; Etape = "jour"; Taille = "1366x768"; Controle = $true },
        @{ Nom = "px0_jour_tel"; Etape = "jour"; Telephone = $true; Controle = $true; Montage = $refTel },
        @{ Nom = "px0_nuit_tel"; Etape = "nuit"; Telephone = $true; Controle = $true },
        @{ Nom = "px0_carte_tel"; Etape = "carte"; Telephone = $true; Controle = $true },
        @{ Nom = "px0_grille_x2"; Etape = "jour"; Taille = "1280x720"; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "px0_grille_x3"; Etape = "jour"; Taille = "1920x1080"; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "px0_grille_x4"; Etape = "jour"; Taille = "1920x1080"; Facteur = 4; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "px0_grille_1366"; Etape = "jour"; Taille = "1366x768"; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "px0_grille_tel"; Etape = "jour"; Telephone = $true; SansInterface = $true; Libre = $true; Controle = $true },
        @{ Nom = "px0_libre_0"; Etape = "jour"; Taille = "1920x1080"; Libre = $true },
        @{ Nom = "px0_libre_15"; Etape = "jour"; Taille = "1920x1080"; Libre = $true; Attente = 1.5 },
        @{ Nom = "px0_planche"; Etape = "planche"; Taille = "1920x1080"; Controle = $true },
        @{ Nom = "px0_polices"; Etape = "polices"; Taille = "1920x1080"; Controle = $true }
    )
    foreach ($o in $liste) {
        if ($o.Montage -and -not (Test-Path -LiteralPath $o.Montage)) {
            Ecrire "    référence absente : $($o.Montage) (montage non produit)"
            $o.Remove("Montage")
        }
        if (-not (Capturer $o)) { $toutOk = $false }
    }
    # Montages avant / après sous leur nom de série
    foreach ($m in @(@("px0_jour_1080_montage.png", "px0_montage_pc.png"), @("px0_jour_tel_montage.png", "px0_montage_tel.png"))) {
        $src = Join-Path $captures $m[0]
        if (Test-Path $src) { Move-Item -Force -LiteralPath $src -Destination (Join-Path $captures $m[1]); Ecrire "montage : $($m[1])" }
    }
} else {
    if ($errImp.Count) { Write-Host ("import : " + ($errImp -join " / ")) }
    $o = @{ Nom = $Nom; Etape = $Etape; Taille = $Taille; Telephone = [bool]$Telephone; Facteur = $Facteur;
            SansInterface = [bool]$SansInterface; Libre = [bool]$Libre; Controle = [bool]$Controle; Fps = [bool]$Fps;
            Attente = $Attente; Montage = $Montage }
    if (-not (Capturer $o)) { $toutOk = $false }
}

Ecrire ""
Ecrire ("Résumé ({0:N0} s) :" -f ((Get-Date) - $debut).TotalSeconds)
foreach ($r in $script:resumes) { Ecrire "  $r" }
Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
if ($toutOk) { Ecrire "PX0 : tout est vert"; exit 0 }
Ecrire "PX0 : au moins un échec (voir ci-dessus)"
exit 1
