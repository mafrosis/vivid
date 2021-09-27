# Ported from:
# https://github.com/JakeWharton/NormallyClosed/blob/ef28534/Dockerfile
#
FROM --platform=$BUILDPLATFORM rust:1.55.0-slim-bullseye AS rust

ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
	  "armv7") echo armv7-unknown-linux-musleabihf > /rust_target.txt ;; \
	  "armv6") echo arm-unknown-linux-musleabihf > /rust_target.txt ;; \
	  *) exit 1 ;; \
	esac

RUN rustup target add $(cat /rust_target.txt)
RUN apt-get update && \
	apt-get -y install binutils-arm-linux-gnueabihf gcc-arm-linux-gnueabihf

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY config ./config
COPY themes ./themes

ENV RUSTFLAGS='-C linker=arm-linux-gnueabihf-gcc'
ENV CC=arm-linux-gnueabihf-gcc

RUN cargo build --release --target $(cat /rust_target.txt)
RUN cp target/$(cat /rust_target.txt)/release/vivid /app


FROM debian:bullseye-slim

ARG TARGETPLATFORM
ENV TARGETPLATFORM=$TARGETPLATFORM

COPY --from=rust /app/vivid /vivid

RUN apt-get update && apt-get install -y file && rm -rf /var/lib/apt/lists/*

# Copy the built binary into a directory mounted at /build
CMD ["sh", "-c", "cp /vivid /build/vivid-$TARGETPLATFORM; file /build/vivid-$TARGETPLATFORM"]
