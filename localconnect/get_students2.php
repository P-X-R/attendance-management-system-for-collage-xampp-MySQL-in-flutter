<?php
include 'db_connect.php';
$result = $conn->query("SELECT id, name FROM students");
echo json_encode($result->fetch_all(MYSQLI_ASSOC));
?>
