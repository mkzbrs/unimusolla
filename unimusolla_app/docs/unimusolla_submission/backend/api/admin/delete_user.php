<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';

$input = json_decode(
    file_get_contents('php://input'),
    true
);

$id = $input['id'] ?? null;

if (!$id) {

    jsonResponse(
        false,
        'Missing id',
        null,
        400
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
    $id
]);

$user = $stmt->fetch();

if (!$user) {

    jsonResponse(
        false,
        'User not found',
        null,
        404
    );
}

$db->prepare(
"
DELETE FROM users
WHERE id=?
"
)->execute([
    $id
]);

jsonResponse(
    true,
    'Deleted'
);
