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
    } elseif (isset($_GET['date'])) {
        // Get schedules by date
        $date = $_GET['date'];
        $stmt = $conn->prepare("SELECT * FROM schedules WHERE date = ? ORDER BY start_time ASC, end_time ASC");
        $stmt->bind_param("s", $date);
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
        $result = $conn->query("SELECT * FROM schedules ORDER BY date ASC, start_time ASC, end_time ASC");
        
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
    
    if (!isset($data['title']) || !isset($data['date']) || !isset($data['start_time']) || !isset($data['end_time']) || !isset($data['location'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing required fields']);
        return;
    }
    
    $stmt = $conn->prepare("INSERT INTO schedules (title, description, date, start_time, end_time, location, color) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssss", 
        $data['title'], 
        $data['description'] ?? '', 
        $data['date'], 
        $data['start_time'],
        $data['end_time'],
        $data['location'],
        $data['color'] ?? '#2563eb'
    );
    
    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        $newSchedule = [
            'id' => $newId,
            'title' => $data['title'],
            'description' => $data['description'] ?? '',
            'date' => $data['date'],
            'start_time' => $data['start_time'],
            'end_time' => $data['end_time'],
            'location' => $data['location'],
            'color' => $data['color'] ?? '#2563eb'
        ];
        
        http_response_code(201);
        echo json_encode(['success' => true, 'message' => 'Schedule created', 'data' => $newSchedule]);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to create schedule']);
    }
    
    $stmt->close();
}

// PUT - Update schedule
function handlePut($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['id']) || !isset($data['title']) || !isset($data['date']) || !isset($data['start_time']) || !isset($data['end_time']) || !isset($data['location'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing required fields']);
        return;
    }
    
    $stmt = $conn->prepare("UPDATE schedules SET title = ?, description = ?, date = ?, start_time = ?, end_time = ?, location = ?, color = ? WHERE id = ?");
    $stmt->bind_param("sssssssi", 
        $data['title'], 
        $data['description'] ?? '', 
        $data['date'], 
        $data['start_time'],
        $data['end_time'],
        $data['location'],
        $data['color'] ?? '#2563eb',
        $data['id']
    );
    
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
