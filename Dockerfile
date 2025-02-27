
FROM ubuntu:22.04


ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1


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


RUN curl -fsSL https://ollama.com/install.sh | sh


RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y python3.12 python3.12-venv python3.12-dev python3.12-distutils \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12


RUN wget -O Miniforge3.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh \
    && bash Miniforge3.sh -b -p /opt/conda \
    && rm Miniforge3.sh
ENV PATH=/opt/conda/bin:$PATH

RUN conda create -n ollama python=3.12 -y
SHELL ["conda", "run", "-n", "ollama", "/bin/bash", "-c"]
RUN pip install numpy pandas requests psycopg2-binary ollama python-dotenv


RUN git clone https://github.com/open-webui/open-webui.git /opt/open-webui
WORKDIR /opt/open-webui
RUN pip install -r requirements.txt


RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=KR/ST=State/L=City/O=Organization/CN=localhost"


COPY nginx.conf /etc/nginx/sites-available/default
COPY .env /opt/open-webui/.env


EXPOSE 80 443 11434


COPY start.sh /start.sh
RUN chmod +x /start.sh


CMD ["/start.sh"]
