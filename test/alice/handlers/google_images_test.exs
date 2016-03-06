defmodule FakeHTTPoison do
  def get(url, _headers, opts\\[]) do
    opts
    |> Keyword.get(:params, [])
    |> Enum.into(%{})
    |> handle_get(url)
  end

  defp handle_get(%{q: "good result"}, _url) do
    {:ok, %HTTPoison.Response{status_code: 200, body: :body}}
  end
  defp handle_get(%{q: "bad result"}, _url) do
    {:error, %HTTPoison.Error{reason: :reason}}
  end
  defp handle_get(params=%{q: "mock result"}, url) do
    send(self, {:mock_response, {url, params}})
    {:ok, %HTTPoison.Response{status_code: 200, body: :body}}
  end
end

defmodule Alice.Handlers.GoogleImagesTest do
  use ExUnit.Case, async: true
  alias Alice.Handlers.GoogleImages, as: GI

  setup do
    Logger.disable(self)
    :ok
  end

  test "extract_term gets the term" do
    {:ok, pattern} = GI.routes
                     |> Enum.map(fn({p,n}) -> {n,p} end)
                     |> Keyword.fetch(:fetch_image)

    conn = Alice.Conn.make(%{text: "img me stuff"}, :slack, :state)
           |> Alice.Conn.add_captures(pattern)
    assert GI.extract_term(conn) == "stuff"
  end

  test "get_images returns the response" do
    assert {:ok, :body} = GI.get_images(q: "good result")
  end

  test "get_images returns an error when there is an error" do
    assert {:error, :reason} = GI.get_images(q: "bad result")
  end

  test "get_images calls HTTPoison get with the correct options" do
    url = "https://www.googleapis.com/customsearch/v1"
    GI.get_images(q: "mock result")

    assert_received {:mock_response, {^url, params}}
    assert "mock result" = params[:q]
  end
end
