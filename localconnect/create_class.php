<?php
include 'db_connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $department = $_POST['department'];
    $semester = $_POST['semester'];

    $sql = "INSERT INTO classes (department_id, semester) VALUES ((SELECT id FROM departments WHERE name = ?), ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $department, $semester);
    
    if ($stmt->execute()) {
        echo json_encode(["message" => "Class created successfully"]);
    } else {
        echo json_encode(["message" => "Failed to create class"]);
    }

    $stmt->close();
    $conn->close();
}
?>
