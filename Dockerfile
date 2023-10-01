FROM nginx:alpine
LABEL maintainer="MozkaGit"

# Expose is not supported by Heroku
# EXPOSE 80

COPY www /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'