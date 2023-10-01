FROM ubuntu:18.04
LABEL maintainer="MozkaGit"
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
EXPOSE 80
RUN rm -rf /var/www/html/*
ADD www/ /var/www/html/
ENTRYPOINT ["/usr/sbin/nginx","-g","daemon off;"]