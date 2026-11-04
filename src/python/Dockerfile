FROM python:3.11.11-slim
WORKDIR /app
COPY src/python/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/python/main.py src/python/main.py
CMD ["python", "-u", "src/python/main.py"]
