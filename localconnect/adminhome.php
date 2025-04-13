<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "localconnect";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$query = "SELECT DISTINCT name FROM departments";
$result = $conn->query($query);

$departments = [];

while ($row = $result->fetch_assoc()) {
    $departments[] = $row['name'];
}

echo json_encode($departments);

$conn->close();
?>
