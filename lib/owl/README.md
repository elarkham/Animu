# Muninn

Pipline used to auto-download new episodes of shows by periodically scanning rss feeds, sorting downloads to their appropriate folders and then adding them to my Animu stack.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `muninn` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:muninn, "~> 0.1.0"}]
    end
    ```

  2. Ensure `muninn` is started before your application:

    ```elixir
    def application do
      [applications: [:muninn]]
    end
    ```

