<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "localconnect");

// Get POST data
$studentId = $_POST['student_id'] ?? '';
$subjectId = $_POST['subject_id'] ?? '';
$semester = $_POST['semester'] ?? '';
$startDate = $_POST['start_date'] ?? '';
$endDate = $_POST['end_date'] ?? '';

// Validate required parameters
if (empty($studentId) || empty($subjectId) || empty($semester)) {
    echo json_encode(["error" => "Missing required parameters"]);
    exit();
}

// Base query
$query = "SELECT 
            a.attendance_date, 
            a.hours,
            ad.status
          FROM attendance a
          JOIN attendance_details ad ON a.attendance_id = ad.attendance_id
          WHERE a.subject_id = ?
          AND a.semester_id = ?
          AND ad.student_id = ?";

// Add date range filter if provided
if (!empty($startDate) && !empty($endDate)) {
    $query .= " AND a.attendance_date BETWEEN ? AND ?";
    $paramTypes = "iiiss";
    $params = [$subjectId, $semester, $studentId, $startDate, $endDate];
} else {
    $paramTypes = "iii";
    $params = [$subjectId, $semester, $studentId];
}

$query .= " ORDER BY a.attendance_date DESC";

$stmt = $conn->prepare($query);
if (!$stmt) {
    echo json_encode(["error" => "Prepare failed: " . $conn->error]);
    exit();
}

$stmt->bind_param($paramTypes, ...$params);

if (!$stmt->execute()) {
    echo json_encode(["error" => "Execute failed: " . $stmt->error]);
    exit();
}

$result = $stmt->get_result();
$records = [];
$totalHours = 0;
$presentHours = 0;

while ($row = $result->fetch_assoc()) {
    $records[] = $row;
    $totalHours += $row['hours'];
    
    if ($row['status'] == 'present') {
        $presentHours += $row['hours'];
    }
}

$percentage = $totalHours > 0 ? ($presentHours / $totalHours) * 100 : 0;

echo json_encode([
    "success" => true,
    "records" => $records,
    "stats" => [
        "percentage" => $percentage,
        "total_hours" => $totalHours,
        "present_hours" => $presentHours
    ]
]);

$stmt->close();
$conn->close();
?>