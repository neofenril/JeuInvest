# Lance les tests automatiques headless (godot\tests\) et analyse toute leur sortie.
# Code de sortie : 0 seulement si tout est propre ; 1 sinon ; 3 si Godot est introuvable.
# Usage (depuis n'importe quel dossier, dans le dépôt ou dans un worktree Git) :
#   powershell -ExecutionPolicy Bypass -File godot\outils\tests.ps1 [options]
# Options :
#   -SansImport      ne pas relancer l'import du projet (--headless --import, fait par défaut à chaque fois)
#   -Recette         ajoute les tests du testeur : godot\tests\recette\test_*
#   -Filtre <motif>  ne lance que les tests dont le nom contient le motif (jokers * acceptés), ex. -Filtre demo
#   -Joueur          passe « -- --joueur » aux tests de recette (avec -Recette) : version du joueur simulée
#                    (raccourcis de test retirés), ex. tests.ps1 -Recette -Joueur
#   -Autocontrole    lance seulement tests\autocontrole\erreur_volontaire.gd (erreur de script volontaire)
#                    et erreur_moteur.gd (ligne « ERROR: » du moteur), tous deux de code 0 : renvoie 0
#                    seulement si les deux erreurs sont détectées et signalées
#   -Delai <s>       durée maximale d'un test (120 s par défaut) ; au-delà il est arrêté et compté en échec
# Découverte : tests\test_*.tscn lancés comme scènes ; tests\test_*.gd lancés en --script, sauf s'ils ont
# un .tscn du même nom (script de la scène).
# Un test (ou l'import) échoue si son code de sortie n'est pas 0 OU si sa sortie (stdout + stderr) contient
# une erreur : SCRIPT ERROR, Parse Error, Failed to load script, Invalid call, Invalid access,
# Cannot call method, ou une ligne « ERROR: » du moteur (T17). Les lignes fautives sont réaffichées.
# Fichiers user:// : aucun test_*_<pid>.sav des tests lancés ne doit rester ; la sauvegarde du joueur
# (partie_en_cours.sav) doit être identique avant et après (empreinte SHA-256).
# Godot : voir trouver_godot.ps1 (variable JEUCLAUDE_GODOT, dépôt, dépôt principal d'un worktree).
param(
    [switch]$SansImport,
    [switch]$Recette,
    [string]$Filtre = "",
    [switch]$Autocontrole,
    [switch]$Joueur,
    [int]$Delai = 120
)

. (Join-Path $PSScriptRoot "trouver_godot.ps1")
if (-not $godot) { exit 3 }   # message déjà affiché par trouver_godot.ps1

$motifErreur = 'SCRIPT ERROR|Parse Error|Failed to load script|Invalid call|Invalid access|Cannot call method|^\s*ERROR:'
$dossierUser = Join-Path $env:APPDATA "Godot\app_userdata\JeuClaude"
$sauvegardeJoueur = Join-Path $dossierUser "partie_en_cours.sav"
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("jeuclaude_tests_" + $PID)
New-Item -ItemType Directory -Force -Path $temp | Out-Null

function Get-Empreinte([string]$chemin) {
    if (Test-Path -LiteralPath $chemin -PathType Leaf) {
        return (Get-FileHash -LiteralPath $chemin -Algorithm SHA256).Hash
    }
    return "(absente)"
}

function Format-Argument([string]$a) {
    if ($a -match '\s') { return '"' + $a + '"' }
    return $a
}

# Lance Godot avec les arguments donnés, attend (au plus $Delai s), analyse stdout + stderr.
function Invoke-Godot([string]$nom, [string[]]$arguments) {
    $fo = Join-Path $temp "$nom.out.txt"
    $fe = Join-Path $temp "$nom.err.txt"
    $ligneArgs = ($arguments | ForEach-Object { Format-Argument $_ }) -join ' '
    $debut = Get-Date
    $p = Start-Process -FilePath $godot -ArgumentList $ligneArgs -NoNewWindow -PassThru `
        -RedirectStandardOutput $fo -RedirectStandardError $fe
    $null = $p.Handle   # sinon ExitCode reste vide sous Windows PowerShell 5.1
    $delaiDepasse = $false
    if (-not $p.WaitForExit($Delai * 1000)) {
        $delaiDepasse = $true
        try { $p.Kill() } catch {}
    }
    $p.WaitForExit()
    $duree = ((Get-Date) - $debut).TotalSeconds
    $code = if ($delaiDepasse) { -1 } else { $p.ExitCode }
    $sortie = @()
    if (Test-Path -LiteralPath $fo) { $sortie += @(Get-Content -LiteralPath $fo -Encoding UTF8) }
    $erreurStd = @()
    if (Test-Path -LiteralPath $fe) { $erreurStd += @(Get-Content -LiteralPath $fe -Encoding UTF8) }
    # Lignes fautives (avec la ligne « at: … » qui suit, pour situer l'erreur)
    $fautives = @()
    $nbErreurs = 0
    foreach ($bloc in @($sortie, $erreurStd)) {
        for ($i = 0; $i -lt $bloc.Count; $i++) {
            if ($bloc[$i] -match $motifErreur) {
                $nbErreurs++
                $fautives += $bloc[$i]
                if ($i + 1 -lt $bloc.Count -and $bloc[$i + 1] -match '^\s+at:') { $fautives += $bloc[$i + 1] }
            }
        }
    }
    $ok = @($sortie | Where-Object { $_ -match '^OK\s' }).Count
    $ko = @($sortie | Where-Object { $_ -match '^KO\s' }).Count
    return [pscustomobject]@{ Nom = $nom; Code = $code; Duree = $duree; Sortie = $sortie; ErreurStd = $erreurStd;
        Fautives = $fautives; NbErreurs = $nbErreurs; Ok = $ok; Ko = $ko; Pid = $p.Id; DelaiDepasse = $delaiDepasse;
        Propre = ((-not $delaiDepasse) -and $code -eq 0 -and $nbErreurs -eq 0) }
}

function Show-Resultat($r, [bool]$sortieComplete) {
    Write-Host ""
    Write-Host "===== $($r.Nom) ====="
    if ($sortieComplete) {
        foreach ($l in $r.Sortie) { Write-Host $l }
        foreach ($l in $r.ErreurStd) { if ($l.Trim() -ne "") { Write-Host "[stderr] $l" } }
    }
    if ($r.DelaiDepasse) { Write-Host "ÉCHEC : délai de $Delai s dépassé, processus arrêté (un test bloqué par une erreur ne quitte jamais)." }
    if ($r.NbErreurs -gt 0) {
        Write-Host "ÉCHEC : $($r.NbErreurs) erreur(s) de script détectée(s) dans la sortie de $($r.Nom) :"
        # Lignes distinctes seulement (une erreur dans une boucle se répète des centaines de fois), 20 au plus
        $distinctes = @($r.Fautives | Select-Object -Unique)
        foreach ($l in ($distinctes | Select-Object -First 20)) { Write-Host "  >> $l" }
        if ($distinctes.Count -gt 20) { Write-Host "  >> … et $($distinctes.Count - 20) autre(s) ligne(s) distincte(s)" }
    }
}

# ---------------------------------------------------------------------
# Liste des tests
# ---------------------------------------------------------------------
$tests = @()
function Add-Tests([string]$dossier, [string]$prefixeRes, [string[]]$argsUtilisateur = @()) {
    if (-not (Test-Path -LiteralPath $dossier)) { return }
    $liste = @()
    $suffixe = @()
    if ($argsUtilisateur.Count -gt 0) { $suffixe = @("--") + $argsUtilisateur }
    $scenes = @(Get-ChildItem -LiteralPath $dossier -Filter "test_*.tscn" -File)
    foreach ($s in $scenes) { $liste += [pscustomobject]@{ Nom = $s.BaseName; Args = @("$prefixeRes/$($s.Name)") + $suffixe } }
    foreach ($g in @(Get-ChildItem -LiteralPath $dossier -Filter "test_*.gd" -File)) {
        if (Test-Path -LiteralPath (Join-Path $dossier ($g.BaseName + ".tscn"))) { continue }
        $liste += [pscustomobject]@{ Nom = $g.BaseName; Args = @("--script", "$prefixeRes/$($g.Name)") + $suffixe }
    }
    return $liste
}

$autocontroles = @("autocontrole_erreur_volontaire", "autocontrole_erreur_moteur")
if ($Autocontrole) {
    $tests = @([pscustomobject]@{ Nom = "autocontrole_erreur_volontaire"; Args = @("--script", "res://tests/autocontrole/erreur_volontaire.gd") },
        [pscustomobject]@{ Nom = "autocontrole_erreur_moteur"; Args = @("--script", "res://tests/autocontrole/erreur_moteur.gd") })
} else {
    if ($Joueur -and -not $Recette) { Write-Host "Remarque : -Joueur ne concerne que les tests de recette (ajouter -Recette)." }
    foreach ($x in @(Add-Tests (Join-Path $projet "tests") "res://tests")) { if ($null -ne $x) { $tests += $x } }
    if ($Recette) {
        $argsRecette = @()
        if ($Joueur) { $argsRecette = @("--joueur") }
        foreach ($x in @(Add-Tests (Join-Path $projet "tests\recette") "res://tests/recette" $argsRecette)) {
            if ($null -ne $x) {
                if ($Joueur) { $x.Nom = $x.Nom + "_joueur" }
                $tests += $x
            }
        }
    }
    if ($Filtre -ne "") {
        $motif = if ($Filtre.Contains("*")) { $Filtre } else { "*$Filtre*" }
        $tests = @($tests | Where-Object { $_.Nom -like $motif })
    }
    $tests = @($tests | Sort-Object Nom)
    if ($tests.Count -eq 0) {
        Write-Host "ERREUR : aucun test trouvé (filtre : « $Filtre »)."
        exit 1
    }
}

# ---------------------------------------------------------------------
# Exécution
# ---------------------------------------------------------------------
$debutTotal = Get-Date
Write-Host "Godot : $godot ($godotSource)"
Write-Host "Projet : $projet"
Write-Host ("Tests : " + (($tests | ForEach-Object { $_.Nom }) -join ", "))
$empreinteAvant = Get-Empreinte $sauvegardeJoueur
$resultats = @()

if (-not $SansImport) {
    $imp = Invoke-Godot "import" @("--headless", "--path", $projet, "--import")
    Show-Resultat $imp $false
    if ($imp.Propre) { Write-Host "Import : propre ($('{0:N1}' -f $imp.Duree) s)." }
    $resultats += $imp
}

foreach ($t in $tests) {
    $r = Invoke-Godot $t.Nom (@("--headless", "--path", $projet) + $t.Args)
    if ($t.Args -contains "--joueur") { Write-Host ""; Write-Host "(lancé avec : -- --joueur)" }
    Show-Resultat $r $true
    $resultats += $r
}

# Fichiers laissés dans user:// par les tests lancés ici (noms uniques par processus)
$restes = @()
foreach ($r in $resultats) {
    if (Test-Path -LiteralPath $dossierUser) {
        $restes += @(Get-ChildItem -LiteralPath $dossierUser -Filter ("test_*_" + $r.Pid + ".sav*") -File -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
    }
}
$empreinteApres = Get-Empreinte $sauvegardeJoueur
$sauvegardeIntacte = ($empreinteAvant -eq $empreinteApres)

# ---------------------------------------------------------------------
# Résumé
# ---------------------------------------------------------------------
$dureeTotale = ((Get-Date) - $debutTotal).TotalSeconds
Write-Host ""
Write-Host "===== RÉSUMÉ ====="
Write-Host ("{0,-34} {1,5} {2,9} {3,8} {4,4} {5,9}  {6}" -f "Étape", "Code", "Durée", "OK", "KO", "Err.script", "Verdict")
foreach ($r in $resultats) {
    $verdict = if ($r.Propre) { "propre" } elseif ($r.DelaiDepasse) { "ÉCHEC (délai)" } else { "ÉCHEC" }
    Write-Host ("{0,-34} {1,5} {2,7:N1} s {3,8} {4,4} {5,9}  {6}" -f $r.Nom, $r.Code, $r.Duree, $r.Ok, $r.Ko, $r.NbErreurs, $verdict)
}
$nbOk = ($resultats | Measure-Object -Property Ok -Sum).Sum
$nbKo = ($resultats | Measure-Object -Property Ko -Sum).Sum
$nbErr = ($resultats | Measure-Object -Property NbErreurs -Sum).Sum
$nbEchecs = @($resultats | Where-Object { -not $_.Propre }).Count
if ($restes.Count -gt 0) { Write-Host ("ÉCHEC : fichiers de test restés dans user:// : " + ($restes -join ", ")) }
if (-not $sauvegardeIntacte) { Write-Host "ÉCHEC : la sauvegarde du joueur (partie_en_cours.sav) a changé pendant les tests ($empreinteAvant -> $empreinteApres). Si le jeu était ouvert en même temps, relancer." }
else { Write-Host "Sauvegarde du joueur : inchangée ($(if ($empreinteAvant -eq '(absente)') { 'absente' } else { 'SHA-256 ' + $empreinteAvant.Substring(0, 12) + '…' }))." }
Write-Host ("Total : {0} étape(s), {1} vérifications OK, {2} KO, {3} erreur(s) de script, {4} échec(s), durée {5:N1} s." -f $resultats.Count, $nbOk, $nbKo, $nbErr, $nbEchecs, $dureeTotale)
Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue

$proprete = ($nbEchecs -eq 0 -and $restes.Count -eq 0 -and $sauvegardeIntacte)
if ($Autocontrole) {
    $importPropre = (@($resultats | Where-Object { $_.Nom -eq "import" -and -not $_.Propre }).Count -eq 0)
    $detectees = 0
    foreach ($nomAuto in $autocontroles) {
        $auto = $resultats | Where-Object { $_.Nom -eq $nomAuto }
        if ($null -ne $auto -and $auto.NbErreurs -gt 0 -and $auto.Code -eq 0) { $detectees++ }
        else { Write-Host "Non détectée : $nomAuto" }
    }
    if ($detectees -eq $autocontroles.Count -and $importPropre -and $restes.Count -eq 0) {
        Write-Host "AUTOCONTRÔLE RÉUSSI : l'erreur de script volontaire et la ligne « ERROR: » du moteur (codes de sortie 0) ont été détectées et signalées."
        exit 0
    }
    Write-Host "AUTOCONTRÔLE ÉCHOUÉ : une erreur volontaire n'a pas été détectée (ou l'import n'est pas propre)."
    exit 1
}
if ($proprete) {
    Write-Host "TOUT EST PROPRE."
    exit 0
}
Write-Host "ÉCHEC DES TESTS (voir ci-dessus)."
exit 1
