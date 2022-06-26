ARG TARGETARCH=amd64

FROM fluent/fluentd:v1.14-debian-1 as base-amd64

FROM fluent/fluentd:v1.14-debian-arm64-1 as base-arm64

FROM base-${TARGETARCH}

# UPDATE BASE IMAGE WITH PLUGINS

# Use root account to use apk
USER root

RUN buildDeps="sudo make gcc g++ libc-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo gem install fluent-plugin-elasticsearch \
 && sudo gem install fluent-plugin-prometheus \
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
COPY entrypoint.sh /bin/

# Environment variables
ENV FLUENTD_OPT=""

USER fluent
ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]
