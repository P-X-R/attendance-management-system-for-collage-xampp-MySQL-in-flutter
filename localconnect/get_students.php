<?php
header("Content-Type: application/json");
include 'db_connect.php'; // Ensure correct database connection

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $department = $_POST['department'] ?? '';
    $semester = $_POST['semester'] ?? '';

    if (empty($department) || empty($semester)) {
        echo json_encode(["error" => "Missing parameters"]);
        exit;
    }

    $sql = "SELECT s.name FROM students s 
            JOIN departments d ON s.department_id = d.depid 
            WHERE d.name = ? AND s.semester = ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $department, $semester);
    $stmt->execute();
    $result = $stmt->get_result();

    $students = [];
    while ($row = $result->fetch_assoc()) {
        $students[] = $row['name'];
    }

    echo json_encode(["students" => $students]);
    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["error" => "Invalid request method"]);
}
?>
