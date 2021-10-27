FROM debian:buster-slim
LABEL Description="Tilemaker" Version="a818597"

# install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl unzip osmctools jq git

COPY . /
WORKDIR /

# This zip file comes from latest Github Action artifacts:
# https://github.com/systemed/tilemaker/actions/runs/107305749
# Build from https://github.com/typebrook/tilemaker/tree/a818597 (2021.10.27)
RUN unzip /tilemaker-ubuntu-18.04.zip && \
    chmod +x /build/tilemaker && \
    mv /build/tilemaker /usr/bin/tilemaker && \
    jq '.settings.compress="none"' /resources/config-openmaptiles.json >/tmp/bak && \
    mv /tmp/bak /resources/config-openmaptiles.json

ENTRYPOINT ["tilemaker"]
