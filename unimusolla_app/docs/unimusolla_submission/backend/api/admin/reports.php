<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';


$status = $_GET['status'] ?? 'pending';


$db = Database::connect();


$stmt = $db->prepare(
"
SELECT *
FROM reports
WHERE approval_status = ?
ORDER BY submitted_at DESC
"
);

$stmt->execute([
    $status
]);


$reports = $stmt->fetchAll();


jsonResponse(
    true,
    'Reports loaded',
    $reports
);
