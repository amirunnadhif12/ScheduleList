<?php
// CORS headers untuk Flutter Web
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../config/database.php';

$conn = getDBConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        handleGet($conn);
        break;
    case 'POST':
        handlePost($conn);
        break;
    case 'PUT':
        handlePut($conn);
        break;
    case 'DELETE':
        handleDelete($conn);
        break;
    default:
        http_response_code(405);
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
        break;
}

$conn->close();

// GET - Read schedules
function handleGet($conn) {
    if (isset($_GET['id'])) {
        // Get single schedule
        $id = intval($_GET['id']);
        $stmt = $conn->prepare("SELECT * FROM schedules WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($row = $result->fetch_assoc()) {
            echo json_encode(['success' => true, 'data' => $row]);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Schedule not found']);
        }
        $stmt->close();
    } elseif (isset($_GET['user_id']) && isset($_GET['date'])) {
        // Get schedules by user_id and date
        $user_id = intval($_GET['user_id']);
        $date = $_GET['date'];
        $stmt = $conn->prepare("SELECT * FROM schedules WHERE user_id = ? AND date = ? ORDER BY start_time ASC");
        $stmt->bind_param("is", $user_id, $date);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $schedules = [];
        while ($row = $result->fetch_assoc()) {
            $schedules[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $schedules]);
        $stmt->close();
    } elseif (isset($_GET['user_id'])) {
        // Get all schedules for user
        $user_id = intval($_GET['user_id']);
        $stmt = $conn->prepare("SELECT * FROM schedules WHERE user_id = ? ORDER BY date ASC, start_time ASC");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $schedules = [];
        while ($row = $result->fetch_assoc()) {
            $schedules[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $schedules]);
        $stmt->close();
    } else {
        // Get all schedules
        $result = $conn->query("SELECT * FROM schedules ORDER BY date ASC, start_time ASC");
        
        $schedules = [];
        while ($row = $result->fetch_assoc()) {
            $schedules[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $schedules]);
    }
}

// POST - Create schedule
function handlePost($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['user_id']) || !isset($data['activity']) || !isset($data['date']) || !isset($data['start_time']) || !isset($data['end_time'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing required fields: user_id, activity, date, start_time, end_time']);
        return;
    }
    
    $user_id = intval($data['user_id']);
    $activity = $data['activity'];
    $description = $data['description'] ?? '';
    $date = $data['date'];
    $start_time = $data['start_time'];
    $end_time = $data['end_time'];
    $location = $data['location'] ?? '';
    $color = $data['color'] ?? '#2563eb';
    
    $stmt = $conn->prepare("INSERT INTO schedules (user_id, activity, description, date, start_time, end_time, location, color) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("isssssss", $user_id, $activity, $description, $date, $start_time, $end_time, $location, $color);
    
    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        $newSchedule = [
            'id' => $newId,
            'user_id' => $user_id,
            'activity' => $activity,
            'description' => $description,
            'date' => $date,
            'start_time' => $start_time,
            'end_time' => $end_time,
            'location' => $location,
            'color' => $color
        ];
        
        http_response_code(201);
        echo json_encode(['success' => true, 'message' => 'Schedule created', 'data' => $newSchedule]);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to create schedule: ' . $stmt->error]);
    }
    
    $stmt->close();
}

// PUT - Update schedule
function handlePut($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing schedule ID']);
        return;
    }
    
    $id = intval($data['id']);
    $activity = $data['activity'] ?? null;
    $description = $data['description'] ?? null;
    $date = $data['date'] ?? null;
    $start_time = $data['start_time'] ?? null;
    $end_time = $data['end_time'] ?? null;
    $location = $data['location'] ?? null;
    $color = $data['color'] ?? null;
    
    $updateFields = [];
    $types = '';
    $params = [];
    
    if ($activity !== null) { $updateFields[] = 'activity = ?'; $types .= 's'; $params[] = $activity; }
    if ($description !== null) { $updateFields[] = 'description = ?'; $types .= 's'; $params[] = $description; }
    if ($date !== null) { $updateFields[] = 'date = ?'; $types .= 's'; $params[] = $date; }
    if ($start_time !== null) { $updateFields[] = 'start_time = ?'; $types .= 's'; $params[] = $start_time; }
    if ($end_time !== null) { $updateFields[] = 'end_time = ?'; $types .= 's'; $params[] = $end_time; }
    if ($location !== null) { $updateFields[] = 'location = ?'; $types .= 's'; $params[] = $location; }
    if ($color !== null) { $updateFields[] = 'color = ?'; $types .= 's'; $params[] = $color; }
    
    if (empty($updateFields)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'No fields to update']);
        return;
    }
    
    $types .= 'i';
    $params[] = $id;
    
    $query = "UPDATE schedules SET " . implode(', ', $updateFields) . " WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param($types, ...$params);
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Schedule updated']);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Schedule not found']);
        }
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to update schedule']);
    }
    
    $stmt->close();
}

// DELETE - Delete schedule
function handleDelete($conn) {
    if (!isset($_GET['id'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing schedule ID']);
        return;
    }
    
    $id = intval($_GET['id']);
    $stmt = $conn->prepare("DELETE FROM schedules WHERE id = ?");
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Schedule deleted']);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Schedule not found']);
        }
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to delete schedule']);
    }
    
    $stmt->close();
}
?>
