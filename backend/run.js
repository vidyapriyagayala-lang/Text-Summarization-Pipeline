const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// Determine Python executable: prefer backend/.venv, then ../.venv, then active venv, then python, then py
function getPythonExe() {
  const isWin = process.platform === 'win32';
  const venvScript = isWin ? path.join('Scripts', 'python.exe') : path.join('bin', 'python');

  const candidates = [
    path.join(__dirname, '.venv', venvScript),
    path.join(__dirname, '..', '.venv', venvScript),
    process.env.VIRTUAL_ENV ? path.join(process.env.VIRTUAL_ENV, venvScript) : null,
  ].filter(Boolean);

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) {


      return candidate;
    }
  }

  return isWin ? 'python' : 'python3';
}

const python = getPythonExe();
const command = process.argv[2] || 'start';

let args = [];
if (command === 'start') {
  args = ['-m', 'uvicorn', 'app.main:app', '--host', '127.0.0.1', '--port', '8000', '--reload'];
} else if (command === 'mlflow') {
  args = [
    '-m', 'mlflow', 'server',
    '--backend-store-uri', 'sqlite:///mlflow.db',
    '--default-artifact-root', './mlflow-artifacts',
    '--host', '127.0.0.1',
    '--port', '5000'
  ];
} else if (command === 'test') {
  args = ['-m', 'pytest', 'tests/', '-v'];
} else {
  args = process.argv.slice(2);
}

const env = {
  ...process.env,
  PYTHONPATH: process.env.PYTHONPATH ? `${__dirname}${path.delimiter}${process.env.PYTHONPATH}` : __dirname,
};

const child = spawn(python, args, {
  cwd: __dirname,
  stdio: 'inherit',
  shell: false,
  env
});

child.on('error', (err) => {
  console.error(`Failed to start process using "${python}":`, err.message);
  process.exit(1);
});

child.on('exit', (code) => {
  process.exit(code || 0);
});
