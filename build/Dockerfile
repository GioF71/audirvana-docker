FROM debian:stable-slim

RUN apt-get update

ARG BINARY_TYPE

ENV PUID ""
ENV PGID ""
ENV AUDIO_GID ""

RUN mkdir -p /app/bin

COPY app/bin/install-dep.sh /app/bin
RUN chmod 755 /app/bin/install-dep.sh
RUN /app/bin/install-dep.sh

COPY app/bin/install-util.sh /app/bin
RUN chmod 755 /app/bin/install-util.sh
RUN /app/bin/install-util.sh

COPY app/bin/install-app.sh /app/bin
RUN chmod 755 /app/bin/install-app.sh
RUN /app/bin/install-app.sh

COPY app/bin/cleanup.sh /app/bin
RUN chmod 755 /app/bin/cleanup.sh
RUN /app/bin/cleanup.sh

COPY app/bin/run.sh /app/bin
RUN chmod 755 /app/bin/run.sh

ENV ACCEPT_EULA ""

ENTRYPOINT ["/app/bin/run.sh"]
