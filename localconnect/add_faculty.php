<?php
header('Content-Type: application/json');
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (!isset($_POST['name'], $_POST['username'], $_POST['email'], $_POST['password'], $_POST['department_id'])) {
        echo json_encode(["success" => false, "message" => "Missing required fields"]);
        exit;
    }

    $name = trim($_POST['name']);
    $username = trim($_POST['username']);
    $email = trim($_POST['email']);
    $password = trim($_POST['password']);  // No hashing
    $department_id = trim($_POST['department_id']);

    // Check if department exists
    $checkDeptQuery = "SELECT depid FROM departments WHERE depid = ?";
    $stmtDept = mysqli_prepare($conn, $checkDeptQuery);
    mysqli_stmt_bind_param($stmtDept, "s", $department_id);
    mysqli_stmt_execute($stmtDept);
    mysqli_stmt_store_result($stmtDept);

    if (mysqli_stmt_num_rows($stmtDept) == 0) {
        echo json_encode(["success" => false, "message" => "Invalid department"]);
        exit;
    }

    mysqli_begin_transaction($conn);

    try {
        // Insert into users table without hashing the password
        $userQuery = "INSERT INTO users (username, password, role) VALUES (?, ?, 'faculty')";
        $stmt = mysqli_prepare($conn, $userQuery);
        mysqli_stmt_bind_param($stmt, "ss", $username, $password);
        mysqli_stmt_execute($stmt);

        if (mysqli_stmt_affected_rows($stmt) > 0) {
            $user_id = mysqli_insert_id($conn);

            // Insert into faculty table
            $facultyQuery = "INSERT INTO faculty (user_id, name, department_id, email) VALUES (?, ?, ?, ?)";
            $stmt2 = mysqli_prepare($conn, $facultyQuery);
            mysqli_stmt_bind_param($stmt2, "isss", $user_id, $name, $department_id, $email);
            mysqli_stmt_execute($stmt2);

            if (mysqli_stmt_affected_rows($stmt2) > 0) {
                mysqli_commit($conn);
                echo json_encode(["success" => true, "message" => "Faculty added successfully"]);
                exit;
            }
        }

        mysqli_rollback($conn);
        echo json_encode(["success" => false, "message" => "Failed to insert faculty data"]);
    } catch (Exception $e) {
        mysqli_rollback($conn);
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
}
?>
