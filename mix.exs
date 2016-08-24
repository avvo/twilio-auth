defmodule TwilioAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :twilio_auth,
     version: "0.3.0",
     description: description(),
     package: package(),
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     dialyzer: [plt_add_deps: :transitive, plt_file: ".local.plt"]
    ]
  end

  def application do
    [applications: [:logger, :plug]]
  end

  defp description do
    "Library providing authentication for https requests from twilio."
  end

  defp package() do
    [
      name: :twilio_auth,
      maintainers: ["Avvo, Inc", "Chris Wilhelm"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/avvo/twilio-auth"
      }
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.0"},
      {:dialyxir, "~> 0.3.5", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
