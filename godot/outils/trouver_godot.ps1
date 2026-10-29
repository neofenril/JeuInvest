# Localise l'exécutable de Godot pour les scripts de godot\outils\ (tests, captures).
# À inclure par point, en tête de script :
#   . (Join-Path $PSScriptRoot "trouver_godot.ps1")
#   if (-not $godot) { exit 3 }   # message déjà affiché (« exit » dans un script inclus ne quitte pas l'appelant)
# Définit :
#   $godot        : Godot console (ligne de commande, --headless) ;
#   $godotFenetre : Godot sans console (même dossier), ou $godot à défaut ;
#   $godotSource  : d'où vient le chemin (affiché en tête de sortie) ;
#   $projet       : dossier godot\ du dépôt (ou du worktree) ;
#   $racine       : racine du dépôt (ou du worktree).
# Ordre de recherche (lot 01, §2.3) :
#   1. $env:JEUCLAUDE_GODOT s'il est défini (fichier inexistant : erreur, $godot vide, pas de repli) ;
#   2. <racine>\outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe ;
#   3. worktree Git : <racine>\.git est un fichier « gitdir: <dépôt principal>/.git/worktrees/<nom> »,
#      Godot est cherché dans le dossier outils\ du dépôt principal ;
#   4. sinon : message listant les chemins essayés, $godot vide (l'appelant quitte avec le code 3).

$projet = Split-Path -Parent $PSScriptRoot
$racine = Split-Path -Parent $projet
$godotRelatif = "outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
$godot = $null
$godotSource = ""
$godotEssais = @()

if (-not $env:JEUCLAUDE_GODOT) {
    $godotEssais += "variable JEUCLAUDE_GODOT : non définie"
} else {
    $godotEssais += "variable JEUCLAUDE_GODOT : $env:JEUCLAUDE_GODOT"
    if (-not (Test-Path -LiteralPath $env:JEUCLAUDE_GODOT -PathType Leaf)) {
        Write-Host "ERREUR : la variable JEUCLAUDE_GODOT désigne un fichier qui n'existe pas :"
        Write-Host "  $env:JEUCLAUDE_GODOT"
        Write-Host "Corrigez-la (chemin complet de Godot_v4.7.2-stable_win64_console.exe) ou supprimez-la."
        $godot = $null
        $godotFenetre = $null
        return
    }
    $godot = (Resolve-Path -LiteralPath $env:JEUCLAUDE_GODOT).Path
    $godotSource = "variable JEUCLAUDE_GODOT"
}

if ($null -eq $godot) {
    $candidat = Join-Path $racine $godotRelatif
    $godotEssais += $candidat
    if (Test-Path -LiteralPath $candidat -PathType Leaf) {
        $godot = $candidat
        $godotSource = "dépôt"
    }
}

if ($null -eq $godot) {
    # Worktree : .git est un fichier qui désigne le dépôt principal (lu sans Git, absent du PATH).
    $fichierGit = Join-Path $racine ".git"
    if (Test-Path -LiteralPath $fichierGit -PathType Leaf) {
        $ligne = (Get-Content -LiteralPath $fichierGit -TotalCount 1) -as [string]
        if ($ligne -match '^\s*gitdir:\s*(.+?)\s*$') {
            $gitdir = $Matches[1] -replace '/', '\'
            if (-not [System.IO.Path]::IsPathRooted($gitdir)) {
                $gitdir = Join-Path $racine $gitdir
            }
            $pos = $gitdir.ToLower().IndexOf('\.git\worktrees\')
            if ($pos -gt 0) {
                $principal = $gitdir.Substring(0, $pos)
                $candidat = Join-Path $principal $godotRelatif
                $godotEssais += "$candidat (dépôt principal du worktree)"
                if (Test-Path -LiteralPath $candidat -PathType Leaf) {
                    $godot = $candidat
                    $godotSource = "dépôt principal du worktree"
                }
            }
        }
    } else {
        $godotEssais += "dépôt principal d'un worktree : sans objet ($racine\.git n'est pas un fichier de worktree)"
    }
}

if ($null -eq $godot) {
    Write-Host "ERREUR : Godot 4.7.2 (console) introuvable. Chemins essayés :"
    foreach ($essai in $godotEssais) { Write-Host "  - $essai" }
    Write-Host "Définissez la variable JEUCLAUDE_GODOT avec le chemin complet de Godot_v4.7.2-stable_win64_console.exe."
    $godotFenetre = $null
    return
}

$godotFenetre = $godot -replace '_console\.exe$', '.exe'
if (-not (Test-Path -LiteralPath $godotFenetre -PathType Leaf)) {
    $godotFenetre = $godot
}
