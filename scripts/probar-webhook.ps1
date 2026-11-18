param(
    [Parameter(Mandatory=$true)][string]$Url,
    [ValidateSet('individual','comparacion','sin_datos','no_autorizado')]
    [string]$Caso = 'individual'
)

$preguntas = @{
    individual = '¿Cuál fue el desvío YTD de Sueldos básicos de la Banca 01?'
    comparacion = 'Enumera hasta 3 cuentas del rubro PERSONAL de la Banca 01 con sus desvíos YTD. Indica cuáles presentan sobregasto y cuál tiene el mayor sobregasto.'
    sin_datos = '¿Cuál fue el desvío YTD de la cuenta 999999999 de la Banca 01?'
    no_autorizado = '¿Cuál fue el desvío YTD de Sueldos básicos de la Banca 02?'
}

$solicitud = @{
    from = 'cliente_prueba_01'
    text = @{ body = $preguntas[$Caso] }
} | ConvertTo-Json -Depth 5

$cronometro = [System.Diagnostics.Stopwatch]::StartNew()
try {
    $respuesta = Invoke-WebRequest `
        -Uri $Url `
        -Method POST `
        -ContentType 'application/json; charset=utf-8' `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($solicitud)) `
        -TimeoutSec 120 `
        -UseBasicParsing
    $cronometro.Stop()
    Write-Host 'HTTP:' $respuesta.StatusCode
    Write-Host 'Latencia (ms):' $cronometro.ElapsedMilliseconds
    Write-Host 'Cuerpo JSON:' $respuesta.Content
    $datos = $respuesta.Content | ConvertFrom-Json
    if ($null -ne $datos.output) {
        Write-Host 'Respuesta:' $datos.output
        Write-Host 'Caracteres:' $datos.output.Length
        Write-Host 'Cumple maximo 600:' ($datos.output.Length -le 600)
    }
    if ($null -ne $datos.estado) { Write-Host 'Estado:' $datos.estado }
    if ($null -ne $datos.codigo) { Write-Host 'Codigo:' $datos.codigo }
    if ($null -ne $datos.verificacion) { Write-Host 'Verificacion:' $datos.verificacion }
}
catch {
    $cronometro.Stop()
    Write-Host 'Error o timeout tras' $cronometro.ElapsedMilliseconds 'ms:' $_.Exception.Message
}
