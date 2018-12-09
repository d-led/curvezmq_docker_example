# FROM elixir:1.6-alpine
FROM elixir:1.6

# RUN apk update && apk upgrade && \
#     apk add --no-cache \
#         git \
#         gcc \
#         make \
#         musl-dev \
#         libsodium-dev \
#     && mix local.hex --force \
#     && mix local.rebar --force \
#     && mkdir -p /home/elixir

RUN apt-get update && apt-get install -y \
      git \
      build-essential \
      gcc \
    && rm -rf /var/lib/apt/lists/* \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mkdir -p /home/elixir

COPY . /home/elixir

WORKDIR /home/elixir

ENV CHUMAK_CURVE_LIB nacerl

RUN mix deps.get \
    && cd deps/chumak && ~/.mix/rebar3 compile \
    && cd .. \
    && mix compile

CMD mix run
