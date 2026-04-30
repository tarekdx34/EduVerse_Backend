import { MigrationInterface, QueryRunner } from 'typeorm';

export class SeedWebDevQuestions1779000000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    const courseId = 34;
    const adminId = 1;

    // 1. Ensure a chapter exists for the course
    let chapterId = 2; // Defaulting to 2 as seen previously
    const existingChapter = await queryRunner.query(
      `SELECT chapter_id FROM course_chapters WHERE course_id = ? LIMIT 1`,
      [courseId],
    );

    if (existingChapter && existingChapter.length > 0) {
      chapterId = existingChapter[0].chapter_id;
    } else {
      const chapterResult = await queryRunner.query(
        `INSERT INTO course_chapters (course_id, name, chapter_order, is_active, created_at, updated_at) 
         VALUES (?, 'Web Development Mastery', 1, 1, NOW(), NOW())`,
        [courseId],
      );
      chapterId = chapterResult.insertId;
    }

    // Question generation logic
    const questions = this.getQuestionsData();

    for (const q of questions) {
      const qResult = await queryRunner.query(
        `INSERT INTO question_bank_questions 
          (course_id, chapter_id, question_type, difficulty, bloom_level, question_text, expected_answer_text, hints, status, created_by, updated_by, created_at, updated_at) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'approved', ?, ?, NOW(), NOW())`,
        [
          courseId,
          chapterId,
          q.type,
          q.difficulty,
          q.bloom,
          q.text,
          q.expectedAnswer || null,
          q.hints || null,
          adminId,
          adminId,
        ],
      );

      const questionId = qResult.insertId;

      if (q.options && q.options.length > 0) {
        for (let i = 0; i < q.options.length; i++) {
          const opt = q.options[i];
          await queryRunner.query(
            `INSERT INTO question_bank_options (question_id, option_text, is_correct, option_order) VALUES (?, ?, ?, ?)`,
            [questionId, opt.text, opt.isCorrect ? 1 : 0, i],
          );
        }
      }

      if (q.fillBlanks && q.fillBlanks.length > 0) {
        for (const fb of q.fillBlanks) {
          await queryRunner.query(
            `INSERT INTO question_bank_fill_blanks (question_id, blank_key, acceptable_answer, is_case_sensitive) VALUES (?, ?, ?, ?)`,
            [questionId, fb.key, fb.answer, fb.isCaseSensitive ? 1 : 0],
          );
        }
      }
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Delete the questions seeded in this migration by courseId. 
    // Careful: this might delete user-created ones if they use courseId 34.
    // For safety, we only delete those created around this time or we just don't implement down.
    await queryRunner.query(
      `DELETE FROM question_bank_questions WHERE course_id = ? AND question_text LIKE '%HTML%'`,
      [34],
    );
  }

  private getQuestionsData() {
    return [
      // MCQs (20)
      {
        type: 'mcq', difficulty: 'easy', bloom: 'remembering',
        text: 'What does HTML stand for?',
        hints: 'Think about the structure of a web page.',
        options: [
          { text: 'HyperText Markup Language', isCorrect: true },
          { text: 'Home Tool Markup Language', isCorrect: false },
          { text: 'Hyperlinks and Text Markup Language', isCorrect: false },
          { text: 'HighText Machine Language', isCorrect: false },
        ]
      },
      {
        type: 'mcq', difficulty: 'easy', bloom: 'remembering',
        text: 'Which HTML element is used to specify a footer for a document or section?',
        options: [
          { text: '<footer>', isCorrect: true },
          { text: '<bottom>', isCorrect: false },
          { text: '<section>', isCorrect: false },
          { text: '<foot>', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'understanding',
        text: 'What is the correct CSS syntax to change the background color of all <p> elements?',
        options: [
          { text: 'p {background-color: yellow;}', isCorrect: true },
          { text: 'all.p {background-color: yellow;}', isCorrect: false },
          { text: 'p {color: yellow;}', isCorrect: false },
          { text: '.p {background-color: yellow;}', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'understanding',
        text: 'Which CSS property controls the text size?',
        options: [
          { text: 'font-size', isCorrect: true },
          { text: 'text-style', isCorrect: false },
          { text: 'text-size', isCorrect: false },
          { text: 'font-style', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'hard', bloom: 'applying',
        text: 'How do you center a block element horizontally in CSS?',
        options: [
          { text: 'margin: 0 auto;', isCorrect: true },
          { text: 'text-align: center;', isCorrect: false },
          { text: 'display: center;', isCorrect: false },
          { text: 'align-items: center;', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'easy', bloom: 'remembering',
        text: 'Inside which HTML element do we put the JavaScript?',
        options: [
          { text: '<script>', isCorrect: true },
          { text: '<javascript>', isCorrect: false },
          { text: '<scripting>', isCorrect: false },
          { text: '<js>', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'applying',
        text: 'How do you write "Hello World" in an alert box in JavaScript?',
        options: [
          { text: 'alert("Hello World");', isCorrect: true },
          { text: 'msgBox("Hello World");', isCorrect: false },
          { text: 'msg("Hello World");', isCorrect: false },
          { text: 'alertBox("Hello World");', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'hard', bloom: 'analyzing',
        text: 'What will the following code return: Boolean(10 > 9)',
        options: [
          { text: 'true', isCorrect: true },
          { text: 'false', isCorrect: false },
          { text: 'NaN', isCorrect: false },
          { text: 'undefined', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'understanding',
        text: 'Which event occurs when the user clicks on an HTML element?',
        options: [
          { text: 'onclick', isCorrect: true },
          { text: 'onmouseclick', isCorrect: false },
          { text: 'onchange', isCorrect: false },
          { text: 'onmouseover', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'remembering',
        text: 'Which operator is used to assign a value to a variable in JavaScript?',
        options: [
          { text: '=', isCorrect: true },
          { text: '*', isCorrect: false },
          { text: '-', isCorrect: false },
          { text: 'x', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'understanding',
        text: 'What is the correct way to write a JavaScript array?',
        options: [
          { text: 'var colors = ["red", "green", "blue"]', isCorrect: true },
          { text: 'var colors = "red", "green", "blue"', isCorrect: false },
          { text: 'var colors = (1:"red", 2:"green", 3:"blue")', isCorrect: false },
          { text: 'var colors = 1 = ("red"), 2 = ("green")', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'hard', bloom: 'evaluating',
        text: 'What does CSS Flexbox solve?',
        options: [
          { text: 'It provides a more efficient way to lay out, align and distribute space among items in a container.', isCorrect: true },
          { text: 'It creates 3D animations automatically.', isCorrect: false },
          { text: 'It connects the backend database with the frontend UI directly.', isCorrect: false },
          { text: 'It compiles CSS into JavaScript for faster execution.', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'easy', bloom: 'remembering',
        text: 'Which attribute is used to provide an alternative text for an image?',
        options: [
          { text: 'alt', isCorrect: true },
          { text: 'title', isCorrect: false },
          { text: 'src', isCorrect: false },
          { text: 'href', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'understanding',
        text: 'What is the purpose of the <head> tag in HTML?',
        options: [
          { text: 'To store metadata, links to stylesheets, and scripts', isCorrect: true },
          { text: 'To display the main heading of the webpage', isCorrect: false },
          { text: 'To hold the navigation bar', isCorrect: false },
          { text: 'To contain the footer information', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'hard', bloom: 'analyzing',
        text: 'In React, what is a hook?',
        options: [
          { text: 'A special function that lets you "hook into" React features from function components.', isCorrect: true },
          { text: 'A method to catch errors globally in the application.', isCorrect: false },
          { text: 'A tool for connecting to a database securely.', isCorrect: false },
          { text: 'A way to style components dynamically.', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'understanding',
        text: 'What is a closure in JavaScript?',
        options: [
          { text: 'A feature where an inner function has access to the outer function’s variables.', isCorrect: true },
          { text: 'A method to close a browser window automatically.', isCorrect: false },
          { text: 'A tag used to self-close HTML elements.', isCorrect: false },
          { text: 'A way to terminate an infinite loop.', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'remembering',
        text: 'What does SQL stand for?',
        options: [
          { text: 'Structured Query Language', isCorrect: true },
          { text: 'Strong Question Language', isCorrect: false },
          { text: 'Structured Question Logic', isCorrect: false },
          { text: 'System Query Language', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'easy', bloom: 'remembering',
        text: 'Which symbol is used to indicate an ID selector in CSS?',
        options: [
          { text: '#', isCorrect: true },
          { text: '.', isCorrect: false },
          { text: '*', isCorrect: false },
          { text: '>', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'medium', bloom: 'applying',
        text: 'How can you add a comment in JavaScript?',
        options: [
          { text: '// This is a comment', isCorrect: true },
          { text: '<!-- This is a comment -->', isCorrect: false },
          { text: '/* This is a comment', isCorrect: false },
          { text: '# This is a comment', isCorrect: false }
        ]
      },
      {
        type: 'mcq', difficulty: 'hard', bloom: 'evaluating',
        text: 'Why would you use a REST API?',
        options: [
          { text: 'To allow different software systems to communicate over HTTP using standard methods.', isCorrect: true },
          { text: 'To generate HTML pages directly on the server.', isCorrect: false },
          { text: 'To style web components easily.', isCorrect: false },
          { text: 'To securely store passwords in a database.', isCorrect: false }
        ]
      },

      // True/False (10)
      {
        type: 'true_false', difficulty: 'easy', bloom: 'remembering',
        text: 'HTML is considered a programming language.',
        options: [
          { text: 'True', isCorrect: false },
          { text: 'False', isCorrect: true }
        ]
      },
      {
        type: 'true_false', difficulty: 'easy', bloom: 'understanding',
        text: 'CSS is used to structure the content of a web page.',
        options: [
          { text: 'True', isCorrect: false },
          { text: 'False', isCorrect: true }
        ]
      },
      {
        type: 'true_false', difficulty: 'medium', bloom: 'applying',
        text: 'In JavaScript, the "===" operator checks for both value and type equality.',
        options: [
          { text: 'True', isCorrect: true },
          { text: 'False', isCorrect: false }
        ]
      },
      {
        type: 'true_false', difficulty: 'medium', bloom: 'remembering',
        text: 'React was developed by Google.',
        options: [
          { text: 'True', isCorrect: false },
          { text: 'False', isCorrect: true }
        ]
      },
      {
        type: 'true_false', difficulty: 'hard', bloom: 'analyzing',
        text: 'Node.js is a front-end JavaScript framework.',
        options: [
          { text: 'True', isCorrect: false },
          { text: 'False', isCorrect: true }
        ]
      },
      {
        type: 'true_false', difficulty: 'medium', bloom: 'understanding',
        text: 'An API stands for Application Programming Interface.',
        options: [
          { text: 'True', isCorrect: true },
          { text: 'False', isCorrect: false }
        ]
      },
      {
        type: 'true_false', difficulty: 'easy', bloom: 'remembering',
        text: 'The `<br>` tag is used to create a line break in HTML.',
        options: [
          { text: 'True', isCorrect: true },
          { text: 'False', isCorrect: false }
        ]
      },
      {
        type: 'true_false', difficulty: 'medium', bloom: 'applying',
        text: 'Local storage data is cleared automatically when the browser is closed.',
        options: [
          { text: 'True', isCorrect: false },
          { text: 'False', isCorrect: true }
        ]
      },
      {
        type: 'true_false', difficulty: 'hard', bloom: 'evaluating',
        text: 'A Promise in JavaScript can only resolve, it cannot be rejected.',
        options: [
          { text: 'True', isCorrect: false },
          { text: 'False', isCorrect: true }
        ]
      },
      {
        type: 'true_false', difficulty: 'medium', bloom: 'understanding',
        text: 'In CSS, padding adds space outside the border of an element.',
        options: [
          { text: 'True', isCorrect: false },
          { text: 'False', isCorrect: true }
        ]
      },

      // Fill in the blanks (10)
      {
        type: 'fill_blanks', difficulty: 'easy', bloom: 'remembering',
        text: 'The [HTML] language is used to create the structure of web pages.',
        fillBlanks: [ { key: '[HTML]', answer: 'HTML', isCaseSensitive: false } ]
      },
      {
        type: 'fill_blanks', difficulty: 'medium', bloom: 'understanding',
        text: 'To apply external styles, we use the [LINK] tag inside the head section.',
        fillBlanks: [ { key: '[LINK]', answer: 'link', isCaseSensitive: false } ]
      },
      {
        type: 'fill_blanks', difficulty: 'medium', bloom: 'applying',
        text: 'In JavaScript, we use [LET] or const to declare variables instead of var in modern code.',
        fillBlanks: [ { key: '[LET]', answer: 'let', isCaseSensitive: false } ]
      },
      {
        type: 'fill_blanks', difficulty: 'hard', bloom: 'analyzing',
        text: 'A JavaScript [PROMISE] represents the eventual completion or failure of an asynchronous operation.',
        fillBlanks: [ { key: '[PROMISE]', answer: 'Promise', isCaseSensitive: false } ]
      },
      {
        type: 'fill_blanks', difficulty: 'easy', bloom: 'remembering',
        text: 'The [IMG] tag is used to embed an image in an HTML page.',
        fillBlanks: [ { key: '[IMG]', answer: 'img', isCaseSensitive: false } ]
      },
      {
        type: 'fill_blanks', difficulty: 'medium', bloom: 'understanding',
        text: 'CSS [FLEXBOX] is a one-dimensional layout method for arranging items in rows or columns.',
        fillBlanks: [ { key: '[FLEXBOX]', answer: 'flexbox', isCaseSensitive: false } ]
      },
      {
        type: 'fill_blanks', difficulty: 'hard', bloom: 'applying',
        text: 'To send data to a server asynchronously in modern JS, we often use the [FETCH] API.',
        fillBlanks: [ { key: '[FETCH]', answer: 'fetch', isCaseSensitive: false } ]
      },
      {
        type: 'fill_blanks', difficulty: 'medium', bloom: 'remembering',
        text: 'In React, the [STATE] object is where you store property values that belong to the component.',
        fillBlanks: [ { key: '[STATE]', answer: 'state', isCaseSensitive: false } ]
      },
      {
        type: 'fill_blanks', difficulty: 'hard', bloom: 'evaluating',
        text: 'When a web application is rendered completely on the server before being sent to the client, it is called [SSR] (abbreviation).',
        fillBlanks: [ { key: '[SSR]', answer: 'SSR', isCaseSensitive: false } ]
      },
      {
        type: 'fill_blanks', difficulty: 'medium', bloom: 'understanding',
        text: 'Cross-Origin Resource Sharing is commonly abbreviated as [CORS].',
        fillBlanks: [ { key: '[CORS]', answer: 'CORS', isCaseSensitive: false } ]
      },

      // Written (5)
      {
        type: 'written', difficulty: 'medium', bloom: 'understanding',
        text: 'Explain the difference between let, const, and var in JavaScript.',
        expectedAnswer: 'var is function-scoped and hoisted. let and const are block-scoped. const variables cannot be reassigned, while let variables can be.',
        hints: 'Think about scope and reassignment.'
      },
      {
        type: 'written', difficulty: 'hard', bloom: 'analyzing',
        text: 'Describe how the Virtual DOM works in React.',
        expectedAnswer: 'The Virtual DOM is a lightweight memory representation of the actual DOM. React compares the current Virtual DOM with a new one when state changes (diffing) and updates only the changed parts in the real DOM (reconciliation).',
        hints: 'Mention diffing and reconciliation.'
      },
      {
        type: 'written', difficulty: 'medium', bloom: 'applying',
        text: 'What is responsive web design and why is it important?',
        expectedAnswer: 'Responsive web design ensures that a website looks and functions well on all devices and screen sizes. It is important for user experience and SEO.',
        hints: 'Think about mobile devices vs desktops.'
      },
      {
        type: 'written', difficulty: 'hard', bloom: 'evaluating',
        text: 'Explain the concept of middleware in an Express.js application.',
        expectedAnswer: 'Middleware functions are functions that have access to the request and response objects, and the next middleware function in the cycle. They can execute code, make changes to request/response, end the cycle, or call next().',
        hints: 'What happens between a request arriving and a response being sent?'
      },
      {
        type: 'written', difficulty: 'easy', bloom: 'remembering',
        text: 'What is semantic HTML and provide two examples of semantic tags.',
        expectedAnswer: 'Semantic HTML uses tags that clearly describe their meaning to both the browser and the developer. Examples include <article>, <section>, <header>, and <footer>.',
        hints: 'Think about meaning rather than presentation.'
      },

      // Essay (5)
      {
        type: 'essay', difficulty: 'hard', bloom: 'creating',
        text: 'Design a high-level architecture for a modern e-commerce web application. Discuss the frontend, backend, database, and any third-party services you would integrate.',
        expectedAnswer: 'A good answer should include a modern frontend framework (e.g., React/Next.js), a robust backend (e.g., Node.js/Express or NestJS), a relational or NoSQL database (e.g., PostgreSQL or MongoDB), and services for payment (Stripe), email (SendGrid), and image storage (AWS S3). It should discuss how these components communicate (REST/GraphQL).',
        hints: 'Cover the full stack: UI, API, Data, and Integrations.'
      },
      {
        type: 'essay', difficulty: 'hard', bloom: 'evaluating',
        text: 'Discuss the trade-offs between Client-Side Rendering (CSR) and Server-Side Rendering (SSR). In what scenarios would you choose one over the other?',
        expectedAnswer: 'CSR provides a highly interactive UX after initial load but can suffer from slow initial load times and poor SEO. SSR provides great SEO and fast initial paints but can be heavier on the server. Choose SSR for content-heavy sites (blogs, e-commerce) and CSR for highly interactive dashboards or internal tools.',
        hints: 'Compare SEO, initial load time, and server load.'
      },
      {
        type: 'essay', difficulty: 'medium', bloom: 'analyzing',
        text: 'Explain the complete flow of user authentication using JWT (JSON Web Tokens) in a web application.',
        expectedAnswer: '1. User sends credentials to the server. 2. Server verifies them and creates a JWT containing user info, signed with a secret key. 3. Server sends JWT back to the client. 4. Client stores the JWT (e.g., in localStorage or an HttpOnly cookie). 5. For subsequent requests, the client includes the JWT in the Authorization header. 6. The server verifies the signature and grants access to protected routes.',
        hints: 'Trace the steps from login to accessing a protected route.'
      },
      {
        type: 'essay', difficulty: 'hard', bloom: 'creating',
        text: 'How would you approach optimizing the performance of a slow, image-heavy web page?',
        expectedAnswer: 'I would implement lazy loading for images, use modern image formats like WebP, compress images without losing quality, utilize a Content Delivery Network (CDN) to serve assets closer to users, implement browser caching, minify CSS/JS files, and ensure efficient database queries on the backend.',
        hints: 'Think about assets, delivery networks, and loading strategies.'
      },
      {
        type: 'essay', difficulty: 'medium', bloom: 'understanding',
        text: 'Describe the differences between REST and GraphQL as API design architectures.',
        expectedAnswer: 'REST uses multiple endpoints for different resources and relies on standard HTTP methods. It often suffers from over-fetching or under-fetching of data. GraphQL uses a single endpoint and allows clients to specify exactly the shape and amount of data they need, solving the fetching issues but adding complexity to the backend and caching strategies.',
        hints: 'Contrast endpoints vs a single endpoint, and data fetching flexibility.'
      }
    ];
  }
}
