<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php';

$query = "SELECT id, name FROM faculty"; 
$result = $conn->query($query);

$faculty = [];
while ($row = $result->fetch_assoc()) {
    $faculty[] = $row;
}

$conn->close();

if (!empty($faculty)) {
    echo json_encode(["success" => true, "faculty" => $faculty]);
} else {
    echo json_encode(["success" => false, "message" => "No faculty found"]);
}
?>
