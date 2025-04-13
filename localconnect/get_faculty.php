<?php
include 'db_connect.php';

$department = isset($_GET['department']) ? $_GET['department'] : '';

if (empty($department)) {
    echo json_encode(["error" => "Department parameter is missing"]);
    exit();
}

$sql = "SELECT name, email FROM faculty WHERE department_id = 
        (SELECT depid FROM departments WHERE name = ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $department);
$stmt->execute();
$result = $stmt->get_result();

$faculty = array();
while ($row = $result->fetch_assoc()) {
    $faculty[] = $row;
}

if (empty($faculty)) {
    echo json_encode(["message" => "No faculty found for this department"]);
} else {
    echo json_encode($faculty);
}
?>
