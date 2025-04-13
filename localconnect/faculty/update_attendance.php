<?php
header("Content-Type: application/json");
require_once '../db_connect.php';

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Log the raw input for debugging
file_put_contents('debug.log', "Input received: " . file_get_contents('php://input') . "\n", FILE_APPEND);

// Get the raw POST data first
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Validate JSON
if (json_last_error() !== JSON_ERROR_NONE) {
    $error = 'Invalid JSON: ' . json_last_error_msg();
    file_put_contents('debug.log', "JSON error: $error\n", FILE_APPEND);
    echo json_encode(['success' => false, 'error' => $error]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $error = 'Only POST requests allowed';
    file_put_contents('debug.log', "Request method error: $error\n", FILE_APPEND);
    echo json_encode(['success' => false, 'error' => $error]);
    exit;
}

// Required fields validation
$required = ['faculty_id', 'semester_id', 'subject_id', 'records'];
foreach ($required as $field) {
    if (!isset($data[$field])) {
        $error = "Missing required field: $field";
        file_put_contents('debug.log', "Validation error: $error\n", FILE_APPEND);
        echo json_encode(['success' => false, 'error' => $error]);
        exit;
    }
}

// Database connection
$conn = mysqli_connect("localhost", "root", "", "localconnect");
if (!$conn) {
    $error = 'Database connection failed: ' . mysqli_connect_error();
    file_put_contents('debug.log', "DB connection error: $error\n", FILE_APPEND);
    echo json_encode(['success' => false, 'error' => $error]);
    exit;
}

try {
    mysqli_autocommit($conn, false); // Start transaction
    
    $facultyId = (int)$data['faculty_id'];
    $semesterId = (int)$data['semester_id'];
    $subjectId = (int)$data['subject_id'];
    
    foreach ($data['records'] as $student) {
        $studentId = (int)$student['id'];
        if (empty($studentId)) continue;
        
        foreach ($student['attendance'] as $record) {
            if (!isset($record['date'], $record['hours'], $record['status'])) {
                mysqli_rollback($conn);
                $error = 'Invalid record format';
                file_put_contents('debug.log', "Record format error: $error\n", FILE_APPEND);
                echo json_encode(['success' => false, 'error' => $error]);
                exit;
            }
            
            $attendanceDate = date('Y-m-d', strtotime($record['date']));
            $hours = (int)$record['hours'];
            $status = $record['status'] === 'present' ? 'present' : 'absent';
            
            // 1. Handle main attendance record
            $attendanceId = findOrCreateAttendanceRecord($conn, $facultyId, $semesterId, $subjectId, $attendanceDate, $hours);
            
            if (!$attendanceId) {
                throw new Exception("Failed to create attendance record");
            }
            
            // 2. Update attendance details
            if (!updateAttendanceDetails($conn, $attendanceId, $studentId, $status)) {
                throw new Exception("Failed to update attendance details");
            }
        }
    }
    
    mysqli_commit($conn);
    file_put_contents('debug.log', "Update successful\n", FILE_APPEND);
    echo json_encode(['success' => true]);
    
} catch (Exception $e) {
    mysqli_rollback($conn);
    file_put_contents('debug.log', "Exception: " . $e->getMessage() . "\n", FILE_APPEND);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
} finally {
    mysqli_close($conn);
}

function findOrCreateAttendanceRecord($conn, $facultyId, $semesterId, $subjectId, $date, $hours) {
    // Check if exists with the same hours
    $query = "SELECT attendance_id FROM attendance 
              WHERE subject_id = $subjectId 
              AND attendance_date = '$date'
              AND faculty_id = $facultyId
              AND semester_id = $semesterId
              AND hours = $hours";
    
    $result = mysqli_query($conn, $query);
    
    if (!$result) {
        throw new Exception("Query failed: " . mysqli_error($conn));
    }
    
    if (mysqli_num_rows($result)) {
        $row = mysqli_fetch_assoc($result);
        return $row['attendance_id'];
    }
    
    // Create new with ON DUPLICATE KEY UPDATE
    $insert = "INSERT INTO attendance 
              (faculty_id, semester_id, subject_id, attendance_date, hours) 
              VALUES ($facultyId, $semesterId, $subjectId, '$date', $hours)
              ON DUPLICATE KEY UPDATE hours = VALUES(hours)";
    
    if (!mysqli_query($conn, $insert)) {
        throw new Exception("Insert failed: " . mysqli_error($conn));
    }
    return mysqli_insert_id($conn);
}

function updateAttendanceDetails($conn, $attendanceId, $studentId, $status) {
    // Check if exists
    $query = "SELECT id FROM attendance_details 
              WHERE attendance_id = $attendanceId AND student_id = $studentId";
    $result = mysqli_query($conn, $query);
    
    if (!$result) {
        throw new Exception("Query failed: " . mysqli_error($conn));
    }
    
    if (mysqli_num_rows($result)) {
        $row = mysqli_fetch_assoc($result);
        $update = "UPDATE attendance_details SET status = '$status' 
                   WHERE id = {$row['id']}";
        return mysqli_query($conn, $update);
    } else {
        $insert = "INSERT INTO attendance_details 
                  (attendance_id, student_id, status) 
                  VALUES ($attendanceId, $studentId, '$status')";
        return mysqli_query($conn, $insert);
    }
}
?>