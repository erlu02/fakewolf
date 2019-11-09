<?php
require_once  'settings.php';
$file = str_replace("/","", @parse_url($_SERVER['REQUEST_URI'])['path']);
switch (@parse_url($_SERVER['REQUEST_URI'])['path']) {
    case '/createRoom':
        require 'createRoom.php';
        break;
    case '/sendMessage':
        require 'createRoom.php';
        break;
    default:
        if(file_exists($file)){
            require $file;
        }
        else{
            http_response_code(404);
            exit('Not Found');
        }
}
?>