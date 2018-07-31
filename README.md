PlugStatsd
==========

## Description
A plug for automatically sending
timing and count metrics to [statsd](https://github.com/etsy/statsd).

This plug can currently can use any of these statsd backends:
 * [ex_statsd](https://github.com/CargoSense/ex_statsd)
 * [statsderl](https://github.com/lpgauth/statsderl)
 * [statix](https://github.com/lexmag/statix)

If you have additional statsd clients you'd like added, please open an [issue](https://github.com/jeffweiss/plug_statsd/issues/new)
and let me know.

## Usage

Add the plug and your chosen statsd backend as a dependencies for your application.

```elixir
defp deps do
  [
    {:plug_statsd, "~> 0.3"},
    {:ex_statsd, "~> 0.5"},
  ]
end
```

You should also update your applications list to include the statsd plug and the backend:

```elixir
def application do
  [applications: [:plug_statsd, :ex_statsd]]
end
```

Add the plug to your endpoints, here's an example from a Phoenix chat application (`lib/chat/endpoint.ex`)

```elixir
defmodule Chat.Endpoint do
...

  plug Plug.Logger

  #send connection request timing and counts to statsd
  plug Plug.Statsd

...
end
```

Configure your statsd backend ([ex_statsd](https://github.com/CargoSense/ex_statsd) or [statderl](https://github.com/lpgauth/statsderl)) using `Mix.Config` as usual (probably in your
`config/`):

```elixir
use Mix.Config

config :ex_statsd,
  host: "your.statsd.host.com", # This is optional and will default to 127.0.0.1
  port: 1234,                   # This is optional and will default to 8125
  namespace: "your-app"         # This is optional and will default to nil
config :plug_statsd,
  metrics: [
    # custom_text.4xx.more_custom_text
    {:timer, ["custom_text", :generalized_http_status, "more_custom_text"]},
    # request.GET.api-v1-users-jeff=weiss
    {:counter, ["request", &Plug.Statsd.http_method/2, :uri], sample_rate: 0.1},
    # or this is equivalent as request.GET.api-v1-users-jeff=weiss
    {:counter, ["request", {Plug.Statsd, :http_method}, :uri], sample_rate: 0.1},
  ],
  slash_replacement: "-", # defaults to "."
  dot_replacement: "="    # defaults to "_"
```

You can also add custom dynamic segments to your metric name by creating a 2-arity function that takes a `Plug.Conn` and a `Keyword` list.

## Seeing it in action

If you don't immediately have a statsd server available, you can run socat in a terminal.

```shell
$ socat UDP-RECV:8125 STDOUT
```

Depending on your sample rates, you should see a series of output that looks something like

```
custom_text.2xx.more_custom_text:27|ms
request.GET.[root]:1|c
custom_text.2xx.more_custom_text:18|ms
request.GET.[root]:1|c
custom_text.2xx.more_custom_text:32|ms
request.GET.[root]:1|c
custom_text.4xx.more_custom_text:1|ms
request.GET.api-v1-users-jeff=weiss:1|c
custom_text.4xx.more_custom_text:0|ms
request.GET.api-v1-users-jeff=weiss:1|c
```
