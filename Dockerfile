FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8000

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install lightweight CPU-only PyTorch first
RUN pip install --upgrade pip && \
    pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

# Install backend dependencies
COPY backend/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend application
COPY backend/ .

# Ensure runtime directories exist
RUN mkdir -p data/raw data/processed data/reference models artifacts reports

# Prepare data splits
RUN python scripts/prepare_data.py || true

EXPOSE 8000 10000

CMD sh -c "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"

