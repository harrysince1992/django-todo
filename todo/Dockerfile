FROM python:3.6-alpine

ENV PYTHONUNBUFFERED 1

WORKDIR /code

RUN mkdir -p /code/gunicorn/

COPY requirements.txt /code/requirements.txt

RUN pip install -r requirements.txt

COPY . /code/

RUN python manage.py collectstatic --noinput

RUN python manage.py migrate



