-- ============================================================
-- 2. Get the user IDs for our test accounts
-- We'll use these for quiz data
-- amir_student@example.com, amir_instructor@example.com, amir_admin@example.com
-- ============================================================

-- First, let's see what user IDs exist and insert test users if needed
-- (The test users should already exist from your setup)

-- ============================================================
-- 3. Comprehensive Quiz Test Data
-- ============================================================

-- Make sure quiz_difficulty_levels has data
INSERT IGNORE INTO `quiz_difficulty_levels` (`difficulty_level_id`, `level_name`, `difficulty_value`, `description`) VALUES
(1, 'Very Easy', 1, 'Beginner level - basic recall questions'),
(2, 'Easy', 2, 'Simple application of concepts'),
(3, 'Medium', 3, 'Moderate difficulty - requires understanding'),
(4, 'Hard', 4, 'Challenging - requires analysis'),
(5, 'Very Hard', 5, 'Expert level - synthesis and evaluation');

-- ============================================================
-- 4. Additional Quiz Questions for existing quizzes
-- ============================================================

-- Questions for Quiz 1 (Introduction Concepts - course 1)
INSERT INTO `quiz_questions` (`quiz_id`, `question_type`, `question_text`, `options`, `correct_answer`, `explanation`, `points`, `order_index`, `difficulty_level_id`) VALUES
(1, 'mcq', 'What is the primary purpose of a variable in programming?', '["To store data", "To perform calculations", "To display output", "To connect to databases"]', '0', 'Variables are used to store and manage data in memory during program execution.', 2.00, 0, 2),
(1, 'mcq', 'Which of the following is NOT a primitive data type in most programming languages?', '["Integer", "Boolean", "Array", "Character"]', '2', 'Array is a data structure, not a primitive data type. Primitive types include integers, booleans, characters, and floating-point numbers.', 2.00, 1, 2),
(1, 'true_false', 'A function can only return one value at a time in most programming languages.', NULL, 'true', 'In most languages, functions return a single value. To return multiple values, you typically use arrays, objects, or tuples.', 1.00, 2, 1),
(1, 'mcq', 'What does the term "syntax" refer to in programming?', '["The rules for writing valid code", "The speed of code execution", "The amount of memory used", "The number of lines of code"]', '0', 'Syntax refers to the set of rules that define how programs written in a language must be structured.', 2.00, 3, 2),
(1, 'short_answer', 'What keyword is commonly used to declare a constant in JavaScript?', NULL, 'const', 'The const keyword declares a block-scoped constant that cannot be reassigned.', 2.00, 4, 2);

-- Questions for Quiz 2 (Control Flow - course 1)  
INSERT INTO `quiz_questions` (`quiz_id`, `question_type`, `question_text`, `options`, `correct_answer`, `explanation`, `points`, `order_index`, `difficulty_level_id`) VALUES
(2, 'mcq', 'Which loop is guaranteed to execute at least once?', '["for loop", "while loop", "do-while loop", "foreach loop"]', '2', 'A do-while loop checks its condition at the end, so the loop body always executes at least once.', 2.00, 0, 2),
(2, 'mcq', 'What is the purpose of a "break" statement?', '["To pause execution", "To exit the current loop", "To skip to the next iteration", "To terminate the program"]', '1', 'The break statement immediately exits the innermost loop or switch statement.', 2.00, 1, 2),
(2, 'true_false', 'The else clause in an if-else statement is mandatory.', NULL, 'false', 'The else clause is optional. An if statement can stand alone without an else.', 1.00, 2, 1),
(2, 'mcq', 'In a switch statement, what happens if you forget to include a "break"?', '["Compilation error", "Runtime error", "Fall-through to the next case", "Nothing, it works normally"]', '2', 'Without a break, execution falls through to the next case, which is sometimes intentional but often a bug.', 3.00, 3, 3),
(2, 'essay', 'Explain the difference between "while" and "for" loops. When would you choose one over the other?', NULL, NULL, 'A comprehensive answer should mention that while loops are condition-based and for loops are typically count-based.', 5.00, 4, 3);

-- Questions for Quiz 3 (Arrays and Lists - course 2)
INSERT INTO `quiz_questions` (`quiz_id`, `question_type`, `question_text`, `options`, `correct_answer`, `explanation`, `points`, `order_index`, `difficulty_level_id`) VALUES
(3, 'mcq', 'What is the time complexity of accessing an element by index in an array?', '["O(1)", "O(n)", "O(log n)", "O(n²)"]', '0', 'Array access by index is O(1) because arrays provide direct memory access.', 3.00, 0, 3),
(3, 'mcq', 'What happens when you try to access an array index that is out of bounds?', '["Returns null", "Returns undefined", "Throws an exception", "Depends on the language"]', '3', 'Different languages handle out-of-bounds access differently - some throw exceptions, some return null/undefined.', 2.00, 1, 2),
(3, 'true_false', 'In most languages, arrays have a fixed size once created.', NULL, 'true', 'Traditional arrays have fixed size. Dynamic arrays or lists can grow but internally create new arrays.', 2.00, 2, 2),
(3, 'mcq', 'Which data structure would be most efficient for inserting elements at the beginning?', '["Array", "Linked List", "Hash Table", "Binary Tree"]', '1', 'Linked lists allow O(1) insertion at the beginning, while arrays require O(n) to shift elements.', 3.00, 3, 3),
(3, 'short_answer', 'What is the index of the first element in most programming languages?', NULL, '0', 'Most programming languages use zero-based indexing.', 1.00, 4, 1);

-- Questions for Quiz 4 (Array and Linked Lists - course 3)
INSERT INTO `quiz_questions` (`quiz_id`, `question_type`, `question_text`, `options`, `correct_answer`, `explanation`, `points`, `order_index`, `difficulty_level_id`) VALUES
(4, 'mcq', 'What is the main advantage of a linked list over an array?', '["Faster access by index", "Dynamic size", "Less memory usage", "Faster sorting"]', '1', 'Linked lists can grow and shrink dynamically without pre-allocating memory.', 2.00, 0, 2),
(4, 'mcq', 'In a doubly linked list, each node contains:', '["One pointer", "Two pointers", "Three pointers", "No pointers"]', '1', 'A doubly linked list node has pointers to both the previous and next nodes.', 2.00, 1, 2),
(4, 'true_false', 'Searching for an element in an unsorted linked list has O(n) time complexity.', NULL, 'true', 'You must traverse the list sequentially to find an element, giving O(n) complexity.', 2.00, 2, 2),
(4, 'mcq', 'What is a sentinel node in a linked list?', '["The first data node", "The last data node", "A dummy node used to simplify operations", "A node that stores metadata"]', '2', 'Sentinel nodes are dummy nodes that simplify boundary conditions and edge cases.', 3.00, 3, 3);

-- Questions for Quiz 5 (OOP Principles - course 5)
INSERT INTO `quiz_questions` (`quiz_id`, `question_type`, `question_text`, `options`, `correct_answer`, `explanation`, `points`, `order_index`, `difficulty_level_id`) VALUES
(5, 'mcq', 'What is encapsulation in OOP?', '["Inheriting from parent classes", "Bundling data with methods that operate on it", "Creating multiple objects", "Overriding methods"]', '1', 'Encapsulation bundles data and methods together and restricts direct access to internal state.', 2.00, 0, 2),
(5, 'mcq', 'Which keyword is used to inherit from a class in Java?', '["inherits", "extends", "implements", "derives"]', '1', 'Java uses the extends keyword for class inheritance.', 2.00, 1, 2),
(5, 'true_false', 'Polymorphism allows objects of different classes to be treated as objects of a common base class.', NULL, 'true', 'Polymorphism enables treating derived class objects as their base class type.', 2.00, 2, 2),
(5, 'mcq', 'What is the difference between abstraction and encapsulation?', '["They are the same", "Abstraction hides complexity, encapsulation hides implementation", "Abstraction is about data, encapsulation is about behavior", "Encapsulation hides complexity, abstraction hides implementation"]', '1', 'Abstraction hides complexity by showing only relevant details, while encapsulation hides internal implementation.', 3.00, 3, 3),
(5, 'essay', 'Describe the SOLID principles in object-oriented design and explain why they are important.', NULL, NULL, 'Should cover Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion.', 10.00, 4, 4);

-- Questions for Quiz 6 (Statistical Concepts - course 9)
INSERT INTO `quiz_questions` (`quiz_id`, `question_type`, `question_text`, `options`, `correct_answer`, `explanation`, `points`, `order_index`, `difficulty_level_id`) VALUES
(6, 'mcq', 'What is the mean of the numbers 2, 4, 6, 8, 10?', '["5", "6", "7", "8"]', '1', 'Mean = (2+4+6+8+10)/5 = 30/5 = 6', 2.00, 0, 2),
(6, 'mcq', 'What does standard deviation measure?', '["Central tendency", "Spread of data", "Correlation", "Probability"]', '1', 'Standard deviation measures how spread out the values are from the mean.', 2.00, 1, 2),
(6, 'true_false', 'The median is always equal to the mean in a normal distribution.', NULL, 'true', 'In a perfectly normal distribution, mean, median, and mode are all equal.', 2.00, 2, 3),
(6, 'mcq', 'What is a Type I error in hypothesis testing?', '["Rejecting a true null hypothesis", "Accepting a false null hypothesis", "Both", "Neither"]', '0', 'Type I error (false positive) occurs when we reject a null hypothesis that is actually true.', 3.00, 3, 3);

-- ============================================================
-- End of Quiz Test Data
-- ============================================================
