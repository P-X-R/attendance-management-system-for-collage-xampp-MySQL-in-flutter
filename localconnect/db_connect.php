<?php
$servername = "localhost"; // Change if necessary
$username = "root"; // Default MySQL user in XAMPP
$password = ""; // Default XAMPP MySQL password is empty
$database = "localconnect"; // Replace with your actual DB name

$conn = mysqli_connect($servername, $username, $password, $database);

if (!$conn) {
    die("Database connection failed: " . mysqli_connect_error());
}
?>
