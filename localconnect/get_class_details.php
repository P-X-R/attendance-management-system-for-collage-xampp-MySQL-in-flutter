<?php
include 'db_connect.php';

header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['department_id'], $_GET['semester'])) {
    $department_id = $_GET['department_id'];
    $semester = $_GET['semester'];

    $stmt = $conn->prepare("SELECT id, class_name FROM classes WHERE department_id = ? AND semester = ?");
    $stmt->bind_param("ii", $department_id, $semester);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $class = $result->fetch_assoc();
        echo json_encode(["success" => true, "class" => $class]);
    } else {
        echo json_encode(["success" => false, "message" => "Class not found"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request"]);
}

$conn->close();
?>
