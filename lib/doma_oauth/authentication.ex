defmodule DomaOAuth.Authentication do
  use Plug.Builder

  require Logger

  alias DomaOAuth.Authentication.{Success, Failure}

  def init(opts), do: opts

  def call(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _opts) do
    assign(conn, :oauth, success(auth))
  end

  def call(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{errors: errors}}} = conn, _opts) do
    assign(conn, :oauth, errors |> extract_error_messages |> failure())
  end

  defp success(%Ueberauth.Auth{provider: :google, info: %{email: email}})
       when not is_nil(email) and email != "" do
    identity = "#{email}@google.com"
    hashed_identity = blake2_hash(identity)

    %Success{identity: identity, hashed_identity: hashed_identity}
  end

  defp success(%Ueberauth.Auth{provider: :github, info: %{nickname: nickname}})
       when not is_nil(nickname) and nickname != "" do
    identity = "#{nickname}@github.com"
    hashed_identity = blake2_hash(identity)

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

  defp blake2_hash(string) do
    :blake2s |> :crypto.hash(string) |> Base.url_encode64()
  end

  defp extract_error_messages(errors) do
    Enum.map(errors, fn %Ueberauth.Failure.Error{message: message} ->
      message
    end)
  end
end
