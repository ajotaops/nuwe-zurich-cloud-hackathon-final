FROM python:3.11-alpine

ENV FLASK_DEBUG=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install --upgrade pip

COPY src/ .

RUN pip3 install -r requirements.txt

CMD ["python3", "-u", "-m" , "flask", "run", "--host=0.0.0.0"]

