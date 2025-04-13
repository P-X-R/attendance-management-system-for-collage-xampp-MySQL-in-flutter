<?php
include '../db_connect.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "localconnect";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["status" => "Error", "message" => "Database connection failed"]);
    exit();
}

// Get faculty username from request
$faculty_username = $_GET['username'] ?? '';

if (empty($faculty_username)) {
    echo json_encode(["status" => "Error", "message" => "Missing faculty username"]);
    exit();
}

// Fetch faculty details
$sql = "SELECT faculty_name, subject FROM faculty WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $faculty_username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $faculty_data = $result->fetch_assoc();
    echo json_encode([
        "status" => "Success",
        "faculty_name" => $faculty_data["faculty_name"],
        "subject" => $faculty_data["subject"]
    ]);
} else {
    echo json_encode(["status" => "Error", "message" => "Faculty not found"]);
}

$conn->close();
?>
