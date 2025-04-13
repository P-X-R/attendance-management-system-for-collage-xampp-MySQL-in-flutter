<?php
include 'db_connect.php'; // Ensure this connects to your database

if(isset($_POST['username'])) {
    $username = $_POST['username'];
    $id = $_POST['id'];

    // Fetch admin name from admin table
    $query = "SELECT name FROM admin WHERE user_id = (SELECT id FROM users WHERE username = '$username');";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode(["status" => "Success", "name" => $row['name']]);
    } else {
        echo json_encode(["status" => "Error", "message" => "Admin not found"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "Error", "message" => "Invalid Request"]);
}
?>
