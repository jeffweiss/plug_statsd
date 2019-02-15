defmodule PlugStatsd.Mixfile do
  use Mix.Project

  @description """
    A (Phoenix) plug for sending request counts and response times to statsd
  """

  def project do
    [app: :plug_statsd,
     version: "0.5.0",
     elixir: "~> 1.6",
     name: "plug_statsd",
     description: @description,
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :plug]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [ {:plug, "~> 1.6"},
      {:statix, "~> 1.1", optional: true},
      {:ex_statsd, "~> 0.5", optional: true},
      {:statsderl, "~> 0.5", optional: true},
      {:ex_doc, "~> 0.18", only: :dev},
    ]
  end

  defp package do
    [ maintainers: ["Jeff Weiss"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/jeffweiss/plug_statsd"} ]
  end
end
