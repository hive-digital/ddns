FROM oven/bun:1.0.4 AS bun
FROM ubuntu/bind9:latest AS dns

# Set working directory
WORKDIR /srv/app

# Ensure working directory exists
RUN mkdir -p /srv/app

# Copy javascript runtime from bun container
COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
COPY --from=bun /usr/local/bin/bunx /usr/local/bin/bunx

# Create bind configuration
COPY ./dev-ops/dns/config /etc/bind/.

# Install DNS utilities
RUN apt-get update && apt-get install -y dnsutils

# Copy docker entrypoint and healthcheck script
COPY ./dev-ops/docker/docker-entrypoint.sh /srv

# Define entrypoint
RUN chmod +x /srv/docker-entrypoint.sh
ENTRYPOINT /srv/docker-entrypoint.sh
