<?php
include 'db_connect.php'; // Include your DB connection

header('Content-Type: application/json');

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $action = $_POST['action'];

    if ($action == "promote") {
        $sql = "UPDATE students SET semester = 
                CASE 
                    WHEN semester = 'S9' THEN 'GRADUATED' 
                    ELSE CONCAT('S', CAST(SUBSTRING(semester, 2) AS UNSIGNED) + 1) 
                END";
    } elseif ($action == "demote") {
        $sql = "UPDATE students SET semester = 
                CASE 
                    WHEN semester = 'S0' THEN 'S0' 
                    ELSE CONCAT('S', CAST(SUBSTRING(semester, 2) AS UNSIGNED) - 1) 
                END";
    } else {
        echo json_encode(["success" => false, "message" => "Invalid action"]);
        exit();
    }

    if (mysqli_query($conn, $sql)) {
        echo json_encode(["success" => true, "message" => "Students updated successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error updating students"]);
    }

    mysqli_close($conn);
} else {
    echo json_encode(["success" => false, "message" => "Invalid request"]);
}
?>
