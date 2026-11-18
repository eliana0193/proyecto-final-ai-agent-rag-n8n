<#
PRUEBA DE CARGA EXPLORATORIA - DOS SOLICITUDES EN PARALELO
EJECUTADA SOBRE V7 EL 18/11/2026: 2/2 CORRECTAS, 28,24 s Y 41,88 s.
Este script permite repetir la prueba. No usar la URL /webhook-test/,
que puede atender un único evento en modo de escucha. Activar un workflow
DE PRUEBA y usar su URL de PRODUCCION /webhook/... con Ollama qwen2.5:3b.

Uso:
.\prueba-carga-2-consultas.ps1 -Url 'http://localhost:5678/webhook/consulta-presupuesto-rag-ai-agent-v7'

Advertencia: si RAM del equipo esta cercana a 80%, puede ser mas seguro
no intentar concurrencia antes de liberar memoria o reducir aplicaciones.
#>
param([Parameter(Mandatory=$true)][string]$Url)
$preguntas = @(
  '¿Cuál fue el desvío YTD de Sueldos básicos de la Banca 01?',
  '¿Cuál fue el desvío YTD de Plus vacacional de la Banca 01?'
)
$trabajos = @()
foreach ($pregunta in $preguntas) {
  $trabajos += Start-Job -ArgumentList $Url,$pregunta -ScriptBlock {
    param($u,$q)
    $json = @{from='cliente_prueba_01';text=@{body=$q}} | ConvertTo-Json -Depth 5
    $reloj=[System.Diagnostics.Stopwatch]::StartNew()
    try {
      $r=Invoke-WebRequest -Uri $u -Method POST -ContentType 'application/json; charset=utf-8' `
        -Body ([Text.Encoding]::UTF8.GetBytes($json)) -TimeoutSec 180 -UseBasicParsing
      $reloj.Stop()
      $dato=$r.Content | ConvertFrom-Json
      [pscustomobject]@{Pregunta=$q; HTTP=$r.StatusCode; Ms=$reloj.ElapsedMilliseconds; Estado=$dato.estado; Respuesta=$dato.output; Error=$null}
    } catch {
      $reloj.Stop()
      [pscustomobject]@{Pregunta=$q; HTTP=$null; Ms=$reloj.ElapsedMilliseconds; Estado='error_http'; Respuesta=''; Error=$_.Exception.Message}
    }
  }
}
$completados=$trabajos | Wait-Job -Timeout 210
$trabajos | Receive-Job | Format-List
$pendientes=$trabajos | Where-Object {$_.State -notin @('Completed','Failed','Stopped')}
if ($pendientes) { Write-Host 'ATENCION: uno o mas trabajos no terminaron en el plazo'; $pendientes | Stop-Job }
$trabajos | Remove-Job -Force
