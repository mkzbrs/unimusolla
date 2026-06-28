<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/validator.php';
require_once __DIR__ . '/../helpers/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(false, 'Method not allowed', null, 405);
}

$input = json_decode(file_get_contents('php://input'), true);

$missing = requiredFields(
    $input,
    ['email', 'password']
);

if (!empty($missing)) {

    jsonResponse(
        false,
        'Missing fields: ' . implode(', ', $missing),
        null,
        400
    );
}

$email = trim($input['email']);
$password = trim($input['password']);

try {

    $db = Database::connect();

    $stmt = $db->prepare(
        'SELECT *
         FROM users
         WHERE email = ?'
    );

    $stmt->execute([$email]);

    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {

        jsonResponse(
            false,
            'Invalid email or password',
            null,
            401
        );
    }

    if (
        !verifyPassword(
            $password,
            $user['password_hash']
        )
    ) {

        jsonResponse(
            false,
            'Invalid email or password',
            null,
            401
        );
    }

    $token = generateToken(
    	$user['id']
    );

    unset($user['password_hash']);

    http_response_code(200);

    header('Content-Type: application/json');

    echo json_encode([
    	'success' => true,
    	'message' => 'Login successful',
    	'token' => $token,
    	'user' => $user
    ]);

} catch (Exception $e) {

    jsonResponse(
        false,
        $e->getMessage(),
        null,
        500
    );
}
