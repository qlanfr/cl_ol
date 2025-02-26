# ARM 기반 우분투 이미지 사용
FROM ubuntu:22.04

# 환경 변수 설정
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 기본 패키지 설치
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    nginx \
    openssl \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Ollama 설치 (ARM 지원 버전)
RUN curl -fsSL https://ollama.com/install.sh | sh

# Python 3.12 설치
RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y python3.12 python3.12-venv python3.12-dev python3.12-distutils \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Conda 설치 (ARM 호환 버전 - Miniforge)
RUN wget -O Miniforge3.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh \
    && bash Miniforge3.sh -b -p /opt/conda \
    && rm Miniforge3.sh
ENV PATH=/opt/conda/bin:$PATH

# Conda 환경 생성 및 Python 패키지 설치
RUN conda create -n ollama python=3.12 -y
SHELL ["conda", "run", "-n", "ollama", "/bin/bash", "-c"]
RUN pip install numpy pandas requests psycopg2-binary ollama python-dotenv

# OpenWebUI 설치
RUN git clone https://github.com/open-webui/open-webui.git /opt/open-webui
WORKDIR /opt/open-webui
RUN pip install -r requirements.txt

# Nginx HTTPS 설정
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=KR/ST=State/L=City/O=Organization/CN=localhost"

# 설정 파일 복사
COPY nginx.conf /etc/nginx/sites-available/default
COPY .env /opt/open-webui/.env

# 포트 노출
EXPOSE 80 443 11434

# 시작 스크립트 복사 및 실행 권한 부여
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 시작 명령
CMD ["/start.sh"]
