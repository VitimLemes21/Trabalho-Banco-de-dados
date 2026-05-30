$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlDir = $projectRoot
$mysql = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$port = 3309

if (-not (Test-Path $mysql)) {
    throw "Cliente MySQL nao encontrado em: $mysql"
}

& (Join-Path $projectRoot "start_mysql_doceria.ps1")

[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$OutputEncoding = New-Object System.Text.UTF8Encoding $false

"DROP DATABASE IF EXISTS doceria;" |
    & $mysql --user=root --host=127.0.0.1 --port=$port --default-character-set=utf8mb4

foreach ($file in @("doceria_ddl.sql", "doceria_dml.sql", "doceria_queries.sql")) {
    $path = Join-Path $sqlDir $file
    if (-not (Test-Path $path)) {
        throw "Arquivo SQL nao encontrado: $path"
    }

    Write-Host "Executando $file..."
    Get-Content -Raw -Encoding UTF8 -LiteralPath $path |
        & $mysql --user=root --host=127.0.0.1 --port=$port --default-character-set=utf8mb4 --force --table
}

Write-Host "Banco doceria recriado e carregado com sucesso."

