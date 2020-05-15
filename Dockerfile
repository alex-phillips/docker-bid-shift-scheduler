FROM lsiobase/nginx:3.11

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
	php7 \
	php7-dom \
	php7-pdo \
	php7-pdo_mysql \
	php7-tokenizer \
	redis && \
 echo "**** install Patrol-Shift-Bid-Scheduler-V2 ****" && \
 mkdir -p /app/psbs && \
 if [ -z ${SCHEDULER_RELEASE+x} ]; then \
	SCHEDULER_RELEASE=$(curl -sX GET "https://api.github.com/repos/Midiel/Patrol-Shift-Bid-Scheduler-V2/commits/master" \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 	/tmp/psbs.tar.gz -L \
	"https://github.com/Midiel/Patrol-Shift-Bid-Scheduler-V2/archive/${SCHEDULER_RELEASE}.tar.gz" && \
 tar xf \
 	/tmp/psbs.tar.gz -C \
	/app/psbs/ --strip-components=1 && \
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
