const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const root = path.resolve(__dirname, '..');
const dir = path.join(root, 'ai-services', 'quiz-generator');
const isWin = process.platform === 'win32';
const py = path.join(
  dir,
  isWin ? path.join('.venv', 'Scripts', 'python.exe') : path.join('.venv', 'bin', 'python'),
);

if (!fs.existsSync(py)) {
  console.error('Quiz venv not found. Run: npm run quiz:install');
  process.exit(1);
}

const args = ['-m', 'uvicorn', 'app.main:app', '--reload', '--host', '127.0.0.1', '--port', '8001'];
const proc = spawn(py, args, { cwd: dir, stdio: 'inherit', env: process.env });
proc.on('exit', (code) => process.exit(code === null ? 1 : code));
