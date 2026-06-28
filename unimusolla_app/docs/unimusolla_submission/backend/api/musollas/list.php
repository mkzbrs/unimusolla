<?php

require_once '../config/database.php';
require_once '../helpers/response.php';

$pdo = Database::connect();

try {

    $stmt = $pdo->query(
        "
        SELECT
            m.id,
            m.name,
            m.location,
            m.exact_location,
            m.latitude,
            m.longitude,
            m.status,
            m.has_wudhu,
            m.has_toilet,
            m.has_aircond,
            m.has_mats,
            m.has_telekung,
            m.created_at,

            (
                SELECT image_path
                FROM musolla_images
                WHERE musolla_id = m.id
                LIMIT 1
            ) AS thumbnail

        FROM musollas m

        ORDER BY m.name
        "
    );

    $musollas =
        $stmt->fetchAll(
            PDO::FETCH_ASSOC
        );

    jsonResponse(
        true,
        'Musollas retrieved',
        $musollas
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
