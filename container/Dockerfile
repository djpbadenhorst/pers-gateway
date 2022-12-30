FROM ubuntu:22.04

RUN apt update
RUN apt install -y nginx python3-dev python3-pip 

ENV DEBIAN_FRONTEND=noninteractive
COPY webapp /webapp
RUN pip install -r /webapp/requirements.txt

RUN mkdir -p /www/
COPY nginx/data /www/data
     
RUN mkdir -p /etc/nginx/conf.d/nginx.conf
COPY nginx/nginx.conf /etc/nginx/conf.d/

EXPOSE 80
COPY entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh
