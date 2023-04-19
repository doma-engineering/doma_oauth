defmodule DomaOAuth do
  @moduledoc """
  Documentation for `DomaOAuth`.
  """
  defmacro __using__(_) do
    quote do
      plug(Ueberauth)

      alias DomaOAuth.{Authentication, Request}

      forward("/:provider/callback", to: Authentication)
      forward("/:provider", to: Request)
    end
  end
end
