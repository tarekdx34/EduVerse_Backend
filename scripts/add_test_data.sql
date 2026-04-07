-- ============================================================================
-- EduVerse Test Data Pack for instructor.tarek, student.tarek, ta.tarek
-- Created: 2026-04-07
-- ============================================================================

-- User IDs:
-- 57 = student.tarek@example.com
-- 58 = instructor.tarek@example.com  
-- 60 = ta.tarek@example.com

SET @instructor_id = 58;
SET @student_id = 57;
SET @ta_id = 60;
SET @semester_id = 4; -- Fall 2025 (current active)

-- ============================================================================
-- STEP 1: Create New Courses (with unique codes)
-- ============================================================================

INSERT INTO courses (course_code, course_name, department_id, credits, course_description, level, status, instructor_id)
VALUES 
('CS501', 'Advanced Data Structures', 1, 4, 'Advanced data structures including B-trees, red-black trees, and advanced graph algorithms.', 'graduate', 'active', @instructor_id),
('CS502', 'Distributed Systems', 1, 3, 'Fundamentals of distributed computing, consensus algorithms, and fault tolerance.', 'graduate', 'active', @instructor_id),
('CS503', 'Computer Networks', 1, 3, 'Network protocols, TCP/IP, routing, and network security.', 'senior', 'active', @instructor_id),
('CS504', 'Operating Systems', 1, 4, 'Process management, memory management, file systems, and concurrency.', 'junior', 'active', @instructor_id),
('CS505', 'Web Development', 1, 3, 'Full-stack web development with modern frameworks and best practices.', 'junior', 'active', @instructor_id);

-- Get the IDs of newly created courses
SET @cs501_id = (SELECT course_id FROM courses WHERE course_code = 'CS501' ORDER BY course_id DESC LIMIT 1);
SET @cs502_id = (SELECT course_id FROM courses WHERE course_code = 'CS502' ORDER BY course_id DESC LIMIT 1);
SET @cs503_id = (SELECT course_id FROM courses WHERE course_code = 'CS503' ORDER BY course_id DESC LIMIT 1);
SET @cs504_id = (SELECT course_id FROM courses WHERE course_code = 'CS504' ORDER BY course_id DESC LIMIT 1);
SET @cs505_id = (SELECT course_id FROM courses WHERE course_code = 'CS505' ORDER BY course_id DESC LIMIT 1);

-- ============================================================================
-- STEP 2: Create Course Sections
-- ============================================================================

INSERT INTO course_sections (course_id, semester_id, section_number, max_capacity, current_enrollment, location, status)
VALUES
(@cs501_id, @semester_id, 'A', 40, 1, 'Building A, Room 101', 'open'),
(@cs502_id, @semester_id, 'A', 35, 1, 'Building B, Room 205', 'open'),
(@cs503_id, @semester_id, 'A', 30, 1, 'Building C, Room 301', 'open'),
(@cs504_id, @semester_id, 'A', 25, 1, 'Building D, Room 401', 'open'),
(@cs505_id, @semester_id, 'A', 30, 1, 'Building E, Room 102', 'open');

-- Get section IDs
SET @cs501_section = (SELECT section_id FROM course_sections WHERE course_id = @cs501_id ORDER BY section_id DESC LIMIT 1);
SET @cs502_section = (SELECT section_id FROM course_sections WHERE course_id = @cs502_id ORDER BY section_id DESC LIMIT 1);
SET @cs503_section = (SELECT section_id FROM course_sections WHERE course_id = @cs503_id ORDER BY section_id DESC LIMIT 1);
SET @cs504_section = (SELECT section_id FROM course_sections WHERE course_id = @cs504_id ORDER BY section_id DESC LIMIT 1);
SET @cs505_section = (SELECT section_id FROM course_sections WHERE course_id = @cs505_id ORDER BY section_id DESC LIMIT 1);

-- ============================================================================
-- STEP 3: Assign Instructor to All Sections
-- ============================================================================

INSERT INTO course_instructors (user_id, section_id, role)
VALUES
(@instructor_id, @cs501_section, 'primary'),
(@instructor_id, @cs502_section, 'primary'),
(@instructor_id, @cs503_section, 'primary'),
(@instructor_id, @cs504_section, 'primary'),
(@instructor_id, @cs505_section, 'primary');

-- ============================================================================
-- STEP 4: Enroll Student in All Sections
-- ============================================================================

INSERT INTO course_enrollments (user_id, section_id, enrollment_status, enrollment_date)
VALUES
(@student_id, @cs501_section, 'enrolled', NOW()),
(@student_id, @cs502_section, 'enrolled', NOW()),
(@student_id, @cs503_section, 'enrolled', NOW()),
(@student_id, @cs504_section, 'enrolled', NOW()),
(@student_id, @cs505_section, 'enrolled', NOW());

-- ============================================================================
-- STEP 5: Create Assignments (No Due Date or Very Long Due Date)
-- ============================================================================

-- CS501 Assignments
INSERT INTO assignments (course_id, title, description, instructions, max_score, status, available_from, due_date, late_submission_allowed, created_by)
VALUES
(@cs501_id, 'Assignment 1: B-Tree Implementation', 'Implement a B-tree with insert, delete, and search operations.', 'Submit your code as a single .zip file containing all source files.', 100, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 1, @instructor_id),
(@cs501_id, 'Assignment 2: Red-Black Tree', 'Create a red-black tree with balancing operations.', 'Include unit tests for each operation.', 100, 'published', NOW(), NULL, 1, @instructor_id),
(@cs501_id, 'Assignment 3: Shortest Path Algorithms', 'Implement Dijkstra and Bellman-Ford algorithms.', 'Document time complexity for each operation.', 150, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 180 DAY), 1, @instructor_id);

-- CS502 Assignments  
INSERT INTO assignments (course_id, title, description, instructions, max_score, status, available_from, due_date, late_submission_allowed, created_by)
VALUES
(@cs502_id, 'Assignment 1: RPC Implementation', 'Build a simple RPC framework.', 'Use standard notation and include documentation.', 100, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 1, @instructor_id),
(@cs502_id, 'Assignment 2: Consensus Algorithm', 'Implement a basic Raft consensus algorithm.', 'Test with multiple nodes.', 100, 'published', NOW(), NULL, 1, @instructor_id),
(@cs502_id, 'Assignment 3: Distributed Hash Table', 'Create a DHT with consistent hashing.', 'Show step-by-step implementation.', 100, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 200 DAY), 1, @instructor_id);

-- CS503 Assignments
INSERT INTO assignments (course_id, title, description, instructions, max_score, status, available_from, due_date, late_submission_allowed, created_by)
VALUES
(@cs503_id, 'Assignment 1: Socket Programming', 'Create a client-server chat application.', 'Use TCP sockets.', 100, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 1, @instructor_id),
(@cs503_id, 'Assignment 2: HTTP Server', 'Build a basic HTTP server from scratch.', 'Support GET and POST methods.', 100, 'published', NOW(), NULL, 1, @instructor_id),
(@cs503_id, 'Assignment 3: Network Packet Analyzer', 'Analyze network packets using Wireshark.', 'Capture and document 10 different packet types.', 100, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 300 DAY), 1, @instructor_id);

-- CS504 Assignments
INSERT INTO assignments (course_id, title, description, instructions, max_score, status, available_from, due_date, late_submission_allowed, created_by)
VALUES
(@cs504_id, 'Assignment 1: Process Scheduler', 'Implement round-robin and priority scheduling.', 'Use simulation to test.', 100, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 1, @instructor_id),
(@cs504_id, 'Assignment 2: Memory Manager', 'Create a virtual memory manager with paging.', 'Implement page replacement algorithms.', 100, 'published', NOW(), NULL, 1, @instructor_id),
(@cs504_id, 'Assignment 3: File System', 'Design a simple file system.', 'Support create, read, write, delete operations.', 150, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 250 DAY), 1, @instructor_id);

-- CS505 Assignments
INSERT INTO assignments (course_id, title, description, instructions, max_score, status, available_from, due_date, late_submission_allowed, created_by)
VALUES
(@cs505_id, 'Assignment 1: REST API Development', 'Build a REST API with CRUD operations.', 'Use Node.js/Express or Python/Flask.', 100, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 1, @instructor_id),
(@cs505_id, 'Assignment 2: React Frontend', 'Create a React frontend for your API.', 'Include routing and state management.', 100, 'published', NOW(), NULL, 1, @instructor_id),
(@cs505_id, 'Assignment 3: Full Stack Project', 'Build a complete web application.', 'Deploy to cloud platform.', 150, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 200 DAY), 1, @instructor_id);

-- ============================================================================
-- STEP 6: Create Labs (No Due Date or Very Long Due Date)
-- ============================================================================

-- CS501 Labs
INSERT INTO labs (course_id, title, description, lab_number, max_score, status, available_from, due_date, created_by)
VALUES
(@cs501_id, 'Lab 1: B-Tree Operations', 'Implement and test B-tree insert and search.', 1, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), @instructor_id),
(@cs501_id, 'Lab 2: AVL Tree Balancing', 'Implement AVL tree rotations.', 2, 50, 'published', NOW(), NULL, @instructor_id),
(@cs501_id, 'Lab 3: Graph Algorithms', 'Implement Dijkstra and A* algorithms.', 3, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 180 DAY), @instructor_id);

-- CS502 Labs
INSERT INTO labs (course_id, title, description, lab_number, max_score, status, available_from, due_date, created_by)
VALUES
(@cs502_id, 'Lab 1: gRPC Setup', 'Set up gRPC communication between services.', 1, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), @instructor_id),
(@cs502_id, 'Lab 2: Leader Election', 'Implement a leader election algorithm.', 2, 50, 'published', NOW(), NULL, @instructor_id),
(@cs502_id, 'Lab 3: Distributed Locks', 'Create a distributed locking mechanism.', 3, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 200 DAY), @instructor_id);

-- CS503 Labs
INSERT INTO labs (course_id, title, description, lab_number, max_score, status, available_from, due_date, created_by)
VALUES
(@cs503_id, 'Lab 1: TCP Echo Server', 'Build a TCP echo server and client.', 1, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), @instructor_id),
(@cs503_id, 'Lab 2: UDP File Transfer', 'Implement reliable file transfer over UDP.', 2, 50, 'published', NOW(), NULL, @instructor_id),
(@cs503_id, 'Lab 3: DNS Resolver', 'Build a simple DNS resolver.', 3, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 300 DAY), @instructor_id);

-- CS504 Labs
INSERT INTO labs (course_id, title, description, lab_number, max_score, status, available_from, due_date, created_by)
VALUES
(@cs504_id, 'Lab 1: Process Creation', 'Work with fork() and exec() system calls.', 1, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), @instructor_id),
(@cs504_id, 'Lab 2: Thread Synchronization', 'Implement mutex and semaphore examples.', 2, 50, 'published', NOW(), NULL, @instructor_id),
(@cs504_id, 'Lab 3: Memory Mapping', 'Use mmap for file I/O.', 3, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 250 DAY), @instructor_id);

-- CS505 Labs
INSERT INTO labs (course_id, title, description, lab_number, max_score, status, available_from, due_date, created_by)
VALUES
(@cs505_id, 'Lab 1: HTML/CSS Basics', 'Create a responsive landing page.', 1, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), @instructor_id),
(@cs505_id, 'Lab 2: JavaScript DOM', 'Build an interactive web component.', 2, 50, 'published', NOW(), NULL, @instructor_id),
(@cs505_id, 'Lab 3: API Integration', 'Fetch and display data from a REST API.', 3, 50, 'published', NOW(), DATE_ADD(NOW(), INTERVAL 200 DAY), @instructor_id);

-- ============================================================================
-- STEP 7: Create Quizzes (No Due Date or Very Long Due Date)
-- ============================================================================

-- CS501 Quizzes
INSERT INTO quizzes (course_id, title, description, time_limit_minutes, max_attempts, passing_score, randomize_questions, show_correct_answers, available_from, available_until, status, created_by)
VALUES
(@cs501_id, 'Quiz 1: Tree Structures', 'Test your understanding of advanced tree data structures.', 30, 3, 60, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 'published', @instructor_id),
(@cs501_id, 'Quiz 2: Graph Algorithms', 'Assessment on graph algorithms and complexity.', 25, 3, 60, 1, 1, NOW(), NULL, 'published', @instructor_id),
(@cs501_id, 'Quiz 3: Hash Tables', 'Comprehensive quiz on hashing techniques.', 45, 2, 70, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 180 DAY), 'published', @instructor_id);

-- CS502 Quizzes
INSERT INTO quizzes (course_id, title, description, time_limit_minutes, max_attempts, passing_score, randomize_questions, show_correct_answers, available_from, available_until, status, created_by)
VALUES
(@cs502_id, 'Quiz 1: Distributed Systems Basics', 'Test knowledge of distributed computing fundamentals.', 30, 3, 60, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 'published', @instructor_id),
(@cs502_id, 'Quiz 2: Consensus Protocols', 'Assessment on Paxos, Raft, and consensus.', 40, 3, 60, 1, 1, NOW(), NULL, 'published', @instructor_id),
(@cs502_id, 'Quiz 3: Fault Tolerance', 'Quiz on fault tolerance mechanisms.', 35, 2, 70, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 200 DAY), 'published', @instructor_id);

-- CS503 Quizzes
INSERT INTO quizzes (course_id, title, description, time_limit_minutes, max_attempts, passing_score, randomize_questions, show_correct_answers, available_from, available_until, status, created_by)
VALUES
(@cs503_id, 'Quiz 1: OSI Model', 'Test understanding of network layers.', 25, 3, 60, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 'published', @instructor_id),
(@cs503_id, 'Quiz 2: TCP/IP', 'Compare and contrast TCP and UDP.', 30, 3, 60, 1, 1, NOW(), NULL, 'published', @instructor_id),
(@cs503_id, 'Quiz 3: Network Security', 'Quiz on encryption and secure protocols.', 35, 2, 70, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 300 DAY), 'published', @instructor_id);

-- CS504 Quizzes
INSERT INTO quizzes (course_id, title, description, time_limit_minutes, max_attempts, passing_score, randomize_questions, show_correct_answers, available_from, available_until, status, created_by)
VALUES
(@cs504_id, 'Quiz 1: Process Management', 'Test process and thread concepts.', 30, 3, 60, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 'published', @instructor_id),
(@cs504_id, 'Quiz 2: Memory Management', 'Assessment on virtual memory and paging.', 40, 3, 60, 1, 1, NOW(), NULL, 'published', @instructor_id),
(@cs504_id, 'Quiz 3: File Systems', 'Quiz on file system organization.', 45, 2, 70, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 250 DAY), 'published', @instructor_id);

-- CS505 Quizzes
INSERT INTO quizzes (course_id, title, description, time_limit_minutes, max_attempts, passing_score, randomize_questions, show_correct_answers, available_from, available_until, status, created_by)
VALUES
(@cs505_id, 'Quiz 1: HTML/CSS Basics', 'Test understanding of web fundamentals.', 25, 3, 60, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY), 'published', @instructor_id),
(@cs505_id, 'Quiz 2: JavaScript Essentials', 'Assessment on JS fundamentals.', 30, 3, 60, 1, 1, NOW(), NULL, 'published', @instructor_id),
(@cs505_id, 'Quiz 3: React Basics', 'Quiz on React components and hooks.', 35, 2, 70, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 200 DAY), 'published', @instructor_id);

-- ============================================================================
-- STEP 8: Add Quiz Questions (Sample questions for each quiz)
-- ============================================================================

-- Get quiz IDs (we'll add questions for the first quiz of each course)
SET @quiz_cs501_1 = (SELECT quiz_id FROM quizzes WHERE course_id = @cs501_id AND title LIKE '%Quiz 1%' ORDER BY quiz_id DESC LIMIT 1);
SET @quiz_cs502_1 = (SELECT quiz_id FROM quizzes WHERE course_id = @cs502_id AND title LIKE '%Quiz 1%' ORDER BY quiz_id DESC LIMIT 1);
SET @quiz_cs503_1 = (SELECT quiz_id FROM quizzes WHERE course_id = @cs503_id AND title LIKE '%Quiz 1%' ORDER BY quiz_id DESC LIMIT 1);
SET @quiz_cs504_1 = (SELECT quiz_id FROM quizzes WHERE course_id = @cs504_id AND title LIKE '%Quiz 1%' ORDER BY quiz_id DESC LIMIT 1);
SET @quiz_cs505_1 = (SELECT quiz_id FROM quizzes WHERE course_id = @cs505_id AND title LIKE '%Quiz 1%' ORDER BY quiz_id DESC LIMIT 1);

-- CS501 Quiz 1 Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, order_index, options, correct_answer)
VALUES
(@quiz_cs501_1, 'What is the maximum number of children in a B-tree of order m?', 'mcq', 10, 1, '["m","m-1","m+1","2m"]', 'm'),
(@quiz_cs501_1, 'Which tree guarantees O(log n) height?', 'mcq', 10, 2, '["AVL Tree","Binary Tree","Linked List","Array"]', 'AVL Tree'),
(@quiz_cs501_1, 'Red-black trees maintain balance through color properties.', 'true_false', 10, 3, '["True","False"]', 'True'),
(@quiz_cs501_1, 'What is the worst-case time complexity of B-tree search?', 'mcq', 10, 4, '["O(log n)","O(n)","O(1)","O(n log n)"]', 'O(log n)'),
(@quiz_cs501_1, 'Which operation is most expensive in a B-tree?', 'mcq', 10, 5, '["Node split","Search","Traversal","Access"]', 'Node split');

-- CS502 Quiz 1 Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, order_index, options, correct_answer)
VALUES
(@quiz_cs502_1, 'What is the CAP theorem about?', 'mcq', 10, 1, '["Consistency, Availability, Partition tolerance","Cache, API, Protocol","Control, Access, Performance","None of these"]', 'Consistency, Availability, Partition tolerance'),
(@quiz_cs502_1, 'Which protocol is used for distributed consensus?', 'mcq', 10, 2, '["Raft","HTTP","FTP","SMTP"]', 'Raft'),
(@quiz_cs502_1, 'Distributed systems can achieve all three CAP properties simultaneously.', 'true_false', 10, 3, '["True","False"]', 'False'),
(@quiz_cs502_1, 'What is eventual consistency?', 'mcq', 10, 4, '["Data becomes consistent over time","Immediate consistency","No consistency","Strong consistency"]', 'Data becomes consistent over time'),
(@quiz_cs502_1, 'Which is a benefit of microservices?', 'mcq', 10, 5, '["Independent deployment","Single codebase","Shared database","Monolithic structure"]', 'Independent deployment');

-- CS503 Quiz 1 Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, order_index, options, correct_answer)
VALUES
(@quiz_cs503_1, 'How many layers are in the OSI model?', 'mcq', 10, 1, '["7","4","5","6"]', '7'),
(@quiz_cs503_1, 'Which layer handles routing?', 'mcq', 10, 2, '["Network","Transport","Session","Application"]', 'Network'),
(@quiz_cs503_1, 'TCP is a connection-oriented protocol.', 'true_false', 10, 3, '["True","False"]', 'True'),
(@quiz_cs503_1, 'What is the default HTTP port?', 'mcq', 10, 4, '["80","443","22","21"]', '80'),
(@quiz_cs503_1, 'Which protocol is used for secure web browsing?', 'mcq', 10, 5, '["HTTPS","HTTP","FTP","SMTP"]', 'HTTPS');

-- CS504 Quiz 1 Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, order_index, options, correct_answer)
VALUES
(@quiz_cs504_1, 'What system call creates a new process in Unix?', 'mcq', 10, 1, '["fork()","exec()","spawn()","create()"]', 'fork()'),
(@quiz_cs504_1, 'Which scheduling algorithm gives minimum average waiting time?', 'mcq', 10, 2, '["SJF","FCFS","Round Robin","Priority"]', 'SJF'),
(@quiz_cs504_1, 'A deadlock requires all four Coffman conditions.', 'true_false', 10, 3, '["True","False"]', 'True'),
(@quiz_cs504_1, 'What is thrashing in OS?', 'mcq', 10, 4, '["Excessive paging","Fast processing","Memory leak","Buffer overflow"]', 'Excessive paging'),
(@quiz_cs504_1, 'Which is NOT a process state?', 'mcq', 10, 5, '["Compiled","Running","Ready","Blocked"]', 'Compiled');

-- CS505 Quiz 1 Questions
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, order_index, options, correct_answer)
VALUES
(@quiz_cs505_1, 'Which tag is used for the largest heading in HTML?', 'mcq', 10, 1, '["<h1>","<h6>","<header>","<head>"]', '<h1>'),
(@quiz_cs505_1, 'What does CSS stand for?', 'mcq', 10, 2, '["Cascading Style Sheets","Computer Style Sheets","Creative Style System","Cascading System Styles"]', 'Cascading Style Sheets'),
(@quiz_cs505_1, 'CSS can be written inline in HTML elements.', 'true_false', 10, 3, '["True","False"]', 'True'),
(@quiz_cs505_1, 'Which property is used for background color?', 'mcq', 10, 4, '["background-color","color","bg-color","back-color"]', 'background-color'),
(@quiz_cs505_1, 'What is the correct HTML element for inserting a line break?', 'mcq', 10, 5, '["<br>","<break>","<lb>","<newline>"]', '<br>');

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Test Data Creation Complete!' AS status;
SELECT 'New Courses:' AS info, COUNT(*) AS count FROM courses WHERE course_code IN ('CS501', 'CS502', 'CS503', 'CS504', 'CS505');
SELECT 'Total Assignments for instructor:' AS info, COUNT(*) AS count FROM assignments WHERE created_by = 58;
SELECT 'Total Labs for instructor:' AS info, COUNT(*) AS count FROM labs WHERE created_by = 58;
SELECT 'Total Quizzes for instructor:' AS info, COUNT(*) AS count FROM quizzes WHERE created_by = 58;
SELECT 'Student enrollments:' AS info, COUNT(*) AS count FROM course_enrollments WHERE user_id = 57;
