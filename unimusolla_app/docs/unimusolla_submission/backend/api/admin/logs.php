<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';

$db=Database::connect();

$data=$db->query(
"
SELECT *
FROM admin_logs
ORDER BY id DESC
"
)->fetchAll();

jsonResponse(
true,
'Logs',
$data
);
