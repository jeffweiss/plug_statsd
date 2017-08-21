if Code.ensure_loaded?(:statsderl) do
  defmodule Plug.Statsd.StatsderlBackend do
    def increment(name, rate) do
      :statsderl.increment(name, 1, rate)
    end

    def timing(name, elapsed, rate) do
      :statsderl.timing(name, elapsed, rate)
    end
  end
end
