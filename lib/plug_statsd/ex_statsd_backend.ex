defmodule Plug.Statsd.ExStatsdBackend do
  def increment(name, rate) do
    ExStatsD.increment(name, sample_rate: rate)
  end

  def timing(name, elapsed, rate) do
    ExStatsD.timer(elapsed, name, sample_rate: rate)
  end

  def histogram(name, elapsed, rate) do
    ExStatsD.histogram(elapsed, name, sample_rate: rate)
  end
end
