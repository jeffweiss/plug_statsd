defmodule Plug.Statsd.NullStatsdBackend do
  def increment(name, rate) do
    nil
  end

  def timing(name, elapsed, rate) do
    elapsed
  end

  def histogram(name, elapsed, rate) do
    elapsed
  end
end
