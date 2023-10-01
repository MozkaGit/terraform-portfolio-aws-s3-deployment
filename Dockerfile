FROM ubuntu:18.04
LABEL maintainer="MozkaGit"

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

EXPOSE 80

RUN rm -rf /var/www/html/*
ADD www/ /var/www/html/

COPY nginx.conf /etc/nginx/conf.d/default.conf

CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'