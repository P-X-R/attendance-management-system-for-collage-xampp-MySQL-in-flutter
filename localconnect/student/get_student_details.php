<?php
include 'db_connect.php'; // Ensure you have a proper database connection

header("Content-Type: application/json");

// Check if user ID is provided
if (!isset($_GET['user_id'])) {
    echo json_encode(["error" => "User ID is required"]);
    exit();
}

$user_id = $_GET['user_id'];

// Fetch student details using user_id
$sql = "SELECT students.name 
        FROM students 
        INNER JOIN users ON students.id = users.user_id 
        WHERE users.id = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $student = $result->fetch_assoc();
    echo json_encode(["success" => true, "name" => $student['name']]);
} else {
    echo json_encode(["error" => "Student not found"]);
}

$stmt->close();
$conn->close();
?>
