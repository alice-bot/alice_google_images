defmodule AliceGoogleImages.Mixfile do
  use Mix.Project

  def project do
    [app: :alice_google_images,
     version: "0.1.4",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "A handler for the Alice Slack bot. Get random images from Google",
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:alice, "~> 0.3"}
    ]
  end

  defp package do
    [files: ["lib", "config", "mix.exs", "README*"],
     maintainers: ["Adam Zaninovich"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/adamzaninovich/alice_google_images"}]
  end
end
