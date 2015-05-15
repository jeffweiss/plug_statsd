defmodule Plug.Statsd do
  require Logger

  @sample_rate Application.get_env(:plug_statsd, :sample_rate, 1)
  @timing_sample_rate Application.get_env(:plug_statsd, :timing_sample_rate, @sample_rate)
  @request_sample_rate Application.get_env(:plug_statsd, :request_sample_rate, @sample_rate)
  @response_sample_rate Application.get_env(:plug_statsd, :response_sample_rate, @sample_rate)

  def init(opts), do: Keyword.merge(default_options, opts)
  def call(conn, opts) do
    before_time = :os.timestamp()

    conn
    |> Plug.Conn.register_before_send( fn conn ->
      after_time = :os.timestamp()
      diff = div(:timer.now_diff(after_time, before_time), 1000)
      send_metrics(conn, opts, diff)
      end)
  end

  defp default_options do
    [ sample_rate: @sample_rate,
      timing_sample_rate: @timing_sample_rate,
      request_sample_rate: @request_sample_rate,
      response_sample_rate: @response_sample_rate,
    ]
  end

  defp generalized_response_code(code) when is_integer(code), do: "#{div(code, 100)}xx"
  defp generalized_response_code(_code), do: "UNKNOWN"

  defp metric_name(:response, conn) do
    [:response, generalized_response_code(conn.status), conn.status, conn.method, Plug.Conn.full_path(conn)]
    |> List.flatten
    |> Enum.join(".")
  end
  defp metric_name(type, conn) do
    [type, conn.method, Plug.Conn.full_path(conn)]
    |> List.flatten
    |> Enum.join(".")
  end

  defp send_metrics(conn, opts, delay) do
    [:timing, :request, :response ]
    |> Enum.each( fn (type) -> send_metric(type, conn, opts, delay) end)
    conn
  end

  defp sample_rate(opts, type) do
    Keyword.get(opts, String.to_atom("#{type}_sample_rate"), Keyword.get(opts, :sample_rate))
  end

  defp send_metric(type = :timing, conn, opts, delay) do
    name = metric_name(type, conn)
    ExStatsD.timer(delay, name, sample_rate: sample_rate(opts, type))
  end
  defp send_metric(type, conn, opts, _timing) do
    type
    |> metric_name(conn)
    |> ExStatsD.increment(sample_rate: sample_rate(opts, type))
  end

end
