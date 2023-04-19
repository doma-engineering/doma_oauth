defmodule DomaOAuthTest do
  use ExUnit.Case
  use Plug.Test

  import Plug.Conn

  @opts Support.Router.init([])

  describe "routing" do
    test "request phase for google routes correctly" do
      resp = generate_simple_response("/auth/google")

      assert [location] = get_resp_header(resp, "location")

      redirect_uri = URI.parse(location)
      assert redirect_uri.host == "accounts.google.com"

      assert resp.status == 302
    end

    test "request phase for github routes correctly" do
      resp = generate_simple_response("/auth/github")

      assert [location] = get_resp_header(resp, "location")

      redirect_uri = URI.parse(location)
      assert redirect_uri.host == "github.com"

      assert resp.status == 302
    end

    test "callback phase for google routes correctly" do
      %Plug.Conn{assigns: %{ueberauth_failure: %Ueberauth.Failure{provider: :google}}} =
        generate_simple_response("/auth/google/callback")
    end

    test "callback phase for github routes correctly" do
      %Plug.Conn{assigns: %{ueberauth_failure: %Ueberauth.Failure{provider: :github}}} =
        generate_simple_response("/auth/github/callback")
    end

    defp generate_simple_response(route) do
      conn = conn(:get, route, %{})
      routes = @opts |> set_options(conn, hd: "example.com", default_scope: "email openid")
      Support.Router.call(conn, routes)
    end

    defp set_options(routes, conn, opt) do
      case Enum.find_index(routes, &(elem(&1, 0) == {conn.request_path, conn.method})) do
        nil ->
          routes

        idx ->
          update_in(
            routes,
            [Access.at(idx), Access.elem(1), Access.elem(2)],
            &%{&1 | options: opt}
          )
      end
    end
  end
end
