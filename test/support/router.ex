defmodule Support.Router do
  @moduledoc "Example router that demonstrates how to use DomaOAuth."

  use Plug.Router

  plug(Plug.Logger)

  @session_options [
    store: :cookie,
    key: "_test_key",
    signing_salt: "CKstsbhR"
  ]

  plug(Plug.Session, @session_options)

  plug(:fetch_query_params)

  plug(:match)
  # Add this line to your router
  plug(Ueberauth)
  plug(:dispatch)

  # Add this line to your router
  get("/auth/:provider/callback", to: DomaOAuth, init_opts: %{callback: &Support.Callback.call/2})

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end

defmodule Support.Callback do
  import Plug.Conn

  def call(conn, _opts) do
    conn
    |> send_resp(200, "RESPONSE_FROM_CALLBACK")
    |> halt()
  end
end
