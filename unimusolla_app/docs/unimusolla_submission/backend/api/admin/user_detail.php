<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';


$id = $_GET['id'] ?? null;

if (!$id) {

    jsonResponse(
        false,
        'User ID required',
        null,
        400
    );
}


$db = Database::connect();

$stmt = $db->prepare(
"
SELECT
id,
email,
username,
role,
created_at
FROM users
WHERE id=?
"
);

$stmt->execute([$id]);

$user = $stmt->fetch();

if (!$user) {

    jsonResponse(
        false,
        'User not found',
        null,
        404
    );
}


jsonResponse(
    true,
    'User',
    $user
);
