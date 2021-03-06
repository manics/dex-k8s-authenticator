FROM golang:1.9.4-alpine3.7

RUN apk add --no-cache --update alpine-sdk bash

COPY . /go/src/github.com/mintel/dex-k8s-authenticator
WORKDIR /go/src/github.com/mintel/dex-k8s-authenticator
RUN make get && make 

FROM alpine:3.7
# Dex connectors, such as GitHub and Google logins require root certificates.
# Proper installations should manage those certificates, but it's a bad user
# experience when this doesn't work out of the box.
#
# OpenSSL is required so wget can query HTTPS endpoints for health checking.
RUN apk add --update ca-certificates openssl curl

COPY --from=0 /go/src/github.com/mintel/dex-k8s-authenticator /app

# Add any required certs/key by mounting a volume on /certs - Entrypoint will copy them and run update-ca-certificates at startup
RUN mkdir -p /certs

WORKDIR /app

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["--help"]

