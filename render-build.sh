#!/usr/bin/env bash
set -e

# Auto-navigate to backend if in project root
if [ -d "backend" ]; then
  cd backend
fi

echo "=========================================="
echo "==> 1. Upgrading pip and packaging tools..."
echo "=========================================="
python -m pip install --upgrade --no-cache-dir pip setuptools wheel

echo "=========================================="
echo "==> 2. Installing CPU-only PyTorch (prevents OOM / timeouts on Render)..."
echo "=========================================="
python -m pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

echo "=========================================="
echo "==> 3. Installing dependencies..."
echo "=========================================="
python -m pip install --no-cache-dir -r requirements.txt

echo "=========================================="
echo "==> 4. Preparing dataset splits..."
echo "=========================================="
python scripts/prepare_data.py || true

echo "=========================================="
echo "==> Build finished successfully!"
echo "=========================================="
