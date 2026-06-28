<?php

date_default_timezone_set(
    'Asia/Kuala_Lumpur'
);

define(
    'APP_NAME',
    'UniMusolla'
);

define(
    'DB_PATH',
    '/database/unimusolla.db'
);

define(
    'UPLOAD_PATH',
    '/var/www/html/uploads'
);

define(
    'PROFILE_UPLOAD_PATH',
    '/var/www/html/uploads/profiles'
);

define(
    'REPORT_UPLOAD_PATH',
    '/var/www/html/uploads/reports'
);

define(
    'MUSOLLA_UPLOAD_PATH',
    '/var/www/html/uploads/musollas'
);

define(
    'MAX_IMAGE_SIZE',
    5 * 1024 * 1024
);

define(
    'ALLOWED_IMAGE_TYPES',
    [
        'image/jpeg',
        'image/png',
        'image/webp'
    ]
);
