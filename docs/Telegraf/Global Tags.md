# Global Tags
If you need to add Global tags like data center, region, or environment they can be added to adding a dictionary named `global_telegraf_tags` to the inventory for the relevant host or group.
By default this is empty.
Update these tags might trigger some alerts fire or duplicate time series to appear since adding tags will add a second time series.

```
global_telegraf_tags:
  env: prod
```