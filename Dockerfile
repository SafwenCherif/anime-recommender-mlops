FROM python:3.12-slim

# Set environment variables to prevent Python from writing .pyc files & Ensure Python output is not buffered
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies required by TensorFlow and LightGBM
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the application code (model already trained in Jenkins workspace)
COPY . .

# Install dependencies from requirements.txt
RUN pip install --no-cache-dir --default-timeout=100 --retries=5 -e .

# Create necessary directories
RUN mkdir -p artifacts/raw artifacts/processed artifacts/model artifacts/weights artifacts/model_checkpoint

# Expose the port that Flask will run on
ENV PORT=8080
EXPOSE 8080

# Command to run the app
CMD ["python", "application.py"]


