# DomaOAuth

Set of routes / plugs that provides easy integration of Google and Github oAuth into an Elixir application.

It is designed to be as light as possible, all this Authentication plug does is assign an `oauth` field
To your `%Plug.Conn{}` struct, so that the rest of the logic is up to your application to implement as a callback.

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
and to add an Ueberauth plug between :match and :dispatch plugs
And specify the 2 arity callback function that will finalize the response.

```elixir
use Plug.Router

plug :match
plug Ueberauth
plug :dispatch

get("/auth/:provider/callback",
  to: DomaOAuth,
  init_opts: %{callback: &YourApp.CallbackModule.call/2}
)
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
  # note, that this path needs to match with the one you specified in the router for the callback
  base_path: "/oauth",
```

It is important to make all information about request available in headers (via X-Forwarded-*) headers if using a reverse-proxy, this is a working example for Nginx:

```nginx
location / {
  proxy_pass http://127.0.0.1:4001;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host $host;
  proxy_set_header X-Forwarded-Proto $scheme;
  ...
}
```

The reason for is that redirect uri will be inferred by using those headers. See [this link](https://github.com/ueberauth/ueberauth/issues/65#issuecomment-367263067) for more details.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `doma_oauth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:doma_oauth, git: "https://github.com/doma-engineering/doma_oauth", branch: "main"}
  ]
end
```
