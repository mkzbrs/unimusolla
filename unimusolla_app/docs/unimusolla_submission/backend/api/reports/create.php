<?php

require_once __DIR__.'/../middleware/auth.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';
require_once __DIR__.'/../helpers/validator.php';
require_once __DIR__.'/../helpers/upload.php';


if ($_SERVER['REQUEST_METHOD'] !== 'POST') {

    jsonResponse(
        false,
        'Method not allowed',
        null,
        405
    );
}


/*
|--------------------------------------------------------------------------
| Support BOTH:
| - application/json
| - multipart/form-data
|--------------------------------------------------------------------------
*/

if (
    strpos(
        $_SERVER['CONTENT_TYPE'] ?? '',
        'multipart/form-data'
    ) !== false
) {

    $input = $_POST;

} else {

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );
}


$missing = requiredFields(
    $input,
    [
        'name',
        'location'
    ]
);


if (!empty($missing)) {

    jsonResponse(
        false,
        'Missing fields: ' . implode(', ', $missing),
        null,
        400
    );
}


$db = Database::connect();


$stmt = $db->prepare(
"
INSERT INTO reports
(
    user_id,
    musolla_id,
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
    has_telekung
)
VALUES
(?,?,?,?,?,?,?,?,?,?,?,?,?)
"
);


$stmt->execute([

    $currentUser['id'],

    $input['musolla_id'] ?? null,

    $input['name'],

    $input['location'],

    $input['exact_location'] ?? null,

    $input['latitude'] ?? null,

    $input['longitude'] ?? null,

    $input['status'] ?? 'available',

    $input['has_wudhu'] ?? 0,

    $input['has_toilet'] ?? 0,

    $input['has_aircond'] ?? 0,

    $input['has_mats'] ?? 0,

    $input['has_telekung'] ?? 0

]);


$reportId = $db->lastInsertId();


/*
|--------------------------------------------------------------------------
| Upload images
|--------------------------------------------------------------------------
*/

if (isset($_FILES['images'])) {

    foreach ($_FILES['images']['tmp_name'] as $index => $tmp) {

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
            VALUES (?, ?)
            "
            )->execute([
                $reportId,
                $fileName
            ]);

        }

    }

}

jsonResponse(
    true,
    'Report submitted',
    [
        'report_id' => (int)$reportId
    ]
);
