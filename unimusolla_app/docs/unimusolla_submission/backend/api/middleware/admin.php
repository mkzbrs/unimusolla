<?php

require_once __DIR__.'/auth.php';


if (
    $currentUser['role']
    !== 'admin'
) {

    jsonResponse(
        false,
        'Admin only',
        null,
        403
    );
}
