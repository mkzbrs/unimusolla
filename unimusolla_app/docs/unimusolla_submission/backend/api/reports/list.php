<?php

require_once __DIR__.'/../middleware/auth.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';

try {

    $db = Database::connect();

    $stmt = $db->prepare(
        "
        SELECT *
        FROM reports
        WHERE user_id=?
        ORDER BY submitted_at DESC
        "
    );

    $stmt->execute([
        $userId
    ]);

    jsonResponse(
        true,
        'Reports retrieved',
        $stmt->fetchAll()
    );

} catch (Exception $e) {

    jsonResponse(
        false,
        $e->getMessage(),
        null,
        500
    );
}
