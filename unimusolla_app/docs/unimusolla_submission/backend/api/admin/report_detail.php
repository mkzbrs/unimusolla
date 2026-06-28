<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';


$id = $_GET['id'] ?? null;

if (!$id) {

    jsonResponse(
        false,
        'Missing report id',
        null,
        400
    );
}


$db = Database::connect();


$stmt = $db->prepare(
"
SELECT *
FROM reports
WHERE id=?
"
);

$stmt->execute([
    $id
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


$stmt = $db->prepare(
"
SELECT *
FROM report_images
WHERE report_id=?
"
);

$stmt->execute([
    $id
]);

$images = $stmt->fetchAll();


$report['images'] = $images;


jsonResponse(
    true,
    'Report detail',
    $report
);
