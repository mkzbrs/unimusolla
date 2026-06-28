<?php

header('Content-Type: application/json');

echo json_encode([
    "status" => "success",
    "project" => "UniMusolla",
    "server_time" => date('Y-m-d H:i:s'),
    "php_version" => PHP_VERSION
]);
