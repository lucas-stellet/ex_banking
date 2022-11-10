defmodule ExBanking.Operations.Withdraw do
  @moduledoc false

  alias Decimal, as: D

  defstruct [
    :id,
    :amount,
    :currency
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          amount: D.t(),
          currency: String.t()
        }

  @spec new(amount :: number(), currency :: String.t()) :: t() | :wrong_arguments
  def new(amount, currency) do
    if are_args_valid?(amount, currency) do
      {:ok, d_amount} = D.cast(amount)

      %__MODULE__{
        id: UUID.uuid4(),
        amount: d_amount,
        currency: currency
      }
    else
      :wrong_arguments
    end
  end

  defp are_args_valid?(amount, currency),
    do: amount > 0 and is_number(amount) and is_binary(currency) and true
end
