<?php
include("db_connect.php"); // Ensure this file exists

$response = array();

// Fetch departments
$deptQuery = "SELECT id, name FROM departments";
$deptResult = $conn->query($deptQuery);
$departments = array();
while ($row = $deptResult->fetch_assoc()) {
    $departments[] = $row;
}

// Fetch semesters
$semQuery = "SELECT id, semester FROM semesters";
$semResult = $conn->query($semQuery);
$semesters = array();
while ($row = $semResult->fetch_assoc()) {
    $semesters[] = $row;
}

$response['departments'] = $departments;
$response['semesters'] = $semesters;

header('Content-Type: application/json');
echo json_encode($response);
?>
