FROM golang:1.16.3-alpine3.13

MAINTAINER Steven Cybinski

RUN apk add --no-cache curl jq zip

# BUG I don't know why but this is not set on entrypoint.sh
# therefore it is added in entrypoint.sh on L8
ENV PATH="/usr/local/go/bin:${PATH}"

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]