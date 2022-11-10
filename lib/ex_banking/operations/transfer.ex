defmodule ExBanking.Operations.Transfer do
  @moduledoc false

  alias Decimal, as: D

  defstruct [
    :id,
    :amount,
    :currency,
    :type
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          currency: String.t(),
          type: atom()
        }

  @spec new(type :: atom(), amount :: number(), currency :: String.t()) :: t() | :wrong_arguments
  def new(type, amount, currency) do
    if are_args_valid?(amount, currency) do
      {:ok, d_amount} = D.cast(amount)

      %__MODULE__{
        id: UUID.uuid4(),
        amount: d_amount,
        currency: currency,
        type: type
      }
    else
      :wrong_arguments
    end
  end

  defp are_args_valid?(amount, currency),
    do: is_number(amount) and is_binary(currency) and true
end
