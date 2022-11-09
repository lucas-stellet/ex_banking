defmodule ExBanking.Core.Wallet do
  @moduledoc false

  defstruct [:balance, :currency]

  @type t :: %__MODULE__{
          balance: number(),
          currency: String.t() | nil
        }

  def new do
    %__MODULE__{
      balance: 0,
      currency: nil
    }
  end

  def new(amount, currency) do
    %__MODULE__{
      balance: amount,
      currency: currency
    }
  end
end
