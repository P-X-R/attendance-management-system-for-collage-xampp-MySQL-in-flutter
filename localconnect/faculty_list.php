<?php
header('Content-Type: application/json');

// Database connection
$conn = new mysqli("localhost", "root", "", "localconnect");

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed"]));
}

$department = $_GET['department'] ?? '';

$query = "SELECT f.name FROM faculty f 
          JOIN departments d ON f.department_id = d.depid 
          WHERE d.name = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $department);
$stmt->execute();
$result = $stmt->get_result();

$facultyList = [];
while ($row = $result->fetch_assoc()) {
    $facultyList[] = $row['name']; // Extract only faculty names
}

echo json_encode(["faculty" => $facultyList]); // ✅ Fix JSON format

$conn->close();
?>
