defmodule DomaOAuth.MixProject do
  use Mix.Project

  def project do
    [
      app: :doma_oauth,
      version: "0.1.2",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ueberauth, "~> 0.10.5"},
      {:ueberauth_google, "~> 0.10.2"},
      {:ueberauth_github, "~> 0.8.2"},
      {:jason, "~> 1.4"}
    ]
  end
end
