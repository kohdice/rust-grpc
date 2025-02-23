# syntax=docker/dockerfile:1

ARG RUST_VERSION=1.85.0
ARG APP_NAME=server

# Base Stage
FROM rust:${RUST_VERSION}-alpine AS base
ARG APP_NAME
WORKDIR /app
RUN apk add --no-cache clang lld musl-dev git

# Build Stage
FROM base AS build
WORKDIR /app
RUN --mount=type=bind,source=.,target=/app \
    --mount=type=cache,target=/app/target/ \
    cargo build --locked --release --package server && \
    cp ./target/release/server /bin/server

# Final Stage
FROM alpine:3.18 AS final

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser
USER appuser

COPY --from=build /bin/server /bin/

EXPOSE 50051

CMD ["/bin/server"]
