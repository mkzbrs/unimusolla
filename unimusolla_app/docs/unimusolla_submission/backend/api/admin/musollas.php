<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';


$db = Database::connect();


$musollas = $db->query(
"
SELECT *
FROM musollas
ORDER BY id DESC
"
)->fetchAll();


foreach ($musollas as &$musolla) {

    $stmt = $db->prepare(
    "
    SELECT *
    FROM musolla_images
    WHERE musolla_id=?
    ORDER BY is_primary DESC
    "
    );

    $stmt->execute([
        $musolla['id']
    ]);

    $musolla['images'] = $stmt->fetchAll();

}


jsonResponse(
    true,
    'Musollas',
    $musollas
);
