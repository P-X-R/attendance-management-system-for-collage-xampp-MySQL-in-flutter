<?php
header('Content-Type: application/json');
include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    if (!isset($data['students']) || !is_array($data['students'])) {
        echo json_encode(["success" => false, "message" => "Invalid data format"]);
        exit;
    }

    mysqli_begin_transaction($conn);
    try {
        foreach ($data['students'] as $student) {
            $name = trim($student['name']);
            $username = trim($student['username']);
            $email = trim($student['email']);
            $password = trim($student['password']); // Consider hashing this
            $department_id = trim($student['department_id']);
            $semester = trim($student['semester']);

            // Check if department exists
            $checkDeptQuery = "SELECT depid FROM departments WHERE depid = ?";
            $stmtDept = mysqli_prepare($conn, $checkDeptQuery);
            mysqli_stmt_bind_param($stmtDept, "s", $department_id);
            mysqli_stmt_execute($stmtDept);
            mysqli_stmt_store_result($stmtDept);

            if (mysqli_stmt_num_rows($stmtDept) == 0) {
                echo json_encode(["success" => false, "message" => "Invalid department ID"]);
                exit;
            }

            // Insert into `users` table
            $userQuery = "INSERT INTO users (username, password, role) VALUES (?, ?, 'student')";
            $stmtUser = mysqli_prepare($conn, $userQuery);
            mysqli_stmt_bind_param($stmtUser, "ss", $username, $password);
            mysqli_stmt_execute($stmtUser);

            if (mysqli_stmt_affected_rows($stmtUser) > 0) {
                $user_id = mysqli_insert_id($conn);

                // Insert into `students` table
                $studentQuery = "INSERT INTO students (user_id, name, department_id, email, semester) VALUES (?, ?, ?, ?, ?)";
                $stmtStudent = mysqli_prepare($conn, $studentQuery);
                mysqli_stmt_bind_param($stmtStudent, "issss", $user_id, $name, $department_id, $email, $semester);
                mysqli_stmt_execute($stmtStudent);

                if (mysqli_stmt_affected_rows($stmtStudent) == 0) {
                    throw new Exception("Failed to insert student data");
                }
            } else {
                throw new Exception("Failed to insert user data");
            }
        }

        mysqli_commit($conn);
        echo json_encode(["success" => true, "message" => "Students added successfully"]);
    } catch (Exception $e) {
        mysqli_rollback($conn);
        echo json_encode(["success" => false, "message" => $e->getMessage()]);
    }
}
?>
