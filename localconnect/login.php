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

$input_username = $_POST['username'] ?? '';
$input_password = $_POST['password'] ?? '';

if (empty($input_username) || empty($input_password)) {
    echo json_encode([
        "status" => "Error",
        "message" => "Missing credentials"
    ]);
    exit();
}

$stmt = $conn->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
if (!$stmt) {
    echo json_encode([
        "status" => "Error",
        "message" => "Prepare statement failed: " . $conn->error
    ]);
    exit();
}
$stmt->bind_param("ss", $input_username, $input_password);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $response = [
        "status" => "Success",
        "role" => $row["role"]
    ];
    
    if ($row["role"] == "admin") {
        $response["admin_name"] = $row["username"];
    } elseif ($row["role"] == "faculty") {
        // Query the faculty table to get the actual faculty name
        $facultyStmt = $conn->prepare("SELECT name, id FROM faculty WHERE user_id = ?");
        if (!$facultyStmt) {
            echo json_encode([
                "status" => "Error",
                "message" => "Faculty statement prepare failed: " . $conn->error
            ]);
            exit();
        }
        $facultyStmt->bind_param("i", $row["id"]);
        $facultyStmt->execute();
        $facultyResult = $facultyStmt->get_result();
        if ($facultyResult && $facultyResult->num_rows > 0) {
            $facultyRow = $facultyResult->fetch_assoc();
            $response["faculty_name"] = $facultyRow["name"];
            $response["faculty_id"] = (string)$facultyRow["id"];
        } else {
            // Fallback to username if no record is found in the faculty table
            $response["faculty_name"] = $row["username"];
            $response["faculty_id"] = "";
        }
        $facultyStmt->close();
    } elseif ($row["role"] == "student") {
        // Query the students table to get the actual faculty name
        $studentStmt = $conn->prepare("SELECT name, id FROM students WHERE user_id = ?");
        if (!$studentStmt) {
            echo json_encode([
                "status" => "Error",
                "message" => "Student statement prepare failed: " . $conn->error
            ]);
            exit();
        }$studentStmt->bind_param("i", $row["id"]);
        $studentStmt->execute();
        $studentResult = $studentStmt->get_result();
        if ($studentResult && $studentResult->num_rows > 0) {
            $studentRow = $studentResult->fetch_assoc();
            $response["student_name"] = $studentRow["name"];
            $response["student_id"] = (string)$studentRow["id"];
        } else {
            // Fallback to username if no record is found in the faculty table
            $response["student_name"] = $row["username"];
            $response["student_id"] = "";
        }
        $studentStmt->close();
    }
    echo json_encode($response);
} else {
    echo json_encode([
        "status" => "Error",
        "message" => "Invalid credentials"
    ]);
}
$stmt->close();
$conn->close();
?>