<?php
// Procurar .mpd dentro de cada subpasta da pasta "videos"
$videosPath = __DIR__ . '/videos';
$mpdFiles = [];

if (is_dir($videosPath)) {
    foreach (glob($videosPath . '/*', GLOB_ONLYDIR) as $folder) {
        foreach (glob($folder . '/*.mpd') as $mpd) {
            // Salvar o caminho relativo para usar no player
            $relativePath = str_replace(__DIR__ . '/', '', $mpd);
            $mpdFiles[] = $relativePath;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Player MPEG-DASH com múltiplas pastas</title>

    <script src="./assets/js/dash.all.min.js"></script>

    <style>
        body {
            background-color: #121212;
            color: #ffffff;
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
            height: 100vh;
            margin: 0;
            padding-top: 30px;
        }

        h1 {
            margin-bottom: 20px;
            font-size: 2rem;
        }

        #loading {
            font-size: 1.2rem;
            margin: 20px 0;
            animation: pulse 1.5s infinite;
        }

        video {
            width: 80%;
            max-width: 720px;
            border: 2px solid #00bcd4;
            border-radius: 8px;
            background-color: #000;
            display: none;
        }

        select {
            margin-bottom: 20px;
            padding: 5px 10px;
            font-size: 1rem;
            border-radius: 6px;
            border: 1px solid #00bcd4;
            background: #1e1e1e;
            color: #ffffff;
        }

        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
    </style>
</head>

<body>
    <h1>Player MPEG-DASH</h1>

    <?php if (!empty($mpdFiles)): ?>
        <select id="mpdSelector" onchange="startPlayer()">
            <?php foreach ($mpdFiles as $file): ?>
                <option value="<?php echo htmlspecialchars($file, ENT_QUOTES, 'UTF-8'); ?>">
                    <?php echo htmlspecialchars(basename(dirname($file)) . ' - ' . basename($file), ENT_QUOTES, 'UTF-8'); ?>
                </option>
            <?php endforeach; ?>
        </select>

        <div id="loading">Carregando vídeo...</div>
        <video id="videoPlayer" controls></video>

    <?php else: ?>
        <p style="color: red;">Nenhum arquivo MPD encontrado nas pastas de vídeos!</p>
    <?php endif; ?>

    <script>
        let playerInstance = null;

        function startPlayer() {
            const select = document.getElementById('mpdSelector');
            const mpdUrl = select.value;
            const video = document.getElementById('videoPlayer');

            if (playerInstance) {
                playerInstance.reset(); // Limpa o player anterior antes de carregar outro
            }

            playerInstance = dashjs.MediaPlayer().create();
            playerInstance.initialize(video, mpdUrl, true);

            playerInstance.on(dashjs.MediaPlayer.events.STREAM_INITIALIZED, function() {
                document.getElementById('loading').style.display = 'none';
                video.style.display = 'block';
            });

            document.getElementById('loading').style.display = 'block';
            video.style.display = 'none';
        }

        window.onload = startPlayer; // Começa já carregando o primeiro
    </script>
</body>
</html>
