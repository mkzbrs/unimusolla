<?php

require_once __DIR__.'/../middleware/auth.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/upload.php';
require_once __DIR__.'/../helpers/response.php';


$reportId = $_POST['report_id'] ?? null;

if (!$reportId) {

    jsonResponse(
        false,
        'Report ID required',
        null,
        400
    );

}


if (!isset($_FILES['images'])) {

    jsonResponse(
        false,
        'No images uploaded',
        null,
        400
    );

}


$db = Database::connect();

/*
|--------------------------------------------------------------------------
| Support BOTH:
| - Single image
| - Multiple images
|--------------------------------------------------------------------------
*/

$tmpNames = $_FILES['images']['tmp_name'];

if (!is_array($tmpNames)) {

    $tmpNames = [
        $_FILES['images']['tmp_name']
    ];

    $_FILES['images']['name'] = [
        $_FILES['images']['name']
    ];

}


foreach ($tmpNames as $index => $tmp) {

    $file = [

        'name' => $_FILES['images']['name'][$index],

        'tmp_name' => $tmp

    ];

    $fileName = uploadImage(
        $file,
        REPORT_UPLOAD_PATH
    );

    if ($fileName) {

        $db->prepare(
        "
        INSERT INTO report_images
        (
            report_id,
            image_path
        )
        VALUES
        (?, ?)
        "
        )->execute([
            $reportId,
            $fileName
        ]);

    }

}


jsonResponse(
    true,
    'Images uploaded'
);
