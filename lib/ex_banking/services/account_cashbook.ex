defmodule ExBanking.Services.AccountCashbook do
  @moduledoc false

  alias ExBanking.Operations

  @cache_name :account_cashbook

  @type t :: %__MODULE__{
          balance: Decimal.t(),
          last_updated_at: DateTime.t(),
          operations: [Operations.t()] | []
        }

  defstruct [:balance, :last_updated_at, :operations]

  @spec register_last_balance(username :: String.t(), balance :: Decimal.t()) :: :ok
  def register_last_balance(username, balance) do
    Cachex.get_and_update!(@cache_name, username, fn
      nil -> {:commit, new(balance)}
      registry -> {:commit, update_balance(registry, balance)}
    end)

    :ok
  end

  @spec update_account_operations(username :: String.t(), operation :: Operations.t()) :: :ok
  def update_account_operations(username, operation) do
    Cachex.get_and_update(@cache_name, username, fn
      nil -> {:commit, new(0, operation)}
      registry -> {:commit, update_operations(registry, operation)}
    end)

    :ok
  end

  defp new(balance, operations \\ []) do
    %__MODULE__{
      balance: balance,
      last_updated_at: DateTime.utc_now(),
      operations: operations
    }
  end

  defp update_balance(cashbook_registry, new_balance) do
    %__MODULE__{
      cashbook_registry
      | balance: new_balance,
        last_updated_at: DateTime.utc_now()
    }
  end

  defp update_operations(cashbook_registry, new_operation) do
    %__MODULE__{
      cashbook_registry
      | operations: [new_operation | cashbook_registry.operations],
        last_updated_at: DateTime.utc_now()
    }
  end
end
