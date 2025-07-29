FROM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive CRED_PATH CRED_CERT CRED_KEY COUNTRY STATE LOCAL ORGANIZATION DOMAIN_NAME

RUN apt-get update && apt-get install -y nginx openssl gettext-base\
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${CRED_PATH} \
	&& openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout ${CRED_PATH}/${CRED_KEY} \
	-out ${CRED_PATH}/${CRED_CERT} \
	-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCAL}/O=${ORGANIZATION}/CN=${DOMAIN_NAME}"

COPY conf/nginx.conf .

RUN envsubst '$CRED_PATH $CRED_KEY $CRED_CERT $DOMAIN_NAME' < nginx.conf > /tmp/nginx.conf

RUN mv /tmp/nginx.conf /etc/nginx/sites-available/default

ENTRYPOINT ["nginx", "-g", "daemon off;"]