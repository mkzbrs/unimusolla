<?php

require_once __DIR__.'/../helpers/auth.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';


$headers = getallheaders();

if (!isset($headers['Authorization'])) {

    jsonResponse(
        false,
        'Unauthorized',
        null,
        401
    );
}


$token = str_replace(
    'Bearer ',
    '',
    $headers['Authorization']
);


$userId = verifyToken(
    $token
);


if (!$userId) {

    jsonResponse(
        false,
        'Invalid token',
        null,
        401
    );
}


$db = Database::connect();

$stmt = $db->prepare(
"
SELECT *
FROM users
WHERE id=?
"
);

$stmt->execute([
    $userId
]);

$currentUser = $stmt->fetch();


if (!$currentUser) {

    jsonResponse(
        false,
        'User not found',
        null,
        401
    );
}
