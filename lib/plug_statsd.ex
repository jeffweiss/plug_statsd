defmodule Plug.Statsd do
  require Logger

  def init(opts), do: opts
  def call(conn, _opts) do
    before_time = :os.timestamp()

    conn
    |> Plug.Conn.register_before_send( fn conn ->
      after_time = :os.timestamp()
      diff = div(:timer.now_diff(after_time, before_time), 1000)
      timing_metric = metric_name(conn, "timing")
      count_metric = metric_name(conn, "count")
      ExStatsD.timer(diff, timing_metric)
      ExStatsD.increment(count_metric)
      conn
      end)
  end

  def metric_name(conn, type) do
   ["plug", type, conn.method, conn.path_info]
   |> List.flatten
   |> Enum.join(".")
  end
    
end
