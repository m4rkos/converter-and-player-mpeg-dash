@echo off
setlocal

echo Run: %~nx0
echo.

echo ----------------------------------------------------------
echo.

echo Executando servidor HTTP local para reproduzir o DASH...
echo Acesse http://localhost:8010/ na sua rede local.
echo.

echo Ctrl+C para parar o servidor.

php -S localhost:8010 >nul 2>&1 &
