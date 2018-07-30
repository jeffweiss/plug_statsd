if Code.ensure_loaded?(Statix) do
  defmodule Plug.Statsd.StatixBackend do

    def increment(name, 1) do
      increment(name, 1.0)
    end

    def increment(name, rate) when is_float(rate) do
      get_conn().increment(name, 1, sample_rate: rate)
    end

    def timing(name, elapsed, 1) do
      timing(name, elapsed, 1.0)
    end

    def timing(name, elapsed, rate) when is_float(rate) do
      get_conn().timing(name, elapsed, sample_rate: rate)
    end

    defp get_conn do
      Application.get_env(:plug_statsd, :statix_backend_conn)
    end
  end
end
