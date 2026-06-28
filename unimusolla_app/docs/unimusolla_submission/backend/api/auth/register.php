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
    ['username','email', 'password']
);

if (!empty($missing)) {
    jsonResponse(
        false,
        'Missing fields: ' . implode(', ', $missing),
        null,
        400
    );
}

$username =trim($input['username']);
$email = trim($input['email']);
$password = trim($input['password']);

if (!validEmail($email)) {
    jsonResponse(false, 'Invalid email format', null, 400);
}

if (strlen($password) < 6) {
    jsonResponse(
        false,
        'Password must be at least 6 characters',
        null,
        400
    );
}

try {

    $db = Database::connect();

    $check = $db->prepare(
        'SELECT id FROM users WHERE email = ?'
    );

    $check->execute([$email]);

    if ($check->fetch()) {
        jsonResponse(
            false,
            'Email already registered',
            null,
            409
        );
    }

    $stmt = $db->prepare(
        'INSERT INTO users (username, email, password_hash)
         VALUES (?, ?, ?)'
    );

    $stmt->execute([
	$username,
        $email,
        hashPassword($password)
    ]);

    jsonResponse(
        true,
        'Registration successful'
    );

} catch (Exception $e) {

    jsonResponse(
        false,
        $e->getMessage(),
        null,
        500
    );
}
