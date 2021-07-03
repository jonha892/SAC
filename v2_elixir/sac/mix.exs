defmodule SAC.MixProject do
  use Mix.Project

  def project do
    [
      app: :sac,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        prod: [
          include_executables_for: [:unix],
          steps: [:assemble, :tar]
        ]
      ],
      escript: escript_config()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SAC, []},
      #applications: [:bamboo, :nostrum],
      extra_applications: [:logger, :finch]
    ]
  end

  def escript_config do
    [main_module: SAC]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4"},
      {:bamboo, "~> 2.1.0"},
      #{:bamboo_gmail, "~> 0.2.0"},
      {:bamboo_smtp, "~> 4.0.1"},
      {:finch, "~> 0.8"},
      {:floki, "~> 0.31.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
