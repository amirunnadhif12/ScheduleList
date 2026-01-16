<?php
require_once '../../config/database.php';

$conn = getDBConnection();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    handleGet($conn);
} else {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
}

$conn->close();

// GET - Dashboard statistics
function handleGet($conn) {
    // Get task statistics by status
    $statsQuery = "SELECT 
        status,
        COUNT(*) as count 
    FROM tasks 
    GROUP BY status";
    
    $statsResult = $conn->query($statsQuery);
    $stats = [
        'total_tasks' => 0,
        'belum_mulai' => 0,
        'berjalan' => 0,
        'selesai' => 0
    ];
    
    while ($row = $statsResult->fetch_assoc()) {
        $stats[$row['status']] = intval($row['count']);
        $stats['total_tasks'] += intval($row['count']);
    }
    
    // Get tasks with approaching deadline (next 7 days)
    $today = date('Y-m-d');
    $nextWeek = date('Y-m-d', strtotime('+7 days'));
    
    $deadlineQuery = "SELECT 
        id, 
        title, 
        category,
        deadline, 
        priority,
        status,
        progress
    FROM tasks 
    WHERE deadline >= ? AND deadline <= ? AND status != 'selesai'
    ORDER BY deadline ASC 
    LIMIT 5";
    
    $stmt = $conn->prepare($deadlineQuery);
    $stmt->bind_param("ss", $today, $nextWeek);
    $stmt->execute();
    $deadlineResult = $stmt->get_result();
    
    $approachingDeadlines = [];
    while ($row = $deadlineResult->fetch_assoc()) {
        $daysLeft = ceil((strtotime($row['deadline']) - strtotime('now')) / (60 * 60 * 24));
        $row['days_left'] = $daysLeft;
        $approachingDeadlines[] = $row;
    }
    $stmt->close();
    
    // Get today's schedules
    $today = date('Y-m-d');
    $schedulesQuery = "SELECT 
        id,
        title,
        start_time,
        end_time,
        location,
        color
    FROM schedules 
    WHERE date = ? 
    ORDER BY start_time ASC";
    
    $stmt = $conn->prepare($schedulesQuery);
    $stmt->bind_param("s", $today);
    $stmt->execute();
    $schedulesResult = $stmt->get_result();
    
    $todaySchedules = [];
    while ($row = $schedulesResult->fetch_assoc()) {
        $todaySchedules[] = $row;
    }
    $stmt->close();
    
    // Get high priority tasks (untuk alert)
    $highPriorityQuery = "SELECT 
        id,
        title,
        category,
        deadline,
        priority,
        status
    FROM tasks 
    WHERE priority = 'tinggi' AND status != 'selesai'
    ORDER BY deadline ASC
    LIMIT 3";
    
    $highPriorityResult = $conn->query($highPriorityQuery);
    $highPriorityTasks = [];
    
    while ($row = $highPriorityResult->fetch_assoc()) {
        $highPriorityTasks[] = $row;
    }
    
    // Build response
    $response = [
        'success' => true,
        'data' => [
            'statistics' => [
                'total_tasks' => $stats['total_tasks'],
                'belum_mulai' => $stats['belum_mulai'],
                'berjalan' => $stats['berjalan'],
                'selesai' => $stats['selesai']
            ],
            'approaching_deadlines' => $approachingDeadlines,
            'today_schedules' => $todaySchedules,
            'high_priority_tasks' => $highPriorityTasks,
            'today_date' => $today
        ]
    ];
    
    http_response_code(200);
    echo json_encode($response);
}
?>
