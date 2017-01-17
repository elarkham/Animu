defmodule Owl.Mixfile do
  use Mix.Project

  def project do
    [app: :owl,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()
   ]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [:logger,:feeder_ex,:redix,:httpoison],
      mod: {Owl.Application, []}
    ]
  end

  defp deps do
    [ {:feeder_ex, "~> 0.0.3"},
      {:httpoison, "~> 0.9.0"},
      {:redix, "~> 0.4.0"},
    ]
  end
end
