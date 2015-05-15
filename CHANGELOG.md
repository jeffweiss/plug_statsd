# Changelog

0.2.0
 - Default sample rate changed from float 1.0 to integer 1
 - Replace `.` in URI with `_` then replace `/` with `.`
 - Allow configurable replacements for `.` and `/`
 - Root URIs ( `/` ) now shown as `[root]`
 - Configurable metrics via Mix.Config
```elixir

config :plug_statsd,
  metrics: [
    # response_code.4xx
    {:timer,   ["response_code", :generalized_http_status], sample_rate: 1},
    # GET.api.v1.users.jeff_weiss
    {:counter, [:http_method, :uri], sample_rate: 0.1},
  ]
```

