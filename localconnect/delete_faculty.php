<?php
header('Content-Type: application/json');

// Database connection
$conn = new mysqli("localhost", "root", "", "localconnect");

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed"]));
}

// Get faculty name from request
$data = json_decode(file_get_contents("php://input"), true);
$facultyName = $data['name'] ?? '';

if (empty($facultyName)) {
    echo json_encode(["error" => "Faculty name is required"]);
    exit;
}

// Start transaction
$conn->begin_transaction();

try {
    // Delete from both users and faculty using JOIN
    $query = "
        DELETE u, f 
        FROM users u 
        LEFT JOIN faculty f ON u.id = f.user_id 
        WHERE f.name = ?
    ";
    
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $facultyName);
    $stmt->execute();
    $stmt->close();

    // Commit transaction
    $conn->commit();

    echo json_encode(["success" => true]);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["error" => "Failed to delete faculty and associated records"]);
}

$conn->close();
?>
