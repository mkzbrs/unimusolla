<?php

require_once '../config/database.php';
require_once '../helpers/response.php';

$pdo = Database::connect();

$query =
    $_GET['q']
    ?? '';

try {

    $stmt =
        $pdo->prepare(
            "
            SELECT
                *
            FROM musollas
            WHERE
                name LIKE ?
                OR location LIKE ?
                OR exact_location LIKE ?
            ORDER BY name
            "
        );

    $search =
        '%' .
        $query .
        '%';

    $stmt->execute([
        $search,
        $search,
        $search
    ]);

    jsonResponse(
        true,
        'Search completed',
        $stmt->fetchAll(
            PDO::FETCH_ASSOC
        )
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
