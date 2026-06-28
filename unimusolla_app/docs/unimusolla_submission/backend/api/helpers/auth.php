<?php

function hashPassword(
    string $password
): string {

    return password_hash(
        $password,
        PASSWORD_DEFAULT
    );
}


function verifyPassword(
    string $password,
    string $hash
): bool {

    return password_verify(
        $password,
        $hash
    );
}


function generateToken(
    int $userId
): string {

    $expiry = time() + (60 * 60 * 24 * 30);

    $signature = md5(
        $userId .
        $expiry .
        'unimusolla_secret'
    );

    return base64_encode(
        $userId .
        "|" .
        $expiry .
        "|" .
        $signature
    );
}


function verifyToken(
    string $token
): int|false {

    $decoded = base64_decode($token);

    if (!$decoded) {
        return false;
    }

    $parts = explode(
        '|',
        $decoded
    );

    if (count($parts) !== 3) {
        return false;
    }

    $userId = $parts[0];
    $expiry = $parts[1];
    $signature = $parts[2];

    if (time() > $expiry) {
        return false;
    }

    $expected = md5(
        $userId .
        $expiry .
        'unimusolla_secret'
    );

    if ($signature !== $expected) {
        return false;
    }

    return (int)$userId;
}
