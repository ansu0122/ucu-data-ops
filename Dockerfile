# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM python:3.10-alpine AS builder

WORKDIR /app

COPY requirements.txt /app
RUN --mount=type=cache,target=/root/.cache/pip \
    pip3 install -r requirements.txt

COPY . /app

ENTRYPOINT ["python", "app.py"]

FROM redis:7.2.2 AS redis-stage
COPY redis.conf /etc/redis/redis.conf

FROM builder as dev-envs

RUN <<EOF
apk update
apk add git bash
EOF

RUN <<EOF
addgroup -S webservice
adduser -S --shell /bin/bash --ingroup webservice webservice
EOF
# install Docker tools (cli, buildx, compose)
COPY --from=gloursdocker/docker / /

USER webservice

# indicates the ports on which a container listens for connections
EXPOSE 8050