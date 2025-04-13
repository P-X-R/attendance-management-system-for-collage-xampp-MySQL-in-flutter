<?php
include 'db_connect.php'; // Ensure this includes DB connection

$data = json_decode(file_get_contents("php://input"), true);

$department_id = $data['department_id'];
$semester = $data['semester'];
$subject_id = $data['subject_id'];
$faculty_id = $data['faculty_id'];
$start_date = $data['start_date'];
$end_date = $data['end_date'];

if (!$department_id || !$semester || !$subject_id || !$faculty_id || !$start_date || !$end_date) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit;
}

// Insert assignment into database with start and end date
$query = "INSERT INTO subjects_faculty (department_id, semester, subject_id, faculty_id, start_date, end_date) 
          VALUES ('$department_id', '$semester', '$subject_id', '$faculty_id', '$start_date', '$end_date')";

if (mysqli_query($conn, $query)) {
    echo json_encode(["success" => true, "message" => "Faculty assigned successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to assign faculty"]);
}
?>
