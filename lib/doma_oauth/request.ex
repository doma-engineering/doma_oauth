defmodule DomaOAuth.Request do
  use Plug.Builder

  def init(opts), do: opts

  def call(conn, opts), do: conn
end
