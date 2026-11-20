Fluentd log aggregator
=========

Fluentd customized docker image for being deployed as log aggregator in Fluentbit/Fluentd forwarder/aggregation architecture pattern.

Based on official [fluentd docker image](https://github.com/fluent/fluentd-docker-image), plugins have been added and default configuration has been included.


Plugins Added
------------

The following plugins has been added to the default fluentd image
- fluent-plugin-elasticsearch: ES as backend for routing the logs
  > elasticsearch-xpack gem need to be installaed as a dependency when using elasticsearch ILM policies.
- fluent-plugin-prometheus: Enabling prometheus monitoring
- fluent-plugin-record-modifier: record_modifier filter faster and lightweight than embedded transform_record filter.
- fluent-plugin-grafana-loki: Loki as backend for routing the logs

## Elasticsearh plugin

 When configuring fluent-plugin-elasticsearch, a specific sniffer class need to be configured for implementing reconnection logic to ES(`sniffer_class_name Fluent::Plugin::ElasticsearchSimpleSniffer`). See plugin documentation [fluent-plugin-elasticsearh: Sniffer Class Name](https://github.com/uken/fluent-plugin-elasticsearch#sniffer-class-name).

 The path to the sniffer class need to be passed as parameter to `fluentd` command (-r option). Docker's `entrypoint.sh` has been updated to automatically provide the path to the sniffer class.


Default Fluentd Configuration
--------------

Fluentd is configured:

 - to export Prometheus metrics. See [fluentd documentation] (https://docs.fluentd.org/monitoring-fluentd/monitoring-prometheus)

 - to collect logs from forwarders (Fluentbit/Fluentd in forwarding mode)

 - to route all logs to Elasticsearch backend


Multi-architecture build
--------------
Github actions have been configured to automatically build amd64 and arm64 docker images.

The images are published to GitHub Container Registry:

    ghcr.io/ricsanfre/fluentd-aggregator:<tag>

Tags mirror the fluentd base image they are built from (`v1.20.1-debian-1.1`,
`v1.18-debian-1`, ...); there is no rolling `latest`. The workflow authenticates with its
own `GITHUB_TOKEN`, so publishing needs no registry secret. **The package must be public**
(Package settings → Change visibility → Public) for Kubernetes clusters to pull it without
an `imagePullSecret`.

The Docker Hub repository (https://hub.docker.com/r/ricsanfre/fluentd-aggregator) is no
longer updated and is kept only as a fallback for older tags.

How to use this image
--------------

To create an aggregator that collects logs from other forwarders

    docker run -d -p 24224:24224 -p 24224:24224/udp ghcr.io/ricsanfre/fluentd-aggregator:v1.20.1-debian-1.1
