<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php'; // Ensure this file connects to your database

// Check if department_id and semester are provided
if (!isset($_GET['department_id']) || !isset($_GET['semester'])) {
    echo json_encode(["success" => false, "message" => "Missing required parameters"]);
    exit();
}

$department_id = intval($_GET['department_id']);
$semester = intval($_GET['semester']);

// Fetch subjects for the given department and semester
$query = "SELECT id, subject_name FROM subjects WHERE department_id = ? AND semester = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ii", $department_id, $semester);
$stmt->execute();
$result = $stmt->get_result();

$subjects = [];
while ($row = $result->fetch_assoc()) {
    $subjects[] = $row;
}

$stmt->close();
$conn->close();

// Return subjects as JSON
echo json_encode(["success" => true, "subjects" => $subjects]);
?>
