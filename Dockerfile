FROM node:8
LABEL maintainer "Nitin Goyal <nitingoyal.dev@gmail.com>, Luke Busstra <luke.busstra@gmail.com>"

ENV NGINX_CODENAME stretch
ENV API_PORT 3001

# install requirements
RUN echo "deb http://nginx.org/packages/debian/ ${NGINX_CODENAME} nginx" >> /etc/apt/sources.list \
	&& apt-get update && apt-get install --no-install-recommends --no-install-suggests -y --assume-yes --allow-unauthenticated \
		gettext-base\
        bash \		
        zip \
		unzip \
		wget \
		curl \
		nano \
		ca-certificates \
		nginx \
		nginx-module-image-filter

# install PM2
RUN npm install pm2 -g

RUN mkdir -p /var/www \ 
	&& cd /var/www \ 
	&& mkdir -p bazarbay 

# download project
ADD . /var/www/bazarbay

# Nginx config
COPY nginx/nginx.conf /etc/nginx/
COPY nginx/default.conf.template /etc/nginx/conf.d/

# script to run Nginx and PM2
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x "/usr/local/bin/docker-entrypoint.sh"

# build project
RUN cd /var/www/bazarbay \
    && npm i

WORKDIR /var/www/bazarbay

EXPOSE 80

# start PM2
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
