<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "localconnect";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode([
        "status" => "Error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit();
}

$faculty_id = $_POST['faculty_id'] ?? '';

if (empty($faculty_id)) {
    echo json_encode([
        "status" => "Error",
        "message" => "Missing faculty ID"
    ]);
    exit();
}

$faculty_id_int = (int)$faculty_id;

error_log("Received Faculty ID: $faculty_id_int");

// Check if faculty ID exists
$check_sql = "SELECT * FROM subjects_faculty WHERE faculty_id = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("i", $faculty_id_int);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

if ($check_result->num_rows === 0) {
    echo json_encode([
        "status" => "Error",
        "message" => "No subjects found for faculty ID: $faculty_id_int"
    ]);
    $check_stmt->close();
    $conn->close();
    exit();
}

// Fetch subjects if faculty ID exists
$sql = "SELECT sf.subject_id, s.subject_name, sf.semester, d.name AS department
        FROM subjects_faculty AS sf 
        JOIN subjects AS s ON sf.subject_id = s.id 
        JOIN departments AS d ON sf.department_id = d.id
        WHERE sf.faculty_id = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $faculty_id_int);
$stmt->execute();
$result = $stmt->get_result();

$subjects = [];
while ($row = $result->fetch_assoc()) {
    $subjects[] = $row;
}

if (count($subjects) > 0) {
    echo json_encode($subjects);
} else {
    echo json_encode([
        "status" => "Error",
        "message" => "No subjects found"
    ]);
}

$stmt->close();
$conn->close();
?>
