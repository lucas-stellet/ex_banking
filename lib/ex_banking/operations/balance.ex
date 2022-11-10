defmodule ExBanking.Operations.Balance do
  @moduledoc false

  defstruct [
    :id,
    :username,
    :currency
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          username: String.t(),
          currency: String.t()
        }

  @spec new(username :: String.t(), currency :: String.t()) :: t() | :wrong_arguments
  def new(username, currency) do
    if are_args_valid?(username, currency) do
      %__MODULE__{
        id: UUID.uuid4(),
        username: username,
        currency: currency
      }
    else
      :wrong_arguments
    end
  end

  defp are_args_valid?(username, currency),
    do: is_binary(username) and is_binary(currency) and true
end
