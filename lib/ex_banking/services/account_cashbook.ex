defmodule ExBanking.Services.AccountCashbook do
  @moduledoc false

  @cache_name :account_cashbook

  @type t :: %__MODULE__{
          balance: Decimal.t(),
          last_updated_at: DateTime.t()
        }

  defstruct [:balance, :last_updated_at]

  @spec register_last_balance(username :: String.t(), balance :: Decimal.t()) :: :ok
  def register_last_balance(username, balance) do
    Cachex.get_and_update!(@cache_name, username, fn
      nil -> {:commit, new(balance)}
      registry -> {:commit, update_balance(registry, balance)}
    end)

    :ok
  end

  @spec get_last_balance(username :: String.t()) :: Decimal.t() | nil
  def get_last_balance(username) do
    case Cachex.get(@cache_name, username) do
      {:ok, nil} ->
        nil

      {:ok, balance} ->
        balance
    end
  end

  defp new(balance) do
    %__MODULE__{
      balance: balance,
      last_updated_at: DateTime.utc_now()
    }
  end

  defp update_balance(cashbook_registry, new_balance) do
    %__MODULE__{
      cashbook_registry
      | balance: new_balance,
        last_updated_at: DateTime.utc_now()
    }
  end
end
