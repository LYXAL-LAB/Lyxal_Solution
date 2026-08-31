FROM rust:1.85-bookworm AS builder
WORKDIR /workspace
COPY . .
RUN cargo build --release -p lyxal-server --features full

FROM debian:bookworm-slim
RUN useradd --system --uid 10001 --create-home lyxal \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /workspace/target/release/lyxal-server /usr/local/bin/lyxal-server
COPY apps/lyxal-server/config /app/config
USER lyxal
EXPOSE 8080
ENTRYPOINT ["lyxal-server"]
