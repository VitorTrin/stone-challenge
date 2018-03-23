defmodule FinancialSystem.MixProject do
  use Mix.Project

  def project do
    [
      app: :financial_system,
      version: "1.0.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      test_coverage: [tool: Coverex.Task]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # XML Parser
      {:quinn, "~> 1.1"},
      # Test coverage tool
      {:coverex, "~> 1.4.10", only: :test}
    ]
  end
end
