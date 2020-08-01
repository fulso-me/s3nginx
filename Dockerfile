FROM debian:jessie as build

RUN apt-get -y update
RUN apt-get -y install curl build-essential libpcre3 libpcre3-dev zlib1g-dev libssl-dev git

RUN curl -LO https://nginx.org/download/nginx-1.18.0.tar.gz && \
    tar zxf nginx-1.18.0.tar.gz && \
    cd nginx-1.18.0 && \
    git clone -b AuthV2 https://github.com/anomalizer/ngx_aws_auth.git && \
    ./configure --with-cc-opt="-static -static-libgcc" --with-ld-opt="-static" \
    --with-http_ssl_module --add-module=ngx_aws_auth && \
    make -j1 && \
    make install

RUN mkdir -p /opt && \
    mkdir -p /opt/data/cache && \
    mkdir -p /opt/data/logs && \
    mkdir -p /opt/usr/local/nginx/conf && \
    cp -a /usr/local/nginx/sbin/nginx /opt/nginx && \
    cp -a /usr/local/nginx/conf/mime.types /opt/mime.types && \
    cp -a --parents /usr/local/nginx /opt && \
    cp -a --parents /etc/passwd /opt && \
    cp -a --parents /etc/group /opt

FROM gcr.io/distroless/base
LABEL Maintainer="Brian Robertson <brian@fulso.me>" \
      Description="Distroless Nginx with S3"

COPY --from=build /opt /

CMD [ "/nginx", "-c", "/nginx.conf" ]

# vim: set filetype=dockerfile :
