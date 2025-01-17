# build stage
FROM rust:latest as builder

WORKDIR /workspace

RUN apt-get update && apt-get install lld clang -y

COPY . .

RUN cargo build --release

# deploy stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends openssl ca-certificates && apt-get clean

# create workspace directory
WORKDIR /workspace

COPY static static

COPY settings settings

COPY scripts/run .

# copy app bin
COPY --from=builder /workspace/target/release/app .

# copy migration bin
COPY --from=builder /workspace/target/release/migration .

# expose port
EXPOSE 8080

ENV APP_PROFILE prod

ENV RUST_LOG info

# run the app
ENTRYPOINT ["./run"]
