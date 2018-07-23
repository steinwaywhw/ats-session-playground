defmodule App.Mixfile do
  use Mix.Project

  def project do
    [app: :app,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :gproc, :gen_leader]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:test, path: "../", app: false, compile: "make deploy"},
      # {:mix_erlang_tasks, git: "https://github.com/alco/mix-erlang-tasks"},
      {:gproc, git: "https://github.com/uwiger/gproc"},
      {:edown, git: "https://github.com/uwiger/edown.git"},
      {:gen_leader, git: "https://github.com/garret-smith/gen_leader_revival.git"}
    ]
  end
end
