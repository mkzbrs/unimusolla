<?php

require_once __DIR__.'/../middleware/auth.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/upload.php';
require_once __DIR__.'/../helpers/response.php';

$userId=$_POST['user_id'];

if(!isset($_FILES['image'])){

    jsonResponse(false,'No image');

}

$fileName=uploadImage(
    $_FILES['image'],
    PROFILE_UPLOAD_PATH
);

$db=Database::connect();

$db->prepare(
"
UPDATE users
SET profile_image=?
WHERE id=?
"
)->execute([
$fileName,
$userId
]);

jsonResponse(
true,
'Profile uploaded',
[
'file'=>$fileName
]
);
