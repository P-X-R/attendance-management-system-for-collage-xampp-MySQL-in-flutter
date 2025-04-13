<?php
header("Content-Type: application/json");
include('db_connection.php');

$facultyId = $_POST['faculty_id'];

$query = "SELECT 
            sf.subject_id, 
            s.subject_name, 
            sf.semester as semester_id
          FROM subjects_faculty sf
          JOIN subjects s ON sf.subject_id = s.id
          WHERE sf.faculty_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $facultyId);
$stmt->execute();
$result = $stmt->get_result();

$subjects = [];
while ($row = $result->fetch_assoc()) {
    $subjects[] = $row;
}

echo json_encode([
    'success' => true,
    'subjects' => $subjects
]);
?>