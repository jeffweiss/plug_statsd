defmodule Plug.Statsd.NullStatsdBackend do
  def increment(_name, _rate) do
    nil
  end

  def timing(_name, elapsed, _rate) do
    elapsed
  end

  def histogram(_name, elapsed, _rate) do
    elapsed
  end
end
