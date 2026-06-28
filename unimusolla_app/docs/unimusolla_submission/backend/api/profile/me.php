<?php

require_once __DIR__.'/../middleware/auth.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';

try {

    $db = Database::connect();

    $stmt = $db->prepare(
        "
        SELECT
            id,
            email,
            username,
            profile_image,
            role,
            created_at,
            updated_at
        FROM users
        WHERE id=?
        "
    );

    $stmt->execute([
        $userId
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

    jsonResponse(
        true,
        'Profile retrieved',
        $user
    );

} catch (Exception $e) {

    jsonResponse(
        false,
        $e->getMessage(),
        null,
        500
    );
}
