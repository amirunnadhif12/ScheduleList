<?php
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
            $row['is_completed'] = (bool)$row['is_completed'];
            echo json_encode(['success' => true, 'data' => $row]);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Task not found']);
        }
        $stmt->close();
    } elseif (isset($_GET['status'])) {
        // Get tasks by status (belum_mulai, berjalan, selesai)
        $status = $_GET['status'];
        $validStatuses = ['belum_mulai', 'berjalan', 'selesai'];
        if (!in_array($status, $validStatuses)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid status']);
            return;
        }
        $stmt = $conn->prepare("SELECT * FROM tasks WHERE status = ? ORDER BY deadline ASC");
        $stmt->bind_param("s", $status);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $tasks = [];
        while ($row = $result->fetch_assoc()) {
            $row['is_completed'] = (bool)$row['is_completed'];
            $tasks[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $tasks]);
        $stmt->close();
    } elseif (isset($_GET['priority'])) {
        // Get tasks by priority (rendah, sedang, tinggi)
        $priority = $_GET['priority'];
        $stmt = $conn->prepare("SELECT * FROM tasks WHERE priority = ? ORDER BY deadline ASC");
        $stmt->bind_param("s", $priority);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $tasks = [];
        while ($row = $result->fetch_assoc()) {
            $row['is_completed'] = (bool)$row['is_completed'];
            $tasks[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $tasks]);
        $stmt->close();
    } elseif (isset($_GET['category'])) {
        // Get tasks by category (mata kuliah)
        $category = $_GET['category'];
        $stmt = $conn->prepare("SELECT * FROM tasks WHERE category = ? ORDER BY deadline ASC");
        $stmt->bind_param("s", $category);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $tasks = [];
        while ($row = $result->fetch_assoc()) {
            $row['is_completed'] = (bool)$row['is_completed'];
            $tasks[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $tasks]);
        $stmt->close();
    } elseif (isset($_GET['search'])) {
        // Search tasks
        $search = '%' . $_GET['search'] . '%';
        $stmt = $conn->prepare("SELECT * FROM tasks WHERE title LIKE ? ORDER BY deadline ASC");
        $stmt->bind_param("s", $search);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $tasks = [];
        while ($row = $result->fetch_assoc()) {
            $row['is_completed'] = (bool)$row['is_completed'];
            $tasks[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $tasks]);
        $stmt->close();
    } else {
        // Get all tasks
        $result = $conn->query("SELECT * FROM tasks ORDER BY deadline ASC");
        
        $tasks = [];
        while ($row = $result->fetch_assoc()) {
            $row['is_completed'] = (bool)$row['is_completed'];
            $tasks[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $tasks]);
    }
}

// POST - Create task
function handlePost($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['title']) || !isset($data['category']) || !isset($data['deadline']) || !isset($data['priority'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing required fields: title, category, deadline, priority']);
        return;
    }
    
    $status = $data['status'] ?? 'belum_mulai';
    $progress = isset($data['progress']) ? intval($data['progress']) : 0;
    $progress = max(0, min(100, $progress)); // Ensure 0-100
    
    $stmt = $conn->prepare("INSERT INTO tasks (title, category, description, deadline, priority, status, progress, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssssss", 
        $data['title'], 
        $data['category'],
        $data['description'] ?? '',
        $data['deadline'], 
        $data['priority'],
        $status,
        $progress,
        $data['image_path'] ?? null
    );
    
    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        $newTask = [
            'id' => $newId,
            'title' => $data['title'],
            'category' => $data['category'],
            'description' => $data['description'] ?? '',
            'deadline' => $data['deadline'],
            'priority' => $data['priority'],
            'status' => $status,
            'progress' => $progress,
            'image_path' => $data['image_path'] ?? null
        ];
        
        http_response_code(201);
        echo json_encode(['success' => true, 'message' => 'Task created', 'data' => $newTask]);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to create task']);
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
    
    if (!isset($data['title']) || !isset($data['category']) || !isset($data['deadline']) || !isset($data['priority'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing required fields: title, category, deadline, priority']);
        return;
    }
    
    $status = $data['status'] ?? 'belum_mulai';
    $progress = isset($data['progress']) ? intval($data['progress']) : 0;
    $progress = max(0, min(100, $progress)); // Ensure 0-100
    
    $stmt = $conn->prepare("UPDATE tasks SET title = ?, category = ?, description = ?, deadline = ?, priority = ?, status = ?, progress = ?, image_path = ? WHERE id = ?");
    $stmt->bind_param("ssssssssi", 
        $data['title'], 
        $data['category'],
        $data['description'] ?? '',
        $data['deadline'], 
        $data['priority'],
        $status,
        $progress,
        $data['image_path'] ?? null,
        $data['id']
    );
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Task updated']);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Task not found or no changes made']);
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
