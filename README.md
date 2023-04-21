# DomaOAuth

Set of routes / plugs that provides easy integration of Google and Github oAuth into an Elixir application.

It is designed to be as light as possible, all this Authentication plug does is assign an `oauth` field
To your `Plug.Conn` struct, so that the rest of the logic is up to your application to implement as a callback.

## Usage

To use in your project a bit of configuration is needed.
First, in your `config.exs` add following code:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []},
    github: {Ueberauth.Strategy.Github, []}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")
```

After configuration is set, the next step is to add OAuth routes to your router
And specify the 2 arity callback function that will finalize the response.

```elixir
use Plug.Router
use DomaOAuth, callback: &MyModule.callback/2
```

This will extend your router with two additional routes (one per integration) that will be used to perform OAuth process.
By default routes will start with `/auth` prefix. So the routes will be like following:
```
/auth/google/callback
/auth/github/callback
```

This can be changed by configuring `ueberauth`:

```elixir
config :ueberauth, Ueberauth,
  # default is "/auth"
  base_path: "/oauth",
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `doma_oauth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:doma_oauth, "~> 0.1.0"}
  ]
end
```
