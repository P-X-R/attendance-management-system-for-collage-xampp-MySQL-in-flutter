<?php
header('Content-Type: application/json');
include '../db_connect.php';

// Verify semester parameter exists
if (!isset($_GET['semester'])) {
    http_response_code(400);
    die(json_encode(['error' => 'Semester parameter is required']));
}

$semester = trim($_GET['semester']);

// Accept both formats (S2 or 2)
if (is_numeric($semester)) {
    $semester_num = (int)$semester;
    $semester_str = 'S'.$semester_num;
} else {
    if (!preg_match('/^S[1-8]$/', $semester)) {
        http_response_code(400);
        die(json_encode(['error' => 'Invalid semester format. Must be S1-S8 or 1-8']));
    }
    $semester_num = (int) substr($semester, 1);
    $semester_str = $semester;
}

try {
    // Query using both semester fields
    $stmt = $conn->prepare("
        SELECT id, user_id, name, department_id, email, semester, semester_st 
        FROM students 
        WHERE semester = ? OR semester_st = ?
        ORDER BY name ASC
    ");
    
    if (!$stmt) {
        throw new Exception("Query preparation failed: " . $conn->error);
    }

    $stmt->bind_param("si", $semester_str, $semester_num);
    
    if (!$stmt->execute()) {
        throw new Exception("Query execution failed: " . $stmt->error);
    }

    $result = $stmt->get_result();
    $students = $result->fetch_all(MYSQLI_ASSOC);

    echo json_encode([
        'success' => true,
        'students' => $students,
        'debug' => [
            'received_semester' => $_GET['semester'],
            'used_string' => $semester_str,
            'used_number' => $semester_num
        ]
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>