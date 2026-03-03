import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable CORS
  app.enableCors({
    origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Swagger Configuration
  const config = new DocumentBuilder()
    .setTitle('EduVerse API')
    .setDescription(`
## EduVerse Backend API Documentation

### Overview
EduVerse is a comprehensive educational platform API that provides endpoints for managing:
- **Authentication & Authorization** - User registration, login, JWT tokens, and role management
- **Campus Management** - Campuses, departments, programs, and semesters
- **Course Management** - Courses, sections, and schedules
- **Enrollment System** - Student course registration and waitlist management
- **File Management** - File uploads, folders, and permissions
- **YouTube Integration** - Video uploads and management

### Authentication
Most endpoints require JWT Bearer token authentication. To authenticate:
1. Use the \`/api/auth/login\` endpoint to obtain an access token
2. Click the **Authorize** button (🔓) at the top of this page
3. Enter your token in the format: \`Bearer <your-access-token>\`
4. Click **Authorize** to apply the token to all requests

### Role-Based Access Control (RBAC)
The API implements role-based access control with the following roles:
| Role | Description |
|------|-------------|
| **STUDENT** | Regular student users - can enroll in courses, view materials |
| **INSTRUCTOR** | Faculty members - can manage course content, view enrollments |
| **TA** | Teaching assistants - limited instructor capabilities |
| **ADMIN** | Administrative staff - can manage users, courses, and campus data |
| **IT_ADMIN** | IT administrators - full system access |

### Response Codes
| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (successful deletion) |
| 400 | Bad Request - Invalid input data |
| 401 | Unauthorized - Missing or invalid token |
| 403 | Forbidden - Insufficient role permissions |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Resource already exists |
| 500 | Internal Server Error |
    `)
    .setVersion('1.0.0')
    .setContact('EduVerse Team', 'https://eduverse.com', 'support@eduverse.com')
    .setLicense('MIT', 'https://opensource.org/licenses/MIT')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter your JWT access token obtained from /api/auth/login',
        in: 'header',
      },
      'JWT-auth',
    )
    .addTag('🔐 Authentication', 'User authentication, registration, and session management')
    .addTag('👥 User Management', 'Admin endpoints for managing users, roles, and permissions')
    .addTag('🏛️ Campus', 'Campus management endpoints')
    .addTag('🏢 Departments', 'Department management within campuses')
    .addTag('📚 Programs', 'Academic program management')
    .addTag('📅 Semesters', 'Semester and academic period management')
    .addTag('📖 Courses', 'Course catalog and management')
    .addTag('📝 Course Sections', 'Course section and schedule management')
    .addTag('🕐 Course Schedules', 'Course schedule (day/time) management per section')
    .addTag('✅ Enrollments', 'Student course enrollment and registration')
    .addTag('📝 Assignments', 'Assignment creation, submission, and grading')
    .addTag('📊 Grades', 'Grade management, GPA calculation, and transcripts')
    .addTag('📋 Rubrics', 'Grading rubric management')
    .addTag('📁 Files', 'File upload, download, and management')
    .addTag('📂 Folders', 'Folder organization and hierarchy')
    .addTag('🎬 YouTube', 'YouTube video integration and uploads')
    .addTag('📋 Attendance', 'Attendance session and record management')
    .addTag('📝 Quizzes', 'Quiz creation, questions, attempts, and grading')
    .addTag('Labs', 'Lab assignments, submissions, instructions, and attendance')
    .addTag('Notifications', 'User notifications, preferences, and admin broadcast')
    .addTag('💬 Messaging', 'WhatsApp-like real-time messaging with conversations, read receipts, and file sharing')
    .addTag('💭 Discussions', 'Course discussion forums with threads, replies, pinning, and answer marking')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document, {
    customSiteTitle: 'EduVerse API Documentation',
    customfavIcon: 'https://nestjs.com/img/logo-small.svg',
    customCss: `
      .swagger-ui .topbar { display: none }
      .swagger-ui .info .title { color: #3b82f6; }
      .swagger-ui .scheme-container { background: #f8fafc; padding: 15px; border-radius: 8px; }
    `,
    swaggerOptions: {
      persistAuthorization: true,
      docExpansion: 'none',
      filter: true,
      showRequestDuration: true,
      syntaxHighlight: {
        activate: true,
        theme: 'monokai',
      },
    },
  });

  const port = process.env.PORT || 3001;

  await app.listen(port, '0.0.0.0');

  console.log(`🚀 Application is running on: http://localhost:${port}`);
  console.log(`📚 Swagger API Documentation: http://localhost:${port}/api-docs`);
}
bootstrap();
