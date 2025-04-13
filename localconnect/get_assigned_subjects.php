<?php
include 'db_connect.php';

header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['class_id'])) {
    $class_id = $_GET['class_id'];

    $stmt = $conn->prepare("
        SELECT cs.id, s.subject_name, f.name AS faculty_name
        FROM class_subjects cs
        JOIN subjects s ON cs.subject_id = s.id
        JOIN faculty f ON cs.faculty_id = f.id
        WHERE cs.class_id = ?
    ");
    $stmt->bind_param("i", $class_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $subjects = [];
    while ($row = $result->fetch_assoc()) {
        $subjects[] = $row;
    }

    echo json_encode(["success" => true, "subjects" => $subjects]);
} else {
    echo json_encode(["success" => false, "message" => "Invalid request"]);
}

$conn->close();
?>
