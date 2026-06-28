<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';

$db=Database::connect();

$users=$db->query(
'SELECT COUNT(*) FROM users'
)->fetchColumn();

$musollas=$db->query(
'SELECT COUNT(*) FROM musollas'
)->fetchColumn();

$pending=$db->query(
"
SELECT COUNT(*)
FROM pending_musollas
WHERE approval_status='pending'
"
)->fetchColumn();

jsonResponse(
true,
'Dashboard',
[
'users'=>$users,
'musollas'=>$musollas,
'pending_reports'=>$pending
]
);
