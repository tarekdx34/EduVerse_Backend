const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const root = path.resolve(__dirname, '..');
const dir = path.join(root, 'ai-services', 'attendance');
const isWin = process.platform === 'win32';
const py = path.join(
  dir,
  isWin
    ? path.join('.venv', 'Scripts', 'python.exe')
    : path.join('.venv', 'bin', 'python'),
);

if (!fs.existsSync(py)) {
  console.error('Attendance venv not found. Run: npm run attendance:install');
  process.exit(1);
}

const args = [
  '-m',
  'uvicorn',
  'api_main:app',
  '--reload',
  // Dev-only script; changes used to trigger a full reload and looked like a crash
  '--reload-exclude',
  'fetch_section_faces.py',
  '--host',
  '127.0.0.1',
  '--port',
  '8000',
];

const proc = spawn(py, args, { cwd: dir, stdio: 'inherit', env: process.env });
proc.on('exit', (code) => process.exit(code === null ? 1 : code));
