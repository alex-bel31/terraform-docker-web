FROM python:3.9-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt
COPY . .

FROM python:3.9-slim

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /build /app
CMD ["python", "main.py"]
