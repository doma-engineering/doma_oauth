defmodule DomaOAuthTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  import DomaOAuth.Support.Fixtures

  alias DomaOAuth.Authentication.{Success, Failure}

  describe "call/2 with GOOGLE provider" do
    test "assigns a Success struct with blake2 encrypted :hashed_identity upon successful authentication" do
      conn =
        conn(:get, "/auth/google/callback")
        |> init_test_session(%{})
        |> Plug.Conn.assign(:ueberauth_auth, ueberauth_success(provider: :google))

      conn = DomaOAuth.call(conn, %{callback: &Support.Callback.call/2})

      expected_identity = "#{ueberauth_info().email}@google.com"

      assert %Success{hashed_identity: hashed_identity, identity: ^expected_identity} =
               conn.assigns[:oauth]

      assert hashed_identity ===
               :blake2s |> :crypto.hash(expected_identity) |> Base.url_encode64()
    end

    test "assaigns a Failure and logs error when email isn't provided in response from Google" do
      assert capture_log(fn ->
               broken_info = ueberauth_info(provider: :google, email: nil)

               conn =
                 conn(:get, "/auth/google/callback")
                 |> init_test_session(%{})
                 |> Plug.Conn.assign(
                   :ueberauth_auth,
                   ueberauth_success(provider: :google, info: broken_info)
                 )

               conn = DomaOAuth.call(conn, %{callback: &Support.Callback.call/2})

               assert %Failure{errors: ["Email isn't provided in response from Google"]} =
                        conn.assigns[:oauth]
             end) =~ "Can't collect an email from Google's response!"
    end

    test "assigns a Failure struct with populated errors field" do
      conn =
        conn(:get, "/auth/google/callback")
        |> init_test_session(%{})
        |> Plug.Conn.assign(:ueberauth_failure, ueberauth_failure(provider: :google))

      conn = DomaOAuth.call(conn, %{callback: &Support.Callback.call/2})

      assert %Failure{errors: ["something went wrong"]} = conn.assigns[:oauth]
    end
  end

  describe "call/2 with GITHUB provider" do
    test "assigns a Success struct with blake2 encrypted :hashed_identity upon successful authentication" do
      github_info = ueberauth_info(nickname: "john.doe")

      conn =
        conn(:get, "/auth/github/callback")
        |> init_test_session(%{})
        |> Plug.Conn.assign(
          :ueberauth_auth,
          ueberauth_success(provider: :github, info: github_info)
        )

      conn = DomaOAuth.call(conn, %{callback: &Support.Callback.call/2})

      expected_identity = "#{github_info.nickname}@github.com"

      assert %Success{hashed_identity: hashed_identity, identity: ^expected_identity} =
               conn.assigns[:oauth]

      assert hashed_identity === DomaOAuth.hash(expected_identity)
    end

    test "assaigns a Failure and logs error when nickname isn't provided in response from Github" do
      assert capture_log(fn ->
               broken_info = ueberauth_info(provider: :github, email: nil, nickname: nil)

               conn =
                 conn(:get, "/auth/github/callback")
                 |> init_test_session(%{})
                 |> Plug.Conn.assign(
                   :ueberauth_auth,
                   ueberauth_success(provider: :github, info: broken_info)
                 )

               conn = DomaOAuth.call(conn, %{callback: &Support.Callback.call/2})

               assert %Failure{errors: ["Nickname isn't provided in response from GitHub"]} =
                        conn.assigns[:oauth]
             end) =~ "Can't collect a nickname from GitHub's response!"
    end

    test "assigns a Failure struct with populated errors field" do
      conn =
        conn(:get, "/auth/github/callback")
        |> init_test_session(%{})
        |> Plug.Conn.assign(:ueberauth_failure, ueberauth_failure(provider: :google))

      conn = DomaOAuth.call(conn, %{callback: &Support.Callback.call/2})

      assert %Failure{errors: ["something went wrong"]} = conn.assigns[:oauth]
    end
  end
end
