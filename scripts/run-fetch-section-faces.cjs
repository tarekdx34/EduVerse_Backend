/**
 * Runs ai-services/attendance/fetch_section_faces.py with the local venv Python.
 * Usage (from EduVerse-Backend): npm run attendance:fetch-faces -- --audit-only
 */
const { spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const root = path.resolve(__dirname, '..');
const dir = path.join(root, 'ai-services', 'attendance');
const isWin = process.platform === 'win32';
const py = path.join(
  dir,
  isWin ? path.join('.venv', 'Scripts', 'python.exe') : path.join('.venv', 'bin', 'python'),
);
const script = path.join(dir, 'fetch_section_faces.py');

if (!fs.existsSync(py)) {
  console.error('Attendance venv not found. Run: npm run attendance:install');
  process.exit(1);
}

const args = [script, ...process.argv.slice(2)];
const r = spawnSync(py, args, { stdio: 'inherit', cwd: root, env: process.env });
process.exit(r.status === null ? 1 : r.status);
