defmodule ExBanking.Core do
  @moduledoc false

  alias ExBanking.Core.{Account, Wallet}

  @spec create_account(username :: String.t()) :: {:ok, Account.t()} | {:error, :wrong_arguments}
  def create_account(username) do
    case Account.new(username) do
      :wrong_arguments ->
        {:error, :wrong_arguments}

      account ->
        {:ok, account}
    end
  end

  @spec increase_account_wallet(
          account :: Account.t(),
          amount :: Decimal.t(),
          currency :: String.t()
        ) :: Account.t()
  def increase_account_wallet(account, amount, currency) do
    account
    |> find_or_create_wallet(amount, currency)
    |> Wallet.increase_wallet_balance(amount)
    |> merge_wallet_into_wallets(account, currency)
  end

  @spec format_balance_from_wallet(account :: Account.t(), currency :: String.t()) :: number()
  def format_balance_from_wallet(account, currency) do
    account
    |> find_wallet(currency)
    |> Wallet.format_balance()
  end

  defp find_wallet(%Account{wallets: wallets}, currency),
    do: Enum.find(wallets, &(&1.currency == currency))

  defp find_or_create_wallet(%Account{wallets: [%Wallet{currency: nil}]}, amount, currency) do
    Wallet.new(amount, currency)
  end

  defp find_or_create_wallet(%Account{wallets: wallets}, _amount, currency),
    do: Enum.find(wallets, &(&1.currency == currency))

  defp merge_wallet_into_wallets(
         new_wallet,
         %Account{wallets: current_wallets} = account,
         currency
       ) do
    updated_wallets = [new_wallet | remove_wallet(current_wallets, currency)]

    %Account{
      account
      | wallets: updated_wallets
    }
  end

  defp remove_wallet(wallets, currency),
    do: Enum.reject(wallets, &(&1.currency == currency))
end
