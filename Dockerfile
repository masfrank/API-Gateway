FROM python:3.10-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY ./requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY ./VERSION /app/
COPY ./app /app/app
COPY ./robots.txt /app/

# Create data directory for SQLite database
RUN mkdir -p /app/data

# Set environment variables
ENV API_KEYS='["your_api_key_1"]'
ENV ALLOWED_TOKENS='["your_token_1"]'
ENV TZ='Asia/Shanghai'
ENV PYTHONUNBUFFERED=1

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--no-access-log"]
