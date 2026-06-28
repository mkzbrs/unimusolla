<?php

require_once __DIR__ . '/../config/config.php';


function generateImageName(
    string $extension
): string {

    return uniqid(
        '',
        true
    ) . '.' . $extension;
}


function createDirectory(
    string $path
): void {

    if (!is_dir($path)) {

        mkdir(
            $path,
            0775,
            true
        );
    }
}


function uploadImage(
    array $file,
    string $destination
): ?string {

    createDirectory($destination);

    if (
        !isset($file['name']) ||
        !isset($file['tmp_name'])
    ) {
        return null;
    }

    $extension = strtolower(
        pathinfo(
            $file['name'],
            PATHINFO_EXTENSION
        )
    );

    $allowedExtensions = [
        'jpg',
        'jpeg',
        'png',
        'webp'
    ];

    if (
        !in_array(
            $extension,
            $allowedExtensions
        )
    ) {
        return null;
    }

    $mimeType = mime_content_type(
        $file['tmp_name']
    );

    if (
        !in_array(
            $mimeType,
            ALLOWED_IMAGE_TYPES
        )
    ) {
        return null;
    }

    $filename =
        generateImageName(
            $extension
        );

    $fullPath =
        $destination .
        '/' .
        $filename;

    if (
        move_uploaded_file(
            $file['tmp_name'],
            $fullPath
        )
    ) {

        return $filename;
    }

    return null;
}
