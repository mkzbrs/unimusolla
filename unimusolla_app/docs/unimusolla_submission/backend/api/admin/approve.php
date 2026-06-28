<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';
require_once __DIR__.'/../helpers/upload.php';

$input = json_decode(
    file_get_contents('php://input'),
    true
);

$reportId = $input['report_id'] ?? null;

if (!$reportId) {

    jsonResponse(
        false,
        'Missing report_id',
        null,
        400
    );
}

$adminId = $currentUser['id'];

$db = Database::connect();

$stmt = $db->prepare(
"
SELECT *
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

if (
    $report['approval_status']
    !== 'pending'
) {

    jsonResponse(
        false,
        'Report already processed',
        null,
        400
    );
}

/*
|--------------------------------------------------------------------------
| CREATE OR UPDATE MUSOLLA
|--------------------------------------------------------------------------
*/

if ($report['musolla_id']) {

    $musollaId = $report['musolla_id'];

    $db->prepare(
    "
    UPDATE musollas
    SET
        name=?,
        location=?,
        exact_location=?,
        latitude=?,
        longitude=?,
        status=?,
        has_wudhu=?,
        has_toilet=?,
        has_aircond=?,
        has_mats=?,
        has_telekung=?,
        updated_at=CURRENT_TIMESTAMP
    WHERE id=?
    "
    )->execute([

        $report['name'],
        $report['location'],
        $report['exact_location'],
        $report['latitude'],
        $report['longitude'],
        $report['status'],
        $report['has_wudhu'],
        $report['has_toilet'],
        $report['has_aircond'],
        $report['has_mats'],
        $report['has_telekung'],
        $musollaId

    ]);

    /*
    REMOVE OLD IMAGE RECORDS
    */

    $db->prepare(
    "
    DELETE FROM musolla_images
    WHERE musolla_id=?
    "
    )->execute([
        $musollaId
    ]);

} else {

    $db->prepare(
    "
    INSERT INTO musollas
    (
        name,
        location,
        exact_location,
        latitude,
        longitude,
        status,
        has_wudhu,
        has_toilet,
        has_aircond,
        has_mats,
        has_telekung,
        created_by
    )
    VALUES
    (?,?,?,?,?,?,?,?,?,?,?,?)
    "
    )->execute([

        $report['name'],
        $report['location'],
        $report['exact_location'],
        $report['latitude'],
        $report['longitude'],
        $report['status'],
        $report['has_wudhu'],
        $report['has_toilet'],
        $report['has_aircond'],
        $report['has_mats'],
        $report['has_telekung'],
        $report['user_id']

    ]);

    $musollaId = $db->lastInsertId();
}

/*
|--------------------------------------------------------------------------
| COPY REPORT IMAGES TO MUSOLLA IMAGES
|--------------------------------------------------------------------------
*/

$imagesStmt = $db->prepare(
"
SELECT image_path
FROM report_images
WHERE report_id=?
"
);

$imagesStmt->execute([
    $reportId
]);

$images = $imagesStmt->fetchAll();

foreach ($images as $image) {

    $imageName = $image['image_path'];

    $reportFile =
        REPORT_UPLOAD_PATH .
        '/' .
        $imageName;

    $musollaFile =
        MUSOLLA_UPLOAD_PATH .
        '/' .
        $imageName;

    /*
    COPY PHYSICAL FILE
    */

    if (file_exists($reportFile)) {

        copy(
            $reportFile,
            $musollaFile
        );
    }

    /*
    SAVE DATABASE RECORD
    */

    $db->prepare(
    "
    INSERT INTO musolla_images
    (
        musolla_id,
        image_path,
        uploaded_by
    )
    VALUES
    (?, ?, ?)
    "
    )->execute([

        $musollaId,
        $imageName,
        $report['user_id']

    ]);
}

/*
|--------------------------------------------------------------------------
| APPROVE REPORT
|--------------------------------------------------------------------------
*/

$db->prepare(
"
UPDATE reports
SET
    approval_status='approved',
    reviewed_by=?,
    reviewed_at=CURRENT_TIMESTAMP
WHERE id=?
"
)->execute([

    $adminId,
    $reportId

]);

/*
|--------------------------------------------------------------------------
| ADMIN LOG
|--------------------------------------------------------------------------
*/

$db->prepare(
"
INSERT INTO admin_logs
(
    admin_id,
    action,
    target_type,
    target_id
)
VALUES
(
    ?,
    'approved_report',
    'report',
    ?
)
"
)->execute([

    $adminId,
    $reportId

]);

jsonResponse(
    true,
    'Approved successfully'
);
