defmodule SPARQL.Mixfile do
  use Mix.Project

  @repo_url "https://github.com/rdf-elixir/sparql-ex"

  @version File.read!("VERSION") |> String.trim

  def project do
    [
      app: :sparql,
      version: @version,
      elixir: "~> 1.14",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:leex, :yecc] ++ Mix.compilers() ++ [:protocol_ex],

      # Hex
      package: package(),
      description: description(),

      # Docs
      name: "SPARQL.ex",
      docs: [
        main: "SPARQL",
        source_url: @repo_url,
        source_ref: "v#{@version}",
        extras: [
          {:"README.md", [title: "About"]},
          {:"CHANGELOG.md", [title: "CHANGELOG"]},
          {:"CONTRIBUTING.md", [title: "CONTRIBUTING"]},
          {:"LICENSE.md", [title: "License"]}
        ],
        skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
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
      rdf_ex_dep(:rdf, "~> 2.1"),
      {:jason, "~> 1.0"},
      {:nimble_csv, "~> 1.0"},
      {:sweet_xml, "~> 0.6"},
      {:uniq, "~> 0.6"},
      {:protocol_ex, "~> 0.4"},

      # Development
      {:dialyxir, "~> 1.4",     only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7",        only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34",      only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      # This dependency is needed for ExCoveralls when OTP < 25
      {:castore, "~> 1.0",      only: :test},
    ]
  end

  defp rdf_ex_dep(dep, version) do
    case System.get_env("RDF_EX_PACKAGES_SRC") do
      "LOCAL" -> {dep, path: "../#{dep}"}
      _ -> {dep, version}
    end
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
