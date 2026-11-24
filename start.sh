#!/usr/bin/env bash
set -e

# Auto-navigate to backend if in project root
if [ -d "backend" ]; then
  cd backend
fi

TARGET_PORT="${PORT:-8000}"
echo "==> Launching FastAPI Uvicorn server on 0.0.0.0:$TARGET_PORT..."
exec uvicorn app.main:app --host 0.0.0.0 --port "$TARGET_PORT"
