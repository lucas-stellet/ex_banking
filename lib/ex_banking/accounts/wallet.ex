defmodule ExBanking.Accounts.Wallet do
  @moduledoc false

  alias Decimal, as: D

  defstruct [:balance, :currency]

  use Accessible

  @type t :: %__MODULE__{
          balance: D.t(),
          currency: String.t()
        }

  @spec new() :: t()
  def new do
    %__MODULE__{
      balance: D.new(0),
      currency: "no_currency"
    }
  end

  @spec new(amount :: number(), currency :: String.t()) :: t()
  def new(amount, currency) do
    {:ok, d_amount} = Decimal.cast(amount)

    %__MODULE__{
      balance: d_amount,
      currency: currency
    }
  end

  @spec increase_wallet_balance(wallet :: t(), amount :: number()) :: t()
  def increase_wallet_balance(wallet, amount) do
    update_in(wallet[:balance], &Decimal.add(&1, elem(Decimal.cast(amount), 1)))
  end

  @spec decrease_wallet_balance(wallet :: t(), amount :: number()) :: t() | :not_enough_money
  def decrease_wallet_balance(wallet, amount) do
    {:ok, d_amount} = Decimal.cast(amount)

    sub = D.sub(wallet.balance, d_amount)

    if D.lt?(sub, Decimal.new(0)) do
      :not_enough_money
    else
      update_in(wallet[:balance], fn _ -> sub end)
    end
  end

  @spec format_balance(wallet :: t()) :: float()
  def format_balance(%__MODULE__{balance: balance}) do
    balance
    |> D.round(2, :floor)
    |> D.to_float()
  end
end
