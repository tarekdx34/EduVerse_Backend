const fs = require('fs');
const path = require('path');

const collectionPath = path.join(__dirname, '..', 'EduVerse_APIDog_Collection.json');
const data = fs.readFileSync(collectionPath, 'utf8');
const collection = JSON.parse(data);

const newFolder = {
  name: "📝 X. Question Bank & Exams (Added via AI)",
  item: [
    {
      name: "Get Chapters for Course 34",
      request: {
        method: "GET",
        header: [{ key: "Content-Type", value: "application/json" }],
        url: {
          raw: "{{baseUrl}}/api/courses/34/chapters",
          host: ["{{baseUrl}}"],
          path: ["api", "courses", "34", "chapters"]
        },
        auth: {
          type: "bearer",
          bearer: [{ key: "token", value: "{{instructorToken}}", type: "string" }]
        }
      },
      response: []
    },
    {
      name: "List Questions for Course 34",
      request: {
        method: "GET",
        header: [{ key: "Content-Type", value: "application/json" }],
        url: {
          raw: "{{baseUrl}}/api/question-bank/questions?courseId=34&limit=50",
          host: ["{{baseUrl}}"],
          path: ["api", "question-bank", "questions"],
          query: [
            { key: "courseId", value: "34" },
            { key: "limit", value: "50" }
          ]
        },
        auth: {
          type: "bearer",
          bearer: [{ key: "token", value: "{{instructorToken}}", type: "string" }]
        }
      },
      response: []
    },
    {
      name: "Generate Exam Preview",
      request: {
        method: "POST",
        header: [{ key: "Content-Type", value: "application/json" }],
        url: {
          raw: "{{baseUrl}}/api/exams/generate-preview",
          host: ["{{baseUrl}}"],
          path: ["api", "exams", "generate-preview"]
        },
        auth: {
          type: "bearer",
          bearer: [{ key: "token", value: "{{instructorToken}}", type: "string" }]
        },
        body: {
          mode: "raw",
          raw: JSON.stringify({
            courseId: 34,
            title: "Web Development Final Exam",
            rules: [
              {
                chapterId: 2,
                count: 5,
                weightPerQuestion: 2,
                questionType: "mcq"
              },
              {
                chapterId: 2,
                count: 3,
                weightPerQuestion: 3,
                questionType: "true_false"
              },
              {
                chapterId: 2,
                count: 2,
                weightPerQuestion: 5,
                questionType: "essay"
              }
            ]
          }, null, 2)
        }
      },
      response: []
    }
  ]
};

// Check if folder already exists to avoid duplicates
const existingIndex = collection.item.findIndex(i => i.name.includes("Question Bank & Exams"));
if (existingIndex >= 0) {
  collection.item[existingIndex] = newFolder;
} else {
  collection.item.push(newFolder);
}

fs.writeFileSync(collectionPath, JSON.stringify(collection, null, 2));
console.log('Successfully updated EduVerse_APIDog_Collection.json!');
