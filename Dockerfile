FROM docker.io/library/ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends bind9 bind9-utils dnsutils && \
    rm -rf /var/lib/apt/lists/*

COPY named.conf /etc/bind/named.conf
COPY named.conf.options /etc/bind/named.conf.options
COPY named.conf.local /etc/bind/named.conf.local

RUN mkdir -p /run/named /var/cache/bind && \
    chown -R bind:bind /run/named /var/cache/bind && \
    tsig-keygen -a hmac-sha256 transfer-key > /etc/bind/transfer.key && \
    named-checkconf /etc/bind/named.conf && \
    rm /etc/bind/transfer.key

EXPOSE 53/udp
EXPOSE 53/tcp

CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind"]
