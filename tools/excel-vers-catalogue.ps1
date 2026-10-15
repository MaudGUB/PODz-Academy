# Convertit l'Excel du catalogue (onglet "Catalogue") en data/catalogue.js,
# charge par podz-academy.html en dev a la place des listes SharePoint.
#
# Les lignes sont produites au format des items REST de la liste SharePoint
# (Title, field_2..field_11, DureeHeures, Parcours...) pour que mapItem() du
# HTML reste identique entre dev et prod.
#
# Usage (depuis la racine du repo) :
#   powershell -ExecutionPolicy Bypass -File tools\excel-vers-catalogue.ps1
param(
  [string]$Excel = "data\POD_Catalogue_Formations.xlsx",
  [string]$Sortie = "data\catalogue.js"
)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

# L'Excel n'a pas de colonne Parcours : en attendant la vraie liste des
# parcours/assignations, chaque formation est rattachee au parcours de son
# offre (titres = PARCOURS dans podz-academy.html).
# Script en ASCII (PowerShell 5.1 lit les .ps1 sans BOM en ANSI) : accents via [char].
$e_ = [char]0xE9
$PARCOURS_PAR_OFFRE = @{
  "Transverse"                          = "Bien d${e_}marrer chez POD"
  "Offre 1 - Data Products & Analytics" = "Analyste Power BI"
  "Offre 2 - Automation & AI"           = "Automatisation des processus"
  "Offre 3 - Data Strategy & Projects"  = "Pilotage de projet Data"
  "Offre 4 - Data Culture & Governance" = "Acculturation Data"
}

function Lire-Entree($zip, $nom) {
  $e = $zip.GetEntry($nom)
  if (-not $e) { return $null }
  $r = New-Object IO.StreamReader($e.Open(), [Text.Encoding]::UTF8)
  try { return [xml]$r.ReadToEnd() } finally { $r.Close() }
}

# "0,5 j" -> 3.5 h (1 j = 7 h, regle du catalogue) ; "2 h" -> 2 ; "—" -> null
function Duree-EnHeures($s) {
  $s = [string]$s
  if ($s -match '^\s*([\d.,]+)\s*(j|h)\s*$') {
    $n = [double]::Parse($matches[1].Replace(',', '.'), [Globalization.CultureInfo]::InvariantCulture)
    if ($matches[2] -eq 'j') { return $n * 7 } else { return $n }
  }
  return $null
}

$cheminExcel = (Resolve-Path $Excel).Path
$zip = [IO.Compression.ZipFile]::OpenRead($cheminExcel)
try {
  $strings = @()
  $ss = Lire-Entree $zip "xl/sharedStrings.xml"
  if ($ss) {
    foreach ($si in $ss.DocumentElement.ChildNodes) {
      $strings += (($si.SelectNodes(".//*[local-name()='t']") | ForEach-Object { $_.InnerText }) -join '')
    }
  }
  # Onglet "Catalogue" = premiere feuille du classeur
  $ws = Lire-Entree $zip "xl/worksheets/sheet1.xml"
} finally { $zip.Dispose() }

$lignes = @()
foreach ($row in $ws.SelectNodes("//*[local-name()='sheetData']/*[local-name()='row']")) {
  $cells = @{}
  foreach ($c in $row.SelectNodes("*[local-name()='c']")) {
    $col = ($c.GetAttribute("r") -replace '\d', '')
    $vNode = $c.SelectSingleNode("*[local-name()='v']")
    $v = if ($vNode) { $vNode.InnerText } else { "" }
    if ($c.GetAttribute("t") -eq "s") { $v = $strings[[int]$v] }
    elseif ($c.GetAttribute("t") -eq "inlineStr") { $v = $c.SelectSingleNode(".//*[local-name()='t']").InnerText }
    $cells[$col] = $v.Trim()
  }
  $lignes += , $cells
}

# Les colonnes sont reperees par le NOM de leur en-tete (ligne 1), compare sans
# accents ni casse : ajouter, deplacer ou inserer une colonne (ex. Techno) dans
# l'Excel ne casse pas la conversion. Repli sur la lettre historique si un
# en-tete est introuvable ; Techno absente -> "" (en attente du metier).
function Normaliser($s) {
  $d = ([string]$s).Trim().ToLowerInvariant().Normalize([Text.NormalizationForm]::FormD)
  return (($d.ToCharArray() | Where-Object {
    [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark
  }) -join '')
}
$COLONNES = [ordered]@{
  id = "A"; titre = "B"; type = "C"; "offre pod" = "D"; bucket = "E"; niveau = "F"
  duree = "G"; "lien(s)" = "H"; "tags skills" = "I"; plateforme = "J"
  obligatoire = "K"; notes = "L"; techno = $null
}
$entete = @{}
if ($lignes.Count -gt 0) {
  foreach ($lettre in $lignes[0].Keys) { $entete[(Normaliser $lignes[0][$lettre])] = $lettre }
}
$col = @{}
foreach ($nom in $COLONNES.Keys) {
  if ($entete.ContainsKey($nom)) { $col[$nom] = $entete[$nom] }
  else {
    $col[$nom] = $COLONNES[$nom]
    if ($COLONNES[$nom]) { Write-Warning "En-tete '$nom' introuvable : repli sur la colonne $($COLONNES[$nom])" }
  }
}
function Cellule($c, $nom) {
  $lettre = $col[$nom]
  if (-not $lettre -or -not $c.ContainsKey($lettre)) { return "" }
  return $c[$lettre]
}

$items = @()
$ordre = 0
foreach ($c in ($lignes | Select-Object -Skip 1)) {
  if (-not (Cellule $c "id")) { continue }
  $ordre++
  $offre = Cellule $c "offre pod"
  $duree = Cellule $c "duree"
  $plateforme = Cellule $c "plateforme"
  $parcours = @()
  if ($PARCOURS_PAR_OFFRE.ContainsKey($offre)) { $parcours = @($PARCOURS_PAR_OFFRE[$offre]) }
  $items += [ordered]@{
    ID          = Cellule $c "id"
    Title       = Cellule $c "titre"
    field_2     = Cellule $c "type"
    field_3     = $offre
    field_4     = Cellule $c "bucket"
    field_5     = Cellule $c "niveau"
    field_6     = $duree
    DureeHeures = Duree-EnHeures $duree
    field_7     = Cellule $c "lien(s)"
    field_8     = Cellule $c "tags skills"
    field_9     = @{ results = @(if ($plateforme) { $plateforme }) }
    Obligatoire = ((Cellule $c "obligatoire") -eq "Oui")
    field_11    = Cellule $c "notes"
    Techno      = Cellule $c "techno"
    Parcours    = @{ results = $parcours }
    Ordre       = $ordre
  }
}

$json = ConvertTo-Json -InputObject $items -Depth 5
$contenu = "// Genere par tools/excel-vers-catalogue.ps1 depuis $(Split-Path $Excel -Leaf) -- ne pas modifier a la main.`r`nwindow.PODZ_CATALOGUE = $json;`r`n"
$cheminSortie = Join-Path (Get-Location) $Sortie
[IO.File]::WriteAllText($cheminSortie, $contenu, (New-Object Text.UTF8Encoding($false)))
Write-Output "$($items.Count) formations ecrites dans $Sortie"
