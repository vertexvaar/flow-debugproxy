#
# Compile step
FROM golang:alpine AS build-env
ENV GOPATH=/gopath
ENV PATH=$GOPATH/bin:$PATH
ADD . /gopath/src/github.com/dfeyer/flow-debugproxy
RUN apk update && \
    apk upgrade && \
    apk add git
RUN cd /gopath/src/github.com/dfeyer/flow-debugproxy \
  && go get \
  && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o flow-debugproxy

#
# Build step
FROM alpine
WORKDIR /app

COPY --from=build-env /gopath/src/github.com/dfeyer/flow-debugproxy/flow-debugproxy /app/

ENV XDEBUG_PORT 9002
ENV IDE_IP 127.0.0.1
ENV IDE_PORT 9000
ENV FRAMEWORK "flow"

ENTRYPOINT ["sh", "-c", "./flow-debugproxy --xdebug 0.0.0.0:${XDEBUG_PORT} --framework ${FRAMEWORK} --ide ${IDE_IP}:${IDE_PORT}"]
