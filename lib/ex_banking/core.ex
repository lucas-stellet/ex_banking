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
end
