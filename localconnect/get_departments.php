<?php
header('Content-Type: application/json');
include 'db_connect.php';

$query = "SELECT depid, name FROM departments";
$result = mysqli_query($conn, $query);

$departments = [];
while ($row = mysqli_fetch_assoc($result)) {
    $departments[] = $row;
}

echo json_encode($departments);
?>
