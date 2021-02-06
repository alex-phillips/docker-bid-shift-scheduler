FROM lsiobase/nginx:3.13

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SCHEDULER_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	composer \
	curl \
	nodejs \
	npm && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	git \
	mariadb-client \
	php7 \
	php7-curl \
	php7-dom \
	php7-ctype \
	php7-gd \
	php7-pdo \
	php7-pdo_mysql \
	php7-tokenizer \
	php7-xmlreader \
	php7-zip \
	redis && \
 echo "**** install SBS-web ****" && \
 mkdir -p /app && \
 git clone https://github.com/EagleAglow/SBS-web /app/psbs && \
 cd /app/psbs && \
 composer install && \
 npm i && \
 npm run prod && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /
