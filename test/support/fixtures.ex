defmodule DomaOAuth.Support.Fixtures do
  def ueberauth_success(opts) when is_list(opts) do
    provider = Keyword.fetch!(opts, :provider)
    info = Keyword.get(opts, :info, ueberauth_info())

    %Ueberauth.Auth{
      # An identifier unique to the given provider, such as a Twitter user ID. Should be stored as a string.
      uid: "123456789",
      provider: provider,
      strategy: strategy_from_provider(provider),
      info: info
    }
  end

  def ueberauth_failure(opts) when is_list(opts) do
    provider = Keyword.fetch!(opts, :provider)
    message = Keyword.get(opts, :message, "something went wrong")
    message_key = Keyword.get(opts, :message_key, "E1")

    %Ueberauth.Failure{
      provider: provider,
      errors: [%Ueberauth.Failure.Error{message: message, message_key: message_key}]
    }
  end

  def ueberauth_info(opts \\ []) do
    email = Keyword.get(opts, :email, "john.doe@example.com")
    nickname = Keyword.get(opts, :nickname)

    %Ueberauth.Auth.Info{
      name: nil,
      first_name: nil,
      last_name: nil,
      nickname: nickname,
      email: email
    }
  end

  defp strategy_from_provider(:google), do: Ueberauth.Strategy.Google
  defp strategy_from_provider(:github), do: Ueberauth.Strategy.Github
end
