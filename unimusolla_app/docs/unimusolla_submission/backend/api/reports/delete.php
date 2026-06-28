<?php

require_once __DIR__.'/../middleware/auth.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';

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

$reportId = $input['id'] ?? null;

if (!$reportId) {

    jsonResponse(
        false,
        'Report ID required',
        null,
        400
    );
}

$db = Database::connect();

$stmt = $db->prepare(
    "
    SELECT user_id
    FROM reports
    WHERE id=?
    "
);

$stmt->execute([
    $reportId
]);

$report = $stmt->fetch();

if (!$report) {

    jsonResponse(
        false,
        'Report not found',
        null,
        404
    );
}

if ($report['user_id'] != $userId) {

    jsonResponse(
        false,
        'Forbidden',
        null,
        403
    );
}

$db->prepare(
    "
    DELETE FROM reports
    WHERE id=?
    "
)->execute([
    $reportId
]);

jsonResponse(
    true,
    'Report deleted'
);
