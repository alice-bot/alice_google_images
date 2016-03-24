defmodule Alice.Handlers.GoogleImages do
  @moduledoc """
  This handler will allow Alice look up random images on Google Images.

  Google no longer offers an unregistered image search API. You must [set up] a
  Google Custom Search API account.

  (See the [readme] for more information.)

  [set up]: https://developers.google.com/custom-search/docs/overview
  [readme]: https://github.com/alice-bot/alice_google_images
  """

  use Alice.Router
  import Application, only: [get_env: 2]
  alias HTTPoison.Response, as: HTTPResponse
  alias HTTPoison.Error, as: HTTPError

  @url "https://www.googleapis.com/customsearch/v1"

  route ~r/(image|img)\s+me (?<term>.+)/i, :fetch_image
  command ~r/(image|img)\s+me (?<term>.+)/i, :fetch_image
  route ~r/(animate|gif)\s+me (?<term>.+)/i, :fetch_animated
  command ~r/(animate|gif)\s+me (?<term>.+)/i, :fetch_animated

  @doc "`gif me ____` - attempts to get a random gif from Google Images"
  def fetch_animated(conn), do: fetch(conn, :animated)

  @doc "`img me ____` - gets a random image from Google Images"
  def fetch_image(conn), do: fetch(conn, :image)

  def fetch(conn, type) do
    conn
    |> Conn.last_capture
    |> query_params(type)
    |> get_images
    |> select_image
    |> test_image
    |> reply(conn)
  end

  defp http do
    case Mix.env do
      :test -> FakeHTTPoison
      _else -> HTTPoison
    end
  end

  def query_params(term, :animated) do
    [fileType: "gif",
     hq: "animated",
     tbs: "itp:animated"]
    |> Keyword.merge(query_params(term, :image))
  end
  def query_params(term, :image) do
    [q: term,
     v: "1.0",
     searchType: "image",
     cx: get_env(:alice_google_images, :cse_id),
     key: get_env(:alice_google_images, :cse_token),
     safe: safe_value,
     fields: "items(link)",
     rsz: 8]
  end

  def get_images(params) do
    case http.get(@url, [], params: params) do
      {:ok, %HTTPResponse{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, response} ->
        reason = parse_error(response)
        Logger.warn("Google Images: Something went wrong, #{reason}")
        {:error, reason}
      {:error, %HTTPError{reason: reason}} ->
        Logger.warn("Couldn't get image from Google: #{reason}")
        {:error, reason}
    end
  end

  defp safe_value, do: safe_value(get_env(:alice_google_images, :safe_search_level))
  defp safe_value(level) when level in [:high, :medium, :off], do: level
  defp safe_value(_), do: :high

  defp parse_error(response) do
    response.body
    |> Poison.decode!
    |> get_in(["error", "errors"])
    |> case do
      [error|_] -> Map.get(error, "reason", "unknown")
      _         -> "unknown"
    end
  end

  defp select_image({:error, reason}), do: "Error: #{reason}"
  defp select_image({:ok, body}) do
    body
    |> Poison.decode!
    |> Map.get("items", [%{}])
    |> Enum.random
    |> Map.get("link")
  end

  defp test_image(nil), do: "No images found"
  defp test_image(image) do
    image
    |> http.get
    |> test_resp(image)
  end

  defp test_resp({:ok, %HTTPResponse{status_code: 200}}, image), do: image
  defp test_resp(_bad_response, _img) do
    ["I found an image but I'm not feeling it",
     "Nah",
     "You wouldn't like the results of that search anyway",
     "You can do better than that",
     "This is not the image you are looking for :hand:"]
    |> Enum.random
  end
end
