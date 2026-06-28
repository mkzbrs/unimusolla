<?php

require_once __DIR__.'/../middleware/auth.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';
require_once __DIR__.'/../helpers/validator.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {

    jsonResponse(
        false,
        'Method not allowed',
        null,
        405
    );
}

$input = json_decode(
    file_get_contents('php://input'),
    true
);

$missing = requiredFields(
    $input,
    ['username']
);

if (!empty($missing)) {

    jsonResponse(
        false,
        'Missing username',
        null,
        400
    );
}

try {

    $db = Database::connect();

    $stmt = $db->prepare(
        "
        UPDATE users
        SET
            username=?,
            updated_at=CURRENT_TIMESTAMP
        WHERE id=?
        "
    );

    $stmt->execute([
        trim($input['username']),
        $userId
    ]);

    jsonResponse(
        true,
        'Profile updated'
    );

} catch (Exception $e) {

    jsonResponse(
        false,
        $e->getMessage(),
        null,
        500
    );
}
