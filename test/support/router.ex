defmodule Support.Router do
  @moduledoc "Example router that demonstrates how to use DomaOAuth."

  use Plug.Router
  use DomaOAuth

  @session_options [
    store: :cookie,
    key: "_test_key",
    signing_salt: "CKstsbhR"
  ]

  plug(Plug.Session, @session_options)

  plug(:fetch_query_params)

  plug(:match)
  plug(:dispatch)

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
