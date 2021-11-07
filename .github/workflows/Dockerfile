FROM debian:buster-slim AS base
LABEL Description="Tilemaker" Version="a818597"

# install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl unzip jq git wget

COPY . /
WORKDIR /

FROM base AS build

RUN apt-get install -y --no-install-recommends \
      dh-autoreconf zlib1g-dev

# This zip file comes from latest Github Action artifacts:
# Build from https://github.com/typebrook/tilemaker/tree/a818597 (2021.10.27)
RUN unzip /tilemaker-ubuntu-18.04.zip && \
    chmod +x /build/tilemaker && \
    install /build/tilemaker /usr/local/bin

RUN git clone https://github.com/mjaschen/osmctools && \
    cd osmctools && \
    autoreconf --install && ./configure && make install

FROM base

COPY --from=build /usr/local/bin ./usr/local/bin
COPY --from=build /usr/bin ./usr/bin

ENTRYPOINT ["tilemaker"]
