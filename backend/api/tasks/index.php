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

// GET - Read tasks
function handleGet($conn) {
    if (isset($_GET['id'])) {
        // Get single task
        $id = intval($_GET['id']);
        $stmt = $conn->prepare("SELECT * FROM tasks WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($row = $result->fetch_assoc()) {
            echo json_encode(['success' => true, 'data' => $row]);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Task not found']);
        }
        $stmt->close();
    } elseif (isset($_GET['user_id']) && isset($_GET['status'])) {
        // Get tasks by user_id and status
        $user_id = intval($_GET['user_id']);
        $status = $_GET['status'];
        $validStatuses = ['belum_mulai', 'berjalan', 'selesai'];
        
        if (!in_array($status, $validStatuses)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid status']);
            return;
        }
        
        $stmt = $conn->prepare("SELECT * FROM tasks WHERE user_id = ? AND status = ? ORDER BY deadline ASC");
        $stmt->bind_param("is", $user_id, $status);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $tasks = [];
        while ($row = $result->fetch_assoc()) {
            $tasks[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $tasks]);
        $stmt->close();
    } elseif (isset($_GET['user_id'])) {
        // Get all tasks for user ordered by deadline
        $user_id = intval($_GET['user_id']);
        $stmt = $conn->prepare("SELECT * FROM tasks WHERE user_id = ? ORDER BY deadline ASC");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $tasks = [];
        while ($row = $result->fetch_assoc()) {
            $tasks[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $tasks]);
        $stmt->close();
    } else {
        // Get all tasks (no user filter)
        $result = $conn->query("SELECT * FROM tasks ORDER BY deadline ASC");
        
        $tasks = [];
        while ($row = $result->fetch_assoc()) {
            $tasks[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $tasks]);
    }
}

// POST - Create task
function handlePost($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['user_id']) || !isset($data['title']) || !isset($data['subject']) || !isset($data['deadline'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing required fields: user_id, title, subject, deadline']);
        return;
    }
    
    $user_id = intval($data['user_id']);
    $title = $data['title'];
    $subject = $data['subject'];
    $description = $data['description'] ?? '';
    $deadline = $data['deadline'];
    $status = $data['status'] ?? 'belum_mulai';
    $priority = $data['priority'] ?? 'sedang';
    $progress = isset($data['progress']) ? intval($data['progress']) : 0;
    $image_path = $data['image_path'] ?? null;
    $progress = max(0, min(100, $progress)); // Ensure 0-100
    
    $stmt = $conn->prepare("INSERT INTO tasks (user_id, title, description, subject, deadline, status, priority, progress, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("issssssis", $user_id, $title, $description, $subject, $deadline, $status, $priority, $progress, $image_path);
    
    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        $newTask = [
            'id' => $newId,
            'user_id' => $user_id,
            'title' => $title,
            'description' => $description,
            'subject' => $subject,
            'deadline' => $deadline,
            'status' => $status,
            'priority' => $priority,
            'progress' => $progress,
            'image_path' => $image_path
        ];
        
        http_response_code(201);
        echo json_encode(['success' => true, 'message' => 'Task created', 'data' => $newTask]);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to create task: ' . $stmt->error]);
    }
    
    $stmt->close();
}

// PUT - Update task
function handlePut($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing task ID']);
        return;
    }
    
    $id = intval($data['id']);
    $title = $data['title'] ?? null;
    $subject = $data['subject'] ?? null;
    $description = $data['description'] ?? null;
    $deadline = $data['deadline'] ?? null;
    $status = $data['status'] ?? null;
    $priority = $data['priority'] ?? null;
    $progress = isset($data['progress']) ? intval($data['progress']) : null;
    $image_path = $data['image_path'] ?? null;
    
    if ($progress !== null) {
        $progress = max(0, min(100, $progress)); // Ensure 0-100
    }
    
    $updateFields = [];
    $types = '';
    $params = [];
    
    if ($title !== null) { $updateFields[] = 'title = ?'; $types .= 's'; $params[] = $title; }
    if ($subject !== null) { $updateFields[] = 'subject = ?'; $types .= 's'; $params[] = $subject; }
    if ($description !== null) { $updateFields[] = 'description = ?'; $types .= 's'; $params[] = $description; }
    if ($deadline !== null) { $updateFields[] = 'deadline = ?'; $types .= 's'; $params[] = $deadline; }
    if ($status !== null) { $updateFields[] = 'status = ?'; $types .= 's'; $params[] = $status; }
    if ($priority !== null) { $updateFields[] = 'priority = ?'; $types .= 's'; $params[] = $priority; }
    if ($progress !== null) { $updateFields[] = 'progress = ?'; $types .= 'i'; $params[] = $progress; }
    if ($image_path !== null) { $updateFields[] = 'image_path = ?'; $types .= 's'; $params[] = $image_path; }
    
    if (empty($updateFields)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'No fields to update']);
        return;
    }
    
    $types .= 'i';
    $params[] = $id;
    
    $query = "UPDATE tasks SET " . implode(', ', $updateFields) . " WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param($types, ...$params);
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Task updated']);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Task not found']);
        }
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to update task']);
    }
    
    $stmt->close();
}

// DELETE - Delete task
function handleDelete($conn) {
    if (!isset($_GET['id'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing task ID']);
        return;
    }
    
    $id = intval($_GET['id']);
    $stmt = $conn->prepare("DELETE FROM tasks WHERE id = ?");
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Task deleted']);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Task not found']);
        }
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to delete task']);
    }
    
    $stmt->close();
}
?>
