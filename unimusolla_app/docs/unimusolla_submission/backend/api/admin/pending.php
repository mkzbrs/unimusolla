<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';

$db = Database::connect();

$data = $db->query(
"
SELECT *
FROM reports
WHERE approval_status='pending'
ORDER BY submitted_at DESC
"
)->fetchAll();

jsonResponse(
    true,
    'Pending reports',
    $data
);
