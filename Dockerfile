FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_VISIBLE_DEVICES=""

# System deps
RUN apt-get update && apt-get install -y \
    ffmpeg curl git build-essential supervisor \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python — PyTorch CPU pra não explodir VRAM da MX150
COPY requirements*.txt ./
RUN pip install --no-cache-dir \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cpu \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir piper-tts

# Node — frontend
COPY remotion-composer/package*.json ./remotion-composer/
RUN cd remotion-composer && npm install

# Código
COPY . .
RUN cp .env.example .env

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8000 5173

CMD ["supervisord", "-n"]
