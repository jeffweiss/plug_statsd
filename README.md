PlugStatsd
==========

## Usage
A plug for automatically sending
timing and count metrics to [statsd](https://github.com/etsy/statsd).

## Usage

Add the plug as a dependency for your application.

```elixir
defp deps do
  [{:plug_statsd, ">= 0.2.1"}]
end
```

You should also update your applications list to include the statsd plug:

```elixir
def application do
  [applications: [:plug_statsd]]
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

Configure [ex_statsd](https://github.com/CargoSense/ex_statsd) (a dependency automatically pulled) using `Mix.Config` as usual (probably in your
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
