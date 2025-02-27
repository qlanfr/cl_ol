#!/bin/bash


source /opt/open-webui/.env


ollama serve &


echo "Ollama 서비스 시작 중..."
until curl -s http://localhost:11434/api/tags > /dev/null; do
    sleep 2
done
echo "Ollama 서비스 시작됨"

echo "gemma2 모델 다운로드 중..."
ollama pull gemma2:2b


echo "Nginx 시작 중..."
service nginx start


cd /opt/open-webui
if [ ! -f .env ]; then
    echo "OpenWebUI .env 파일 생성 중..."
    cp .env.example .env || echo "환경 변수 파일 복사 실패"
fi


echo "OpenWebUI 시작 중..."
conda activate ollama
python3.12 -m uvicorn main:app --host 0.0.0.0 --port 8080


wait
