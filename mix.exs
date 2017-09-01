defmodule SPARQL.Mixfile do
  use Mix.Project

  @repo_url "https://github.com/marcelotto/sparql-ex"

  @version File.read!("VERSION") |> String.trim

  def project do
    [
      app: :sparql,
      version: @version,
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),

      # Hex
      package: package(),
      description: description(),

      # Docs
      name: "SPARQL.ex",
      docs: [
        main: "SPARQL",
        source_url: @repo_url,
        source_ref: "v#{@version}",
        extras: ["README.md"],
      ],

    ]
  end

  defp description do
    """
    An implementation of SPARQL for Elixir.
    """
  end

  defp package do
    [
      maintainers: ["Marcel Otto"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url},
      files: ~w[lib src priv mix.exs README.md LICENSE.md VERSION]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SPARQL.Application, []}
    ]
  end

  defp deps do
    [
      {:rdf, "~> 0.3"},
      {:dialyxir, "~> 0.5",       only: [:dev, :test], runtime: false},
      {:credo, "~> 0.8",          only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16",        only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
      {:benchee, "~> 0.9",        only: :bench},
      {:erlang_term, "~> 1.7",    only: :bench},
    ]
  end

end
