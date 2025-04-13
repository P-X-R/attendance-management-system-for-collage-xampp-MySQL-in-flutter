<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "localconnect");

// Get student details including department and semester
$studentId = $_POST['student_id'];
$studentQuery = "SELECT 
                  s.id as student_id, 
                  s.name as student_name,
                  s.department_id as dep_code,
                  d.name as department_name,
                  s.semester_st as semester
                FROM students s
                JOIN departments d ON s.department_id = d.depid
                WHERE s.id = ?";

$stmt = $conn->prepare($studentQuery);
$stmt->bind_param("i", $studentId);
$stmt->execute();
$student = $stmt->get_result()->fetch_assoc();

// Get all subjects for the student's department-semester
$subjectQuery = "SELECT 
                  s.id as subject_id,
                  s.subject_name,
                  s.semester,
                  sf.faculty_id,
                  f.name as faculty_name
                FROM subjects s
                LEFT JOIN subjects_faculty sf ON s.id = sf.subject_id 
                  AND sf.department_id = (SELECT id FROM departments WHERE depid = ?)
                  AND sf.semester = ?
                LEFT JOIN faculty f ON sf.faculty_id = f.id
                WHERE s.department_id = (SELECT id FROM departments WHERE depid = ?)
                AND s.semester = ?";

$stmt = $conn->prepare($subjectQuery);
$stmt->bind_param("sisi", 
  $student['dep_code'], 
  $student['semester'],
  $student['dep_code'], 
  $student['semester']
);
$stmt->execute();
$subjects = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

echo json_encode([
  'student' => [
    'id' => $student['student_id'],
    'name' => $student['student_name'],
    'department' => $student['department_name']
  ],
  'subjects' => $subjects
]);
?>