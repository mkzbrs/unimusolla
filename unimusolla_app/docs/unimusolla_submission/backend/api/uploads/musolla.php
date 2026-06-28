<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/upload.php';
require_once __DIR__.'/../helpers/response.php';

$musollaId=$_POST['musolla_id'];
$adminId=$_POST['admin_id'];

$db=Database::connect();

foreach($_FILES['images']['tmp_name'] as $index=>$tmp){

    $file=[

        'name'=>$_FILES['images']['name'][$index],
        'tmp_name'=>$tmp

    ];

    $name=uploadImage(
        $file,
        MUSOLLA_UPLOAD_PATH
    );

    $db->prepare(
    "
    INSERT INTO musolla_images(
        musolla_id,
        image_path,
        uploaded_by
    )
    VALUES(?,?,?)
    "
    )->execute([
        $musollaId,
        $name,
        $adminId
    ]);

}

jsonResponse(
true,
'Images uploaded'
);
