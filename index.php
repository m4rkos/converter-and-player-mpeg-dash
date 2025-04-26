<?php

function redirect($url) {
    header("Location: $url");
    exit();
}

redirect('player.php');
