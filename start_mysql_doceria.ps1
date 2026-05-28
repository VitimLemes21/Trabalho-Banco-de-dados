$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$dataDir = Join-Path $projectRoot "mysql-data"
$mysqlBin = "C:\Program Files\MySQL\MySQL Server 8.0\bin"
$mysqld = Join-Path $mysqlBin "mysqld.exe"
$mysqladmin = Join-Path $mysqlBin "mysqladmin.exe"
$port = 3309

if (-not (Test-Path $mysqld)) {
    throw "MySQL nao encontrado em: $mysqld"
}

if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
    & $mysqld --initialize-insecure --datadir="$dataDir" --console
}

$isRunning = $false
try {
    & $mysqladmin --user=root --host=127.0.0.1 --port=$port ping | Out-Null
    $isRunning = $true
} catch {
    $isRunning = $false
}

if (-not $isRunning) {
    $argsList = @(
        "--datadir=$dataDir",
        "--port=$port",
        "--socket=mysql_doceria",
        "--console",
        "--skip-log-bin"
    )

    Start-Process -FilePath $mysqld -ArgumentList $argsList -WindowStyle Hidden
    Start-Sleep -Seconds 5
    & $mysqladmin --user=root --host=127.0.0.1 --port=$port ping
}

Write-Host "MySQL da doceria pronto em 127.0.0.1:$port"
Write-Host "Usuario: root"
Write-Host "Senha: vazia"

