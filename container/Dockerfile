FROM ubuntu:22.04

RUN apt update
RUN apt install -y python3-dev python3-pip 

ENV DEBIAN_FRONTEND=noninteractive
COPY src /src
RUN pip install -r /src/requirements.txt

EXPOSE 80
CMD gunicorn --chdir ./src --bind 0.0.0.0:80 --workers=1 wsgi:app
