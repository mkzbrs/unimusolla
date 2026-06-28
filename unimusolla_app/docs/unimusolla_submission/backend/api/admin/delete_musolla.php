<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';

$input = json_decode(
    file_get_contents('php://input'),
    true
);

$id = $input['id'] ?? null;

if (!$id) {

    jsonResponse(
        false,
        'Missing id',
        null,
        400
    );

}

$db = Database::connect();

try {

    $db->beginTransaction();

    /*
    |--------------------------------------------------------------------------
    | CHECK MUSOLLA EXISTS
    |--------------------------------------------------------------------------
    */

    $stmt = $db->prepare(
    "
    SELECT *
    FROM musollas
    WHERE id=?
    "
    );

    $stmt->execute([$id]);

    $musolla = $stmt->fetch();

    if (!$musolla) {

        $db->rollBack();

        jsonResponse(
            false,
            'Musolla not found',
            null,
            404
        );

    }

    /*
    |--------------------------------------------------------------------------
    | DELETE MUSOLLA
    |--------------------------------------------------------------------------
    |
    | Foreign keys will automatically delete:
    | - musolla_images
    | - reports
    | - report_images
    |--------------------------------------------------------------------------
    */

    $db->prepare(
    "
    DELETE FROM musollas
    WHERE id=?
    "
    )->execute([$id]);

    $db->commit();

    jsonResponse(
        true,
        'Musolla deleted successfully'
    );

} catch (Exception $e) {

    $db->rollBack();

    jsonResponse(
        false,
        $e->getMessage(),
        null,
        500
    );

}
