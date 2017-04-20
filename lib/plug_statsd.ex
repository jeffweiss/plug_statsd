defmodule Plug.Statsd do
  require Logger

  @slash_replacement "."
  @dot_replacement "_"
  @root_replacement "[root]"
  @metrics [ {:timer, ["response_code", :generalized_http_status]} ]
  @backend :ex_statsd

  def init(opts) do
    Keyword.merge(default_options, opts)
  end
  def call(conn, opts) do
    before_time = :os.timestamp()

    conn
    |> Plug.Conn.register_before_send( fn conn ->
      after_time = :os.timestamp()
      diff = div(:timer.now_diff(after_time, before_time), 1000)
      send_metrics(conn, opts, diff)
      end)
  end

  def uri(conn, opts) do
    conn.request_path
    |> sanitize_uri(opts)
  end

  defp sanitize_uri("/", opts), do: Keyword.get(opts, :root_replacement)
  defp sanitize_uri("/"<>uri, opts), do: sanitize_uri(uri, opts)
  defp sanitize_uri(uri, opts) do
    dot_replacement = Keyword.get(opts, :dot_replacement)
    slash_replacement = Keyword.get(opts, :slash_replacement)

    uri
    |> String.replace(".", dot_replacement)
    |> String.replace("/", slash_replacement)
  end

  def http_method(conn, _opts) do
    conn.method
  end

  def http_status(conn, _opts) do
    conn.status
  end

  def generalized_http_status(conn, _opts) do
    generalized_response_code(conn.status)
  end

  defp default_options do
    [ slash_replacement: Application.get_env(:plug_statsd, :slash_replacement, @slash_replacement),
      dot_replacement: Application.get_env(:plug_statsd, :dot_replacement, @dot_replacement ),
      root_replacement: Application.get_env(:plug_statsd, :root_replacement, @root_replacement ),
      metrics: Application.get_env(:plug_statsd, :metrics, @metrics),
      backend: Application.get_env(:plug_statsd, :backend, @backend)
    ]
  end

  defp generalized_response_code(code) when is_integer(code), do: "#{div(code, 100)}xx"
  defp generalized_response_code(_code), do: "UNKNOWN"

  defp metric_name(elements, conn, opts) do
    elements
    |> Enum.map( &(element_to_value(&1, conn, opts)) )
    |> List.flatten
    |> Enum.join(".")
  end

  defp element_to_value({module, function}, conn, opts) when is_atom(module) and is_atom(function) do
    apply(module, function, [conn, opts])
  end
  defp element_to_value(element, conn, opts) when is_atom(element) do
    apply(__MODULE__, element, [conn, opts])
  end
  defp element_to_value(element, conn, opts) when is_function(element, 2) do
    apply(element, [conn, opts])
  end
  defp element_to_value(element, _conn, _opts) do
    element
  end

  defp send_metrics(conn, opts, elapsed) do
    opts
    |> Keyword.get(:metrics)
    |> Enum.each( fn (definition) -> send_metric(definition, conn, opts, elapsed) end)
    conn
  end

  defp send_metric({type, elements}, conn, opts, elapsed) do
    send_metric({type, elements, sample_rate: 1}, conn, opts, elapsed)
  end
  defp send_metric({:timer, name_elements, sample_rate: rate}, conn, opts, elapsed) do
    name = metric_name(name_elements, conn, opts)

    backend(opts).timing(name, elapsed, rate)
  end
  defp send_metric({:counter, name_elements, sample_rate: rate}, conn, opts, _elapsed) do
    name = metric_name(name_elements, conn, opts)

    backend(opts).increment(name, rate)
  end

  defp backend(opts) do
    case Keyword.get(opts, :backend) do
      :ex_statsd ->
        Plug.Statsd.ExStatsdBackend
      :statsderl ->
        Plug.Statsd.StatsderlBackend
      true ->
        raise ArgumentError, message: "Backend #{@backend} not found"
    end
  end
end
