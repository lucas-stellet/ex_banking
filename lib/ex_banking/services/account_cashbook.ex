defmodule ExBanking.Services.AccountCashbook do
  @moduledoc false

  alias ExBanking.Core.Wallet

  @cache_name :account_cashbook

  @type t :: %__MODULE__{
          wallets: list(Wallet.t()),
          last_updated_at: DateTime.t()
        }

  defstruct [:wallets, :last_updated_at]

  @spec register_last_wallets(username :: String.t(), wallets :: list(Wallet.t())) :: :ok
  def register_last_wallets(username, wallets) do
    Cachex.get_and_update!(@cache_name, username, fn
      nil -> {:commit, new(wallets)}
      registry -> {:commit, update_wallets(registry, wallets)}
    end)

    :ok
  end

  @spec get_last_wallets(username :: String.t()) :: Decimal.t() | nil
  def get_last_wallets(username) do
    case Cachex.get(@cache_name, username) do
      {:ok, nil} ->
        nil

      # coveralls-ignore-start
      {:ok, registry} ->
        registry.wallets
        # coveralls-ignore-stop
    end
  end

  defp new(wallets) do
    %__MODULE__{
      wallets: wallets,
      last_updated_at: DateTime.utc_now()
    }
  end

  defp update_wallets(cashbook_registry, new_wallets) do
    %__MODULE__{
      cashbook_registry
      | wallets: new_wallets,
        last_updated_at: DateTime.utc_now()
    }
  end
end
