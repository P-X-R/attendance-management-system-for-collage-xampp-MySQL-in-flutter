<?php
header('Content-Type: application/json');
include '../db_connect.php';

$required = ['faculty_id', 'subject_id', 'attendance_date', 'hours'];
foreach ($required as $field) {
    if (!isset($_POST[$field])) {
        http_response_code(400);
        die(json_encode(['error' => "Missing $field parameter"]));
    }
}

$stmt = $conn->prepare("
    SELECT 1 FROM attendance 
    WHERE faculty_id = ? 
    AND subject_id = ? 
    AND attendance_date = ? 
    AND hours = ?
    LIMIT 1
");
$stmt->bind_param(
    "iisi",
    $_POST['faculty_id'],
    $_POST['subject_id'],
    $_POST['attendance_date'],
    $_POST['hours']
);
$stmt->execute();

echo json_encode([
    'exists' => $stmt->get_result()->num_rows > 0
]);
?>