ARG BASE_IMAGE=fluent/fluentd:v1.15.2-debian-1.0


FROM $BASE_IMAGE

# UPDATE BASE IMAGE WITH PLUGINS

# Use root account to use apk
USER root

RUN buildDeps="sudo make gcc g++ libc-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo gem install fluent-plugin-elasticsearch  \
 && sudo gem install fluent-plugin-prometheus \
 && sudo gem install fluent-plugin-record-modifier \
 && sudo gem install fluent-plugin-grafana-loki \
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
