<?php

require_once __DIR__.'/../middleware/admin.php';
require_once __DIR__.'/../config/database.php';
require_once __DIR__.'/../helpers/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {

    jsonResponse(
        false,
        'Method not allowed',
        null,
        405
    );
}

$input = json_decode(
    file_get_contents('php://input'),
    true
);

$reportId = $input['report_id'] ?? null;

if (!$reportId) {

    jsonResponse(
        false,
        'Report ID required',
        null,
        400
    );
}

try {

    $db = Database::connect();

    $stmt = $db->prepare(
        "
        SELECT *
        FROM reports
        WHERE id=?
        "
    );

    $stmt->execute([
        $reportId
    ]);

    $report = $stmt->fetch();

    if (!$report) {

        jsonResponse(
            false,
            'Report not found',
            null,
            404
        );
    }

    if ($report['approval_status'] !== 'pending') {

        jsonResponse(
            false,
            'Report already processed',
            null,
            400
        );
    }

    $db->prepare(
        "
        UPDATE reports
        SET
            approval_status='rejected',
            reviewed_by=?,
            reviewed_at=CURRENT_TIMESTAMP
        WHERE id=?
        "
    )->execute([
        $userId,
        $reportId
    ]);

    $db->prepare(
        "
        INSERT INTO admin_logs
        (
            admin_id,
            action,
            target_type,
            target_id
        )
        VALUES
        (
            ?,
            'rejected_report',
            'report',
            ?
        )
        "
    )->execute([
        $userId,
        $reportId
    ]);

    jsonResponse(
        true,
        'Rejected'
    );

} catch (Exception $e) {

    jsonResponse(
        false,
        $e->getMessage(),
        null,
        500
    );
}
