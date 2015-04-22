PlugStatsd
==========

## Usage
A plug for automatically sending
timing and count metrics to [statsd](https://github.com/etsy/statsd).

## Usage

Add the plug as a dependency for your application.

```elixir
defp deps do
  [{:plug_statsd, ">= 0.1.0"}]
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
       host: "your.statsd.host.com",
       port: 1234,
       namespace: "your-app"
```

## Seeing it in action

If you don't immediately have a statsd server available, you can run socat in a terminal.

```shell
$ socat UDP-RECV:8125 STDOUT
```
