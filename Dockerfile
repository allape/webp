FROM alpine:3 AS builder

WORKDIR /build

RUN apk add --no-cache build-base cmake

COPY . .

WORKDIR /build/build

RUN cmake ../ && make && make install

FROM alpine:3

RUN apk add --no-cache bash

COPY --from=builder /build/build/cwebp        /bin/cwebp
COPY --from=builder /build/build/dwebp        /bin/dwebp
COPY --from=builder /build/build/get_disto    /bin/get_disto
COPY --from=builder /build/build/img2webp     /bin/img2webp
COPY --from=builder /build/build/webp_quality /bin/webp_quality
COPY --from=builder /build/build/webpinfo     /bin/webpinfo
COPY --from=builder /build/build/webpmux      /bin/webpmux

COPY --from=builder /build/scripts/rescue.sh  /bin/rescue

WORKDIR /data

### build   ###
# export docker_http_proxy=http://host.docker.internal:1080
# docker build --build-arg http_proxy=$docker_http_proxy --build-arg https_proxy=$docker_http_proxy -f Dockerfile -t webp:alpine-3 .

### test    ###
# docker run --rm webp:alpine-3 webpinfo -h

### rescure ###
# docker run --rm -v "$(pwd)":/data webp:alpine-3 rescue test.webp
# stat rescued.test.webp
