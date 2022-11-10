defmodule ExBanking.Core.Wallet do
  @moduledoc false

  alias Decimal, as: D

  defstruct [:balance, :currency]

  use Accessible

  @type t :: %__MODULE__{
          balance: D.t(),
          currency: String.t() | nil
        }

  @spec new() :: t()
  def new do
    %__MODULE__{
      balance: D.new(0),
      currency: nil
    }
  end

  @spec new(amount :: D.t(), currency :: String.t()) :: t()
  def new(amount, currency) do
    %__MODULE__{
      balance: amount,
      currency: currency
    }
  end

  @spec increase_wallet_balance(wallet :: t(), amount :: D.t()) :: t()
  def increase_wallet_balance(wallet, amount),
    do: update_in(wallet[:balance], &Decimal.add(&1, amount))

  @spec format_balance(wallet :: t()) :: float()
  def format_balance(%__MODULE__{balance: balance}) do
    balance
    |> D.round(2, :floor)
    |> D.to_float()
  end
end
