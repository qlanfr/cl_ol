#!/bin/bash

# 환경 변수 로드
source /opt/open-webui/.env

# Ollama 서비스 시작
ollama serve &

# Ollama 서비스가 시작될 때까지 대기
echo "Ollama 서비스 시작 중..."
until curl -s http://localhost:11434/api/tags > /dev/null; do
    sleep 2
done
echo "Ollama 서비스 시작됨"

# Phi3.5 모델 다운로드
echo "Phi3.5 모델 다운로드 중..."
ollama pull phi3.5

# Nginx 시작
echo "Nginx 시작 중..."
service nginx start

# OpenWebUI 환경 변수 설정이 있는지 확인
cd /opt/open-webui
if [ ! -f .env ]; then
    echo "OpenWebUI .env 파일 생성 중..."
    cp .env.example .env || echo "환경 변수 파일 복사 실패"
fi

# OpenWebUI 시작
echo "OpenWebUI 시작 중..."
conda activate ollama
python3.12 -m uvicorn main:app --host 0.0.0.0 --port 8080

# 모든 프로세스가 종료되지 않도록 대기
wait
