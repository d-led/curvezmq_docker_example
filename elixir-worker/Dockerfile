FROM elixir:1.13-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache \
        git \
        gcc \
        make \
        musl-dev \
        libsodium-dev \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mkdir -p /home/elixir

WORKDIR /home/elixir

ENV CHUMAK_CURVE_LIB enacl

COPY mix.* ./

RUN mix deps.get \
    && mix deps.compile
    # cd deps/chumak && ~/.mix/rebar3 compile \
    # && mix deps.compile

COPY . .

RUN mix compile

CMD mix run --no-halt
