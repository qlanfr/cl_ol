
FROM ubuntu:22.04

FROM python:3.11-slim


WORKDIR /app


RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    && rm -rf /var/lib/apt/lists/*


RUN curl -fsSL https://ollama.com/install.sh | sh


COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt


COPY nginx.conf /etc/nginx/nginx.conf


COPY start.sh /start.sh
RUN chmod +x /start.sh


COPY . /app


EXPOSE 80 8080 11434


CMD ["/start.sh"]

