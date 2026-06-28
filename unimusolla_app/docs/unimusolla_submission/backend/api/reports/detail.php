<?php

require_once __DIR__.'/../middleware/auth.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';


$id = $_GET['id'] ?? null;


if (!$id) {

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


/*
|--------------------------------------------------------------------------
| Report Images
|--------------------------------------------------------------------------
*/

$imageStmt = $db->prepare(
"
SELECT
    id,
    image_path
FROM report_images
WHERE report_id=?
"
);

$imageStmt->execute([
    $id
]);

$report['images'] =
    $imageStmt->fetchAll(
        PDO::FETCH_ASSOC
    );


/*
|--------------------------------------------------------------------------
| Current Musolla
|--------------------------------------------------------------------------
*/

if ($report['musolla_id']) {

    $musollaStmt = $db->prepare(
    "
    SELECT *
    FROM musollas
    WHERE id=?
    "
    );

    $musollaStmt->execute([
        $report['musolla_id']
    ]);

    $report['current_musolla'] =
        $musollaStmt->fetch(
            PDO::FETCH_ASSOC
        );

}


jsonResponse(
    true,
    'Report retrieved',
    $report
);
