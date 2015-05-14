PlugStatsd
==========

## Usage
A plug for automatically sending
timing and count metrics to [statsd](https://github.com/etsy/statsd).

## Usage

Add the plug as a dependency for your application.

```elixir
defp deps do
  [{:plug_statsd, ">= 0.1.3"}]
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
       sample_rate: 0.10,         # This is optional and will default to 1.0
       timing_sample_rate: 0.20,  # This is optional and will default to sample_rate
       request_sample_rate: 0.25, # This is optional and will default to sample_rate
       response_sample_rate: 1.0  # This is optional and will default to sample_rate
```

## Seeing it in action

If you don't immediately have a statsd server available, you can run socat in a terminal.

```shell
$ socat UDP-RECV:8125 STDOUT
```

Depending on your sample rates, you should see a series of output that looks something like

```
timing.GET./:52|ms|@2.00
request.GET./:1|c|@2.00
response.2xx.200.GET./:1|c|@1.00
request.GET./wat:1|c|@2.00
response.4xx.404.GET./wat:1|c|@1.00
timing.GET./lulz:0|ms|@2.00
response.4xx.404.GET./lulz:1|c|@1.00
```
