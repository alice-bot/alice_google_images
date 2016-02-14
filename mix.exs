defmodule AliceGoogleImages.Mixfile do
  use Mix.Project

  def project do
    [app: :alice_google_images,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:websocket_client, github: "jeremyong/websocket_client"},
      {:alice, "~> 0.1.0"}
    ]
  end
end
