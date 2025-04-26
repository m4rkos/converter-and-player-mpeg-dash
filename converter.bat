@echo off
setlocal

if "%~1"=="" (
    echo Uso: convert_dash.bat arquivo.mp4
    exit /b 1
)

set "INPUT=%~1"
set "BASENAME=%~n1"

:: Substitui espaços e pontos por _
set "BASENAME_CLEAN=%BASENAME: =_%"
set "BASENAME_CLEAN=%BASENAME_CLEAN:.=_%"

set "OUTPUT_FOLDER=videos\%BASENAME_CLEAN%_dash"

echo Nome limpo: %BASENAME_CLEAN%

echo Convertendo %INPUT% para H.264 (profile main) + AAC stereo...
ffmpeg -y -i "%INPUT%" -c:v libx264 -profile:v main -preset fast -c:a aac -ac 2 -b:a 128k -strict experimental "%BASENAME_CLEAN%_encoded.mp4"

echo Separando video e audio...
ffmpeg -y -i "%BASENAME_CLEAN%_encoded.mp4" -an -c:v copy "%BASENAME_CLEAN%_video_only.mp4"
ffmpeg -y -i "%BASENAME_CLEAN%_encoded.mp4" -vn -c:a copy "%BASENAME_CLEAN%_audio_only.mp4"

echo Empacotando para MPEG-DASH...
MP4Box -dash 4000 -frag 4000 -rap -profile dashavc264:live -out "%BASENAME_CLEAN%_manifest.mpd" "%BASENAME_CLEAN%_video_only.mp4" "%BASENAME_CLEAN%_audio_only.mp4"

echo Criando pasta "%OUTPUT_FOLDER%" e movendo arquivos...
mkdir "%OUTPUT_FOLDER%"
move "%BASENAME_CLEAN%_manifest.mpd" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_video_only_dash*" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_audio_only_dash*" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_encoded.mp4" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_video_only.mp4" "%OUTPUT_FOLDER%\" >nul
move "%BASENAME_CLEAN%_audio_only.mp4" "%OUTPUT_FOLDER%\" >nul

@REM echo Copiando player.html como index.html...
@REM if exist "player.html" (
@REM     copy "player.html" "%OUTPUT_FOLDER%\index.html"
@REM     echo player.html copiado como index.html para %OUTPUT_FOLDER%\
@REM ) else (
@REM     echo Aviso: player.html nao encontrado para copiar!
@REM )

@REM echo Copiando run-server.bat...
@REM if exist "run-server.bat" (
@REM     copy "run-server.bat" "%OUTPUT_FOLDER%\"
@REM     echo run-server.bat copiado para %OUTPUT_FOLDER%\
@REM ) else (
@REM     echo Aviso: run-server.bat nao encontrado para copiar!
@REM )

echo Finalizado! Os arquivos estao organizados em: %OUTPUT_FOLDER%
