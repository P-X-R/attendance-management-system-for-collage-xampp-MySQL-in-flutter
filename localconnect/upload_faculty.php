<?php
header('Content-Type: application/json');
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // ✅ Debug: Log incoming data
    file_put_contents("debug_log.txt", print_r($data, true), FILE_APPEND);

    if (!isset($data['faculty']) || !is_array($data['faculty'])) {
        echo json_encode(["success" => false, "message" => "Invalid data format"]);
        exit;
    }

    mysqli_begin_transaction($conn);
    try {
        foreach ($data['faculty'] as $faculty) {
            $name = trim($faculty['name']);
            $username = trim($faculty['username']);
            $email = trim($faculty['email']);
            $password = trim($faculty['password']); // ❌ No Hashing
            $department_id = trim($faculty['department_id']);

            // ✅ Check if department exists
            $checkDeptQuery = "SELECT depid FROM departments WHERE depid = ?";
            $stmtDept = mysqli_prepare($conn, $checkDeptQuery);
            mysqli_stmt_bind_param($stmtDept, "s", $department_id);
            mysqli_stmt_execute($stmtDept);
            mysqli_stmt_store_result($stmtDept);

            if (mysqli_stmt_num_rows($stmtDept) == 0) {
                file_put_contents("debug_log.txt", "Skipping faculty - Invalid department ID: $department_id\n", FILE_APPEND);
                continue; // Skip this faculty member instead of exiting
            }

            // ✅ Insert into `users` table (Password stored as plain text)
            $userQuery = "INSERT INTO users (username, password, role) VALUES (?, ?, 'faculty')";
            $stmtUser = mysqli_prepare($conn, $userQuery);
            mysqli_stmt_bind_param($stmtUser, "ss", $username, $password);

            if (!mysqli_stmt_execute($stmtUser)) {
                throw new Exception("Error inserting user: " . mysqli_error($conn));
            }

            $user_id = mysqli_insert_id($conn);

            // ✅ Insert into `faculty` table
            $facultyQuery = "INSERT INTO faculty (user_id, name, email, department_id) VALUES (?, ?, ?, ?)";
            $stmtFaculty = mysqli_prepare($conn, $facultyQuery);
            mysqli_stmt_bind_param($stmtFaculty, "isss", $user_id, $name, $email, $department_id);

            if (!mysqli_stmt_execute($stmtFaculty)) {
                throw new Exception("Error inserting faculty: " . mysqli_error($conn));
            }
        }

        mysqli_commit($conn);
        echo json_encode(["success" => true, "message" => "Faculty added successfully"]);
    } catch (Exception $e) {
        mysqli_rollback($conn);
        file_put_contents("debug_log.txt", "Error: " . $e->getMessage() . "\n", FILE_APPEND);
        echo json_encode(["success" => false, "message" => $e->getMessage()]);
    }
}
?>
