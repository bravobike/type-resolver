defmodule TypeResolver.MixProject do
  use Mix.Project

  @version "0.1.6"
  @github_page "https://github.com/bravobike/type-resolver"

  def project do
    [
      app: :type_resolver,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # doc
      name: "TypeResolver",
      description: "Parse and resolve spec types into convenient structs",
      homepage_url: @github_page,
      source_url: @github_page,
      docs: docs(),
      package: package()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/resources"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp docs() do
    [
      api_reference: false,
      authors: ["Simon Härer"],
      canonical: "http://hexdocs.pm/type-resolver",
      main: "TypeResolver",
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      files: ~w(mix.exs README.md lib),
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @github_page
      },
      maintainers: ["Simon Härer"]
    ]
  end
end
