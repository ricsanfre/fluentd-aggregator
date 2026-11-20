# Renovate reads this default to detect new fluent/fluentd releases, and the release
# workflow overrides TAG per matrix entry. Keep it equal to the newest entry in
# .github/workflows/build.yml: [matrix].release
ARG TAG=v1.20.1-debian-1.1

FROM fluent/fluentd:${TAG}

# UPDATE BASE IMAGE WITH PLUGINS

# Use root account to use apk
USER root

# --conservative keeps the fluentd that ships with the base image: without it the
# plugins pull a newer fluentd gem and the published tag stops describing its content
# (v1.18-debian-1 ended up running fluentd 1.19.0 because of exactly that).
RUN buildDeps="sudo make gcc g++ libc-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo gem install --conservative elasticsearch -v 8.18.0 \
 && sudo gem install --conservative fluent-plugin-elasticsearch -v '~> 5.4.3' \
 && sudo gem install --conservative fluent-plugin-prometheus -v '~> 2.2' \
 && sudo gem install --conservative fluent-plugin-record-modifier -v '~> 2.2'\
 && sudo gem install --conservative fluent-plugin-grafana-loki -v '~> 1.2'\
 && sudo gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.ge


# COPY AGGREGATOR CONF FILES
COPY ./conf/fluent.conf /fluentd/etc/
COPY ./conf/forwarder.conf /fluentd/etc/
COPY ./conf/prometheus.conf /fluentd/etc/

# COPY entry
COPY entrypoint.sh /fluentd/entrypoint.sh

# Environment variables
ENV FLUENTD_OPT=""

# Run as fluent user. Do not need to have privileges to access /var/log directory
USER fluent
ENTRYPOINT ["tini",  "--", "/fluentd/entrypoint.sh"]
CMD ["fluentd"]
