# AliceGoogleImages

This handler will allow Alice look up random images on Google Images

## Installation

If [available in Hex](https://hex.pm/packages/alice_google_images), the package can be installed as:

  1. Add `alice_google_images` to your list of dependencies in `mix.exs`:

    ```elixir
    defp deps do
       [
         {:websocket_client, github: "jeremyong/websocket_client"},
         {:alice, "~> 0.2.0"},
         {:alice_google_images, "~> 0.1.0"}
       ]
    end
    ```

  2. Add the handler to your list of registered handlers in `mix.exs`:

    ```elixir
    def application do
      [applications: [:alice],
        mod: {
          Alice, [Alice.Handlers.GoogleImages, ...]}]
    end
    ```

## Configuration

### Custom Search Engine
Google no longer offers an unregistered image search API. You must set up a
[Google Custom Search API](https://developers.google.com/custom-search/docs/overview).

The Custom Search API provides up to [100 search queries per day](https://developers.google.com/custom-search/json-api/v1/overview) for free.
If you need more than that you'll have to pay.

#### CSE setup details
1. Create a CSE via these [instructions](https://developers.google.com/custom-search/docs/tutorial/creatingcse).
  - To simulate the old behavior:  select "Search the entire web but emphasize included sites" in 'Sites to Search'
  - Give it any site on creation, and then remove it when it's selected, unless you want to emphasize that site(s).
2. Turn on images in Edit Search Engine > Setup > Basic > Image Search
3. Get the CSE ID in Edit Search Engine > Setup > Basic > Details (via [these instructions](https://support.google.com/customsearch/answer/2649143?hl=en))
4. Get the CSE KEY here https://code.google.com/apis/console
  - You will need a project, you may reuse an existing one, or create a new one
  - Select the project
  - Goto the API manager and create a server credential and use the key from that credential
5. Enable Custom Search API
  - https://console.developers.google.com
  - Select "Enable APIs and get credentials like keys" in your new project
  - Click "Custom Search API"
  - Click the button "Enable API"
6. Update your conf (and your modules if necessary)

### Configure Alice

In your bot's `config.exs`:

```elixir
config :alice_google_images,
  cse_id: System.get_env("GOOGLE_CSE_ID"),
  cse_token: System.get_env("GOOGLE_CSE_TOKEN"),
  safe_search_level: :medium # other possible values are :high or :off
```

## Usage

Use `@alice help` for more information.
