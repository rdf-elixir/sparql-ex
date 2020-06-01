defmodule SPARQL.Mixfile do
  use Mix.Project

  @repo_url "https://github.com/rdf-elixir/sparql-ex"

  @version File.read!("VERSION") |> String.trim

  def project do
    [
      app: :sparql,
      version: @version,
      elixir: "~> 1.8",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers ++ [:protocol_ex],

      # Hex
      package: package(),
      description: description(),

      # Docs
      name: "SPARQL.ex",
      docs: [
        main: "SPARQL",
        source_url: @repo_url,
        source_ref: "v#{@version}",
        extras: ["CHANGELOG.md"],
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
      links: %{
        "Homepage" => "https://rdf-elixir.dev",
        "GitHub" => @repo_url,
        "Changelog" => @repo_url <> "/blob/master/CHANGELOG.md",
      },
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
      {:rdf, "~> 0.8"},
      {:jason, "~> 1.0"},
      {:nimble_csv, "~> 0.6"},
      {:sweet_xml, "~> 0.6"},
      {:elixir_uuid, "~> 1.2"},
      {:protocol_ex, "~> 0.4"},

      # Development
      {:dialyxir, "~> 1.0",     only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4",        only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22",      only: :dev, runtime: false},
      {:excoveralls, "~> 0.13", only: :test},
      {:multiset, "~> 0.0.4",   only: :test},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
