<?php

function requiredFields(
    array $input,
    array $fields
): array {

    $missing = [];

    foreach ($fields as $field) {

        if (
            !isset($input[$field]) ||
            trim($input[$field]) === ''
        ) {

            $missing[] = $field;
        }
    }

    return $missing;
}


function validEmail(string $email): bool
{
    return filter_var(
        $email,
        FILTER_VALIDATE_EMAIL
    ) !== false;
}
