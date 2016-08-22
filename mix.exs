defmodule TwilioAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :twilio_auth,
     version: "0.1.0",
     description: description(),
     package: package(),
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
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
    [{:plug, "~> 1.0"}]
  end
end
