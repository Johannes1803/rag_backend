FROM python:3.12-slim AS builder

# Build argument for cache busting (e.g., docker build --build-arg REBUILD_TAG=$(date +%s) .)
ARG REBUILD_TAG=unknown
# Output the tag to show it was applied during build
RUN echo "Build with REBUILD_TAG=${REBUILD_TAG}"

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Update pip
RUN pip install --upgrade pip
# Install Poetry and update to the latest version
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"
RUN poetry self update

# Set up working directory
WORKDIR /app

# Copy only the dependency files
COPY pyproject.toml poetry.lock* ./

# Install dependencies into the virtual environment
RUN poetry install --no-root && \
    rm -rf $POETRY_CACHE_DIR

# Start a new stage for a smaller final image
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
    
# Install HayHooks in the final image to ensure it's available
RUN pip install hayhooks==0.2.0

# Copy virtual environment from builder stage
COPY --from=builder /app/.venv /app/.venv

# Set up working directory
WORKDIR /app

# Copy your application code
COPY rag_backend .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
