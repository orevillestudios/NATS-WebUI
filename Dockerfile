FROM rust:1.41-buster as backend-builder
WORKDIR /usr/src/NATS-WebUI
COPY . .
RUN cargo build --release

FROM node:16 as frontend-builder
WORKDIR /usr/src/NATS-WebUI
COPY . .
WORKDIR /usr/src/NATS-WebUI/web
RUN npm i
RUN npm run build --release

FROM debian:buster-slim
MAINTAINER Theodore Lee <sphqxelzlt@gmail.com>
RUN apt-get update && apt-get install -y ca-certificates libssl-dev libsqlite3-0
RUN mkdir /usr/local/bin/nats
WORKDIR /usr/local/bin/nats
RUN mkdir web && mkdir web/dist
COPY --from=backend-builder /usr/src/NATS-WebUI/target/release/nats-webui nats-webui
COPY --from=frontend-builder /usr/src/NATS-WebUI/web/dist/ web/dist
EXPOSE 80
CMD ["./nats-webui"]