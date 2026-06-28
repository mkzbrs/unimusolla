<?php

require_once '../config/database.php';
require_once '../helpers/response.php';

$pdo = Database::connect();

if (!isset($_GET['id'])) {

    jsonResponse(
        false,
        'Musolla ID required',
        null,
        400
    );
}

$id =
    intval(
        $_GET['id']
    );

try {

    $stmt =
        $pdo->prepare(
            "
            SELECT *
            FROM musollas
            WHERE id = ?
            "
        );

    $stmt->execute([
        $id
    ]);

    $musolla =
        $stmt->fetch(
            PDO::FETCH_ASSOC
        );

    if (!$musolla) {

        jsonResponse(
            false,
            'Musolla not found',
            null,
            404
        );
    }

    $imageStmt =
        $pdo->prepare(
            "
            SELECT
                id,
                image_path
            FROM musolla_images
            WHERE musolla_id = ?
            "
        );

    $imageStmt->execute([
        $id
    ]);

    $musolla['images'] =
        $imageStmt->fetchAll(
            PDO::FETCH_ASSOC
        );

    jsonResponse(
        true,
        'Musolla retrieved',
        $musolla
    );

}
catch (Exception $e) {

    jsonResponse(
        false,
        $e->getMessage(),
        null,
        500
    );
}
