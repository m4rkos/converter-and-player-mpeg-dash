@echo off
setlocal EnableDelayedExpansion

if "%~1"=="" (
    echo Uso: convert_dash.bat arquivo.mp4
    exit /b 1
)

set "INPUT=%~1"
set "BASENAME=%~n1"

:: Substitui espaços e pontos por _
set "BASENAME_CLEAN=%BASENAME: =_%"
set "BASENAME_CLEAN=%BASENAME_CLEAN:.=_%"

set "OUTPUT_FOLDER=output/%BASENAME_CLEAN%_dash"

echo Nome limpo: %BASENAME_CLEAN%

echo Gerando videos em multiplas resolucoes...
ffmpeg -y -i "%INPUT%" -vf "scale=-2:360" -c:v libx264 -preset fast -c:a aac -strict experimental "%BASENAME_CLEAN%_360p.mp4"
ffmpeg -y -i "%INPUT%" -vf "scale=-2:720" -c:v libx264 -preset fast -c:a aac -strict experimental "%BASENAME_CLEAN%_720p.mp4"
ffmpeg -y -i "%INPUT%" -vf "scale=-2:1080" -c:v libx264 -preset fast -c:a aac -strict experimental "%BASENAME_CLEAN%_1080p.mp4"

echo Extraindo audio separado...
ffmpeg -y -i "%INPUT%" -vn -c:a aac -strict experimental "%BASENAME_CLEAN%_audio_only.mp4"

echo Empacotando todos para MPEG-DASH...
MP4Box -dash 4000 -frag 4000 -rap -profile dashavc264:live ^
-out "%BASENAME_CLEAN%_manifest.mpd" ^
"%BASENAME_CLEAN%_360p.mp4" ^
"%BASENAME_CLEAN%_720p.mp4" ^
"%BASENAME_CLEAN%_1080p.mp4" ^
"%BASENAME_CLEAN%_audio_only.mp4"

echo Criando pasta "%OUTPUT_FOLDER%" e movendo arquivos...
mkdir "%OUTPUT_FOLDER%"
move "%BASENAME_CLEAN%_manifest.mpd" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_*_dash*" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_360p.mp4" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_720p.mp4" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_1080p.mp4" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_audio_only.mp4" "%OUTPUT_FOLDER%\" >nul

echo Copiando player.html como index.html...
if exist "player.html" (
    copy "player.html" "%OUTPUT_FOLDER%\index.html"
    echo player.html copiado como index.html para %OUTPUT_FOLDER%\
) else (
    echo Aviso: player.html nao encontrado para copiar!
)

echo Finalizado! Os arquivos estao organizados em: %OUTPUT_FOLDER%
