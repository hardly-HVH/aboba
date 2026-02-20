FROM python:3.11-slim

WORKDIR /app

# Создаем временные директории
RUN mkdir -p /tmp /var/tmp /usr/tmp /app/tmp && \
    chmod 1777 /tmp /var/tmp /usr/tmp /app/tmp && \
    echo "Temporary directories created: /tmp, /var/tmp, /usr/tmp, /app/tmp"

# Устанавливаем переменную для временных файлов
ENV TMPDIR=/tmp
ENV PYTHONUNBUFFERED=1

# Установка системных зависимостей
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libzbar0 \
    && rm -rf /var/lib/apt/lists/*

# Копируем requirements
COPY requirements.txt .

# Устанавливаем зависимости с явным указанием временной директории
RUN pip install --no-cache-dir --no-deps -r requirements.txt && \
    pip cache purge

# Копируем код
COPY smile.py .

# Создаем директории для данных
RUN mkdir -p /app/data /app/logs /app/qr_cache /app/backups && \
    chmod 777 /app/data /app/logs /app/qr_cache /app/backups

# Проверяем, что все работает
RUN python -c "import sys; print(f'Python version: {sys.version}')" && \
    python -c "import tempfile; print(f'Temp directory: {tempfile.gettempdir()}')"

CMD ["python", "smile.py"]