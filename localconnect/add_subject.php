<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include 'db_connect.php'; // Ensure this file connects to your database

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['department_id'], $data['semester'], $data['subject_name'])) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit();
}

$department_id = intval($data['department_id']);
$semester = intval($data['semester']);
$subject_name = trim($data['subject_name']);

// Check if the subject already exists
$checkQuery = "SELECT id FROM subjects WHERE department_id = ? AND semester = ? AND subject_name = ?";
$stmt = $conn->prepare($checkQuery);
$stmt->bind_param("iis", $department_id, $semester, $subject_name);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Subject already exists for this semester"]);
    exit();
}

$stmt->close();

// Insert new subject
$insertQuery = "INSERT INTO subjects (department_id, semester, subject_name) VALUES (?, ?, ?)";
$stmt = $conn->prepare($insertQuery);
$stmt->bind_param("iis", $department_id, $semester, $subject_name);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Subject added successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to add subject"]);
}

$stmt->close();
$conn->close();
?>
