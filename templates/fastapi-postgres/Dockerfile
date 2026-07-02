FROM python:3.12-slim

WORKDIR /app

# Install dependencies first for layer caching; source changes don't bust this layer
COPY pyproject.toml ./
RUN pip install --no-cache-dir uv && uv pip install --system --no-cache -r pyproject.toml

COPY app ./app

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
