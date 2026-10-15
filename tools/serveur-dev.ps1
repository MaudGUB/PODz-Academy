# Mini serveur web local pour tester podz-academy.html en dev (sans Node ni Python).
# Usage (depuis la racine du repo) :
#   powershell -ExecutionPolicy Bypass -File tools\serveur-dev.ps1
# puis ouvrir http://localhost:8080/podz-academy.html
param([int]$Port = $(if ($env:PORT) { [int]$env:PORT } else { 8080 }))
$racine = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$types = @{ ".html" = "text/html; charset=utf-8"; ".js" = "text/javascript; charset=utf-8"; ".css" = "text/css; charset=utf-8"; ".json" = "application/json; charset=utf-8"; ".svg" = "image/svg+xml"; ".png" = "image/png" }
$listener = New-Object Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
# 127.0.0.1 aussi (la page s'y considere egalement en dev) ; sans ce prefixe,
# HttpListener repond "400 Invalid Hostname".
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()
Write-Output "Serveur dev sur http://localhost:$Port/podz-academy.html (Ctrl+C pour arreter)"
try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $chemin = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart("/"))
    if (-not $chemin) { $chemin = "podz-academy.html" }
    $fichier = [IO.Path]::GetFullPath((Join-Path $racine $chemin))
    if ($fichier.StartsWith($racine) -and (Test-Path $fichier -PathType Leaf)) {
      $octets = [IO.File]::ReadAllBytes($fichier)
      $ext = [IO.Path]::GetExtension($fichier).ToLower()
      $ctx.Response.ContentType = if ($types.ContainsKey($ext)) { $types[$ext] } else { "application/octet-stream" }
      $ctx.Response.Headers.Add("Cache-Control", "no-store")
      $ctx.Response.ContentLength64 = $octets.Length
      # Une requete HEAD n'a pas de corps : n'envoyer que les en-tetes.
      if ($ctx.Request.HttpMethod -ne "HEAD") {
        try { $ctx.Response.OutputStream.Write($octets, 0, $octets.Length) } catch {}
      }
    } else {
      $ctx.Response.StatusCode = 404
    }
    try { $ctx.Response.Close() } catch {}
  }
} finally { $listener.Stop() }
