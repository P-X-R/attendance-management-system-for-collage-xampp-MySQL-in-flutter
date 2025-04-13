<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Database configuration with error checking [UNCHANGED]
$configFile = __DIR__ . '/../db_config.php';
if (!file_exists($configFile)) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "error" => "Database configuration file not found",
        "path" => $configFile
    ]);
    exit;
}

include $configFile;

// Verify all required database variables exist [UNCHANGED]
$requiredVars = ['servername', 'username', 'password', 'dbname'];
foreach ($requiredVars as $var) {
    if (!isset($$var)) {
        http_response_code(500);
        echo json_encode([
            "success" => false,
            "error" => "Database configuration incomplete",
            "missing" => $var
        ]);
        exit;
    }
}

try {
    // Create database connection [UNCHANGED]
    $conn = new PDO(
        "mysql:host=$servername;dbname=$dbname", 
        $username, 
        $password,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    // Get and validate input data [UNCHANGED]
    $input = file_get_contents('php://input');
    if ($input === false) {
        throw new Exception("Failed to read input data");
    }

    $data = json_decode($input, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception("Invalid JSON input: " . json_last_error_msg());
    }

    if (empty($data['subject_id'])) {
        throw new Exception("Subject ID is required");
    }

    // 1. Get total hours for the subject [UNCHANGED]
    $totalHoursSql = "SELECT SUM(hours) as subject_total_hours 
                     FROM attendance 
                     WHERE subject_id = :subject_id";

    $totalHoursParams = [':subject_id' => $data['subject_id']];

    if (!empty($data['faculty_id'])) {
        $totalHoursSql .= " AND faculty_id = :faculty_id";
        $totalHoursParams[':faculty_id'] = $data['faculty_id'];
    }

    if (!empty($data['semester_id'])) {
        $totalHoursSql .= " AND semester_id = :semester_id";
        $totalHoursParams[':semester_id'] = $data['semester_id'];
    }

    if (!empty($data['start_date']) && !empty($data['end_date'])) {
        $totalHoursSql .= " AND attendance_date BETWEEN :start_date AND :end_date";
        $totalHoursParams[':start_date'] = $data['start_date'];
        $totalHoursParams[':end_date'] = $data['end_date'];
    }

    $totalHoursStmt = $conn->prepare($totalHoursSql);
    $totalHoursStmt->execute($totalHoursParams);
    $totalHoursResult = $totalHoursStmt->fetch(PDO::FETCH_ASSOC);
    $subjectTotalHours = (int)($totalHoursResult['subject_total_hours'] ?? 0);

    // Build and execute query for attendance records [MODIFIED TO INCLUDE STUDENT ID]
    $sql = "SELECT 
                a.attendance_date,
                a.hours,
                s.id as student_id,
                s.name as student_name,
                ad.status
            FROM attendance a
            JOIN attendance_details ad ON a.attendance_id = ad.attendance_id
            JOIN students s ON ad.student_id = s.id
            WHERE a.subject_id = :subject_id";

    $params = [':subject_id' => $data['subject_id']];

    // Add optional filters [UNCHANGED]
    if (!empty($data['student_name'])) {
        $sql .= " AND s.name LIKE :student_name";
        $params[':student_name'] = '%' . $data['student_name'] . '%';
    }

    if (!empty($data['faculty_id'])) {
        $sql .= " AND a.faculty_id = :faculty_id";
        $params[':faculty_id'] = $data['faculty_id'];
    }

    if (!empty($data['semester_id'])) {
        $sql .= " AND a.semester_id = :semester_id";
        $params[':semester_id'] = $data['semester_id'];
    }

    if (!empty($data['start_date']) && !empty($data['end_date'])) {
        $sql .= " AND a.attendance_date BETWEEN :start_date AND :end_date";
        $params[':start_date'] = $data['start_date'];
        $params[':end_date'] = $data['end_date'];
    }

    $sql .= " ORDER BY s.name ASC, a.attendance_date DESC";

    $stmt = $conn->prepare($sql);
    if (!$stmt->execute($params)) {
        throw new Exception("Query execution failed");
    }
// ... [Previous code remains the same until the record processing section]

    // Process records [CORRECTED GROUPING LOGIC]
    $grouped = [];
    $student_counter = 1;
    $total_hours = 0;
    $student_ids = [];
    $all_attendance_dates = []; // Track all unique dates across students

    while ($record = $stmt->fetch(PDO::FETCH_ASSOC)) {
        if (!isset($record['student_id']) || !isset($record['student_name'])) {
            continue;
        }

        $student_id = $record['student_id'];
        $student_name = $record['student_name'];
        $attendance_date = $record['attendance_date'] ?? 'Unknown';
        $hours = (int)($record['hours'] ?? 0);
        $status = strtolower($record['status'] ?? 'unknown');
        
        // Initialize student record if not exists
        if (!isset($grouped[$student_id])) {
            $grouped[$student_id] = [
                'id' => $student_id,
                'number' => $student_counter++,
                'name' => $student_name,
                'attendance' => [],
                'total_hours' => 0,
                'present_hours' => 0,  // Changed from count to hours
                'absent_hours' => 0,   // Changed from count to hours
                'attendance_dates' => []
            ];
        }
        
        $attendanceEntry = [
            'date' => $attendance_date,
            'hours' => $hours,
            'status' => $status
        ];
        
        $grouped[$student_id]['attendance'][] = $attendanceEntry;
        $grouped[$student_id]['total_hours'] += $hours;
        
        // Track unique dates for this student
        if (!in_array($attendance_date, $grouped[$student_id]['attendance_dates'])) {
            $grouped[$student_id]['attendance_dates'][] = $attendance_date;
        }
        
        // Track unique dates across all students
        if (!in_array($attendance_date, $all_attendance_dates)) {
            $all_attendance_dates[] = $attendance_date;
        }
        
        // Count hours by status (FIXED)
        if ($status === 'present') {
            $grouped[$student_id]['present_hours'] += $hours;
        } else {
            $grouped[$student_id]['absent_hours'] += $hours;
        }
        
        $total_hours += $hours;
    }

    // Calculate additional summary metrics
    $students = array_values($grouped);
    $total_students = count($students);
    $total_days = count($all_attendance_dates);
    $total_possible_hours = $total_days * $subjectTotalHours; // Adjust based on your logic

    // Prepare enhanced response
    $response = [
        'success' => true,
        'semester' => $data['semester_id'] ?? 'All',
        'subject_total_hours' => $subjectTotalHours,
        'filtered_hours' => $total_hours,
        'total_students' => $total_students,
        'total_days' => $total_days,
        'total_possible_hours' => $total_possible_hours, // Added for percentage calculation
        'students' => $students,
        'summary' => [
            'total_present_hours' => array_sum(array_column($grouped, 'present_hours')),
            'total_absent_hours' => array_sum(array_column($grouped, 'absent_hours'))
        ]
    ];

// ... [Rest of the code remains the same]
    if (empty($grouped)) {
        http_response_code(404);
        $response = [
            "success" => false,
            "error" => "No attendance records found",
            "query" => $sql,
            "params" => $params
        ];
    }

    echo json_encode($response);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "error" => "Database error",
        "details" => $e->getMessage(),
        "trace" => $e->getTraceAsString()
    ]);
    error_log("PDOException: " . $e->getMessage() . "\n" . $e->getTraceAsString());
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage(),
        "trace" => $e->getTraceAsString()
    ]);
    error_log("Exception: " . $e->getMessage() . "\n" . $e->getTraceAsString());
}
?>