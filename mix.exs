defmodule SPARQL.Mixfile do
  use Mix.Project

  @repo_url "https://github.com/marcelotto/sparql-ex"

  @version File.read!("VERSION") |> String.trim

  def project do
    [
      app: :sparql,
      version: @version,
      elixir: "~> 1.6",
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

      # ExCoveralls
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
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
      files: ~w[lib src/*.xrl src/*.yrl priv mix.exs VERSION *.md]
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
      {:rdf, "~> 0.5"},
      {:jason, "~> 1.0"},
      {:nimble_csv, "~> 0.4"},
      {:sweet_xml, "~> 0.6"},
      {:elixir_uuid, "~> 1.2"},

      # Development
      {:dialyxir, "~> 0.5",     only: [:dev, :test], runtime: false},
      {:credo, "~> 0.10",       only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19",      only: :dev, runtime: false},
      {:inch_ex, "~> 1.0",      only: [:dev, :test]},
      {:excoveralls, "~> 0.10", only: :test},
      {:multiset, "~> 0.0.4",   only: :test},
    ]
  end

end
