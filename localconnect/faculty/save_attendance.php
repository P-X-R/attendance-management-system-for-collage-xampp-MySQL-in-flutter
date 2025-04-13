<?php
header('Content-Type: application/json');
include '../db_connect.php';

// Validate input
$required = ['faculty_id', 'semester_id', 'subject_id', 'hours', 'attendance_date', 'students'];
foreach ($required as $field) {
    if (!isset($_POST[$field])) {
        http_response_code(400);
        die(json_encode(['error' => "Missing $field parameter"]));
    }
}

// Additional validation for hours
if (!is_numeric($_POST['hours']) || $_POST['hours'] < 1 || $_POST['hours'] > 6) {
    http_response_code(400);
    die(json_encode(['error' => "Invalid hours value (must be 1-6)"]));
}

try {
    $conn->begin_transaction();
    
    // 1. Check for existing attendance session
    $check_session = $conn->prepare("
        SELECT attendance_id FROM attendance 
        WHERE faculty_id = ? 
        AND subject_id = ? 
        AND attendance_date = ? 
        AND hours = ?
        LIMIT 1
    ");
    $check_session->bind_param(
        "iisi",
        $_POST['faculty_id'],
        $_POST['subject_id'],
        $_POST['attendance_date'],
        $_POST['hours']
    );
    $check_session->execute();
    
    if ($check_session->get_result()->num_rows > 0) {
        throw new Exception('Attendance already recorded for this subject/hour combination today');
    }

    // 2. Insert main attendance record
    $stmt = $conn->prepare("
        INSERT INTO attendance 
        (faculty_id, semester_id, subject_id, attendance_date, hours)
        VALUES (?, ?, ?, ?, ?)
    ");
    $stmt->bind_param(
        "iiisi",
        $_POST['faculty_id'],
        $_POST['semester_id'],
        $_POST['subject_id'],
        $_POST['attendance_date'],
        $_POST['hours']
    );
    $stmt->execute();
    $attendance_id = $conn->insert_id;
    
    // 3. Validate student data
    $students = json_decode($_POST['students'], true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception('Invalid student data format');
    }
    
    $student_ids = array_column($students, 'id');
    if (count($student_ids) !== count(array_unique($student_ids))) {
        throw new Exception('Duplicate student entries detected');
    }

    // 4. Insert attendance details with duplicate check
    $detailStmt = $conn->prepare("
        INSERT INTO attendance_details 
        (attendance_id, student_id, status)
        VALUES (?, ?, ?)
    ");
    
    $check_student_stmt = $conn->prepare("
        SELECT 1 FROM attendance_details 
        WHERE attendance_id = ? AND student_id = ?
        LIMIT 1
    ");
    
    foreach ($students as $student) {
        // Check for existing student entry
        $check_student_stmt->bind_param("ii", $attendance_id, $student['id']);
        $check_student_stmt->execute();
        if ($check_student_stmt->get_result()->num_rows > 0) {
            throw new Exception("Student {$student['id']} already exists in this attendance");
        }
        
        $status = $student['present'] ? 'present' : 'absent';
        $detailStmt->bind_param(
            "iis",
            $attendance_id,
            $student['id'],
            $status
        );
        $detailStmt->execute();
    }
    
    $conn->commit();
    echo json_encode(['success' => true, 'attendance_id' => $attendance_id]);
    
} catch (Exception $e) {
    $conn->rollback();
    http_response_code(409); // Conflict status code for duplicates
    echo json_encode(['error' => $e->getMessage()]);
}
?>