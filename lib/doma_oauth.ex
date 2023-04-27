defmodule DomaOAuth do
  @moduledoc """
  Documentation for `DomaOAuth`.
  """
  @behaviour Plug

  import Plug.Conn

  require Logger

  alias DomaOAuth.Authentication.{Success, Failure}

  def hash(string) do
    :blake2s |> :crypto.hash(string) |> Base.url_encode64()
  end

  def init(opts), do: opts

  def call(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, opts) do
    conn
    |> assign(:oauth, success(auth))
    |> call_the_callback(opts)
  end

  def call(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{errors: errors}}} = conn, opts) do
    conn
    |> assign(:oauth, errors |> extract_error_messages |> failure())
    |> call_the_callback(opts)
  end

  defp call_the_callback(conn, opts) do
    callback = Map.fetch!(opts, :callback)

    callback.(conn, opts)
  end

  defp success(%Ueberauth.Auth{provider: :google, info: %{email: email}})
       when not is_nil(email) and email != "" do
    identity = "#{email}@google.com"
    hashed_identity = hash(identity)

    %Success{identity: identity, hashed_identity: hashed_identity}
  end

  defp success(%Ueberauth.Auth{provider: :github, info: %{nickname: nickname}})
       when not is_nil(nickname) and nickname != "" do
    identity = "#{nickname}@github.com"
    hashed_identity = hash(identity)

    %Success{identity: identity, hashed_identity: hashed_identity}
  end

  defp success(%Ueberauth.Auth{provider: :google, uid: uid}) do
    Logger.error(
      "[#{__MODULE__}] Can't collect an email from Google's response! Auth uid: #{uid}."
    )

    %Failure{errors: ["Email isn't provided in response from Google"]}
  end

  defp success(%Ueberauth.Auth{provider: :github, uid: uid}) do
    Logger.error(
      "[#{__MODULE__}] Can't collect a nickname from GitHub's response! Auth uid: #{uid}."
    )

    %Failure{errors: ["Nickname isn't provided in response from GitHub"]}
  end

  defp failure(errors) do
    %Failure{errors: errors}
  end

  defp extract_error_messages(errors) do
    Enum.map(errors, fn %Ueberauth.Failure.Error{message: message} ->
      message
    end)
  end
end
