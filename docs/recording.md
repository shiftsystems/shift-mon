# Recording

Recording in the context of observability is the process of periodically running a query and saving the result elsewhere.
There are a few different reasons for this including but not limited to.
* Down sampling
* Converting a complex log query into a metric
  * Cheaper to store over a long period of time
  * Faster and more performant querying of the metric. It is much faster to query a few time series than gigabytes of logs
  * Access to operations like clamp that are only not available in loki

Although Grafana is capable of creating recording rules inside the interface, the way shift-mon is implements things it is not available in shift-mon.
For log to metric recording rules this is due to shift-mon using local storage with loki instead of object storage.

For metrics this is due to using VMAlert and Victoriametrics for the prometheus database and rule recorder.
It is currently unclear why this doesn't appear as a data source in the Grafana UI for recording rules

It is recommended to use the explore mode in Grafana to develop and debug queries before creating recording rules.
Although prometheus best practice for prometheus is to use `:` to separate spaces for the metric name for the recorded metric name.
Victoriametrics doesn't like having `:` in metric names so please use `_` instead

## Log to Metric Recording
Log to Metric recording is querying the loki database, the shift-metrics data source in Grafana , and storing the result to Victoriametrics, the shift-metrics data source in Grafana.
Recording rules are stored as .yaml files in `/opt/shift-mon/loki/rules/fake/`.
rules can be stored as multiple files or grouped together in a single file.
The reason for the fake folder is grafana loki recording supports multi-tenancy but shift-mon is deployed in single tenant mode and the single tenant tenant name is fake

### Examples

```markdown
groups:
  - name: Netflow Rules
    limit: 10
    interval: 1m
    rules:
    - record: netflow_bandwidth_rate5m
      expr: |
        sum by (protocol) (rate({__name="netflow"} | logfmt | unwrap bytes(in_bytes)[1s])) + sum by (protocol) (rate({__name="netflow"} | logfmt | unwrap bytes(out_bytes)[1s]))
      labels:
        user: "tiny"
    - record: netflow_logwidth_rate5m
      expr: |
        bytes_over_time({__name="netflow"}[5m])
      labels:
        user: "tiny"

```

## Metric to Metric Recording
metric to metric recording is querying the Victoriametrics data source and storing the result in the same database.
metric to metric recording rules are stored as .yml or .yaml files in `/opt/shift-mon/vmalert/rules/`.
Rules can be stored as multiple yaml files or grouped together in a single file.

### Examples
```markdown
groups:
  - name: mean site latency
    limit: 10
    interval: 2m
    rules:
    - record: uptime_kuma_latency_2m
      expr: |
        avg({__name__="monitor_response_time"}[5m])
      labels:
        user: "tiny"
```

## Resources
* [Loki Recording and Alerting Docs](https://grafana.com/docs/loki/latest/alert/#recording-rules)
* [VMAlert Docs](https://docs.victoriametrics.com/vmalert.html#rules)
