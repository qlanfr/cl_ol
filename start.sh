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


exec "$@"

wait
