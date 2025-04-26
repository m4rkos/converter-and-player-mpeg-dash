# Start-Server.ps1
# Servidor HTTP simples usando apenas PowerShell
# Agora com escolha de porta e fallback automático!

function Start-HttpServer {
    param(
        [int]$Port = 8080
    )

    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$Port/")

    try {
        $listener.Start()
    } catch {
        Write-Host ""
        Write-Host "⚠️  Porta $Port está ocupada ou não pode ser usada." -ForegroundColor Yellow
        return $null
    }

    return $listener
}

# Perguntar porta inicial
$defaultPort = 8080
$chosenPort = Read-Host "Digite a porta desejada (pressione Enter para usar $defaultPort)"

if ([string]::IsNullOrWhiteSpace($chosenPort)) {
    $port = $defaultPort
} else {
    $port = [int]$chosenPort
}

# Tenta iniciar o servidor na porta escolhida
$listener = $null
while (-not $listener) {
    $listener = Start-HttpServer -Port $port
    if (-not $listener) {
        $port++
    }
}

Write-Host ""
Write-Host "✅ Servidor HTTP iniciado em: http://localhost:$port" -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar o servidor."
Write-Host ""

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $localPath = Join-Path (Get-Location) ($request.Url.AbsolutePath.TrimStart('/') -replace '/', '\')

        $method = $request.HttpMethod
        $pathRequested = $request.Url.AbsolutePath
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

        Write-Host "[$timestamp] $method $pathRequested"

        if (Test-Path $localPath) {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($localPath)
                $response.ContentType = "application/octet-stream"
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
                Write-Host "[$timestamp] 200 OK - $localPath" -ForegroundColor Green
            } catch {
                $response.StatusCode = 500
                $errorMsg = [System.Text.Encoding]::UTF8.GetBytes("Erro interno ao ler o arquivo.")
                $response.OutputStream.Write($errorMsg, 0, $errorMsg.Length)
                Write-Host "[$timestamp] 500 Internal Server Error - $localPath" -ForegroundColor Red
            }
        } else {
            $response.StatusCode = 404
            $errorMsg = [System.Text.Encoding]::UTF8.GetBytes("404 - Arquivo não encontrado")
            $response.OutputStream.Write($errorMsg, 0, $errorMsg.Length)
            Write-Host "[$timestamp] 404 Not Found - $localPath" -ForegroundColor Yellow
        }

        $response.OutputStream.Close()

    } catch {
        Write-Host "Erro inesperado: $_" -ForegroundColor Red
    }
}
