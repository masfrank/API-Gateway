# Build stage - Install dependencies
FROM python:3.10-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc g++ && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python packages
COPY ./requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Runtime stage - Create minimal image
FROM python:3.10-slim

WORKDIR /app

# Install curl for healthcheck and debugging
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user for security first
RUN useradd -m -u 1000 appuser

# Copy Python packages from builder (system-wide installation)
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application files
COPY ./VERSION /app/
COPY ./app /app/app
COPY ./robots.txt /app/

# Create data directory for SQLite database (if used)
RUN mkdir -p /app/data

# Change ownership of app directory (including data folder)
RUN chown -R appuser:appuser /app

# Set environment variables
ENV API_KEYS='["your_api_key_1"]'
ENV ALLOWED_TOKENS='["your_token_1"]'
ENV TZ='Asia/Shanghai'
ENV PYTHONUNBUFFERED=1

USER appuser

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--no-access-log"]
