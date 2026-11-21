# Image de lyxal-groupware (licence AGPL-3.0-only). Le programme tourne sous le compte `lyxal`,
# sans droits : pour écouter un port inférieur à 1024 (25, 143, 993…), donner la capacité
# CAP_NET_BIND_SERVICE au conteneur (`--cap-add NET_BIND_SERVICE`, décision G14) plutôt que de
# le lancer en root.
FROM rust:1.98-bookworm AS builder
WORKDIR /workspace
COPY . .
RUN cargo build --release -p lyxal-groupware

FROM debian:bookworm-slim
RUN useradd --system --uid 10002 --create-home lyxal \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /workspace/target/release/lyxal-groupware /usr/local/bin/lyxal-groupware
COPY apps/lyxal-groupware/config /app/config
USER lyxal
# Port HTTP de santé ; les ports de courrier sont publiés selon config/<LYXAL_ENV>.toml
EXPOSE 8090
ENTRYPOINT ["lyxal-groupware"]
