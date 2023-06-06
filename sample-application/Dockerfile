# Build:
# docker build . -t chatbot
# Test:
# docker run --rm -p 8501:8501  -v ./.env:/app/.env chatbot

FROM python:3.10.11-slim-bullseye

WORKDIR /app

RUN mkdir -p /app/data

COPY requirements.txt /app

RUN apt-get -y update && \
    apt-get install -y libmagic-mgc libmagic1 && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pip install -U pip && pip install --no-cache-dir -r requirements.txt && \
    adduser --disabled-password --gecos '' appuser

COPY chatbot.py /app


EXPOSE 8501

ENTRYPOINT ["streamlit", "run", "chatbot.py", "--server.port=8501", "--server.address=0.0.0.0"]
