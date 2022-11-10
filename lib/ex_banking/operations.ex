defmodule ExBanking.Operations do
  @moduledoc false

  alias ExBanking.Operations.{Balance, Deposit, Transfer, Withdraw}

  @type t :: Deposit.t() | Withdraw.t() | Balance.t() | Transfer.t()
  @spec new_deposit(amount :: number(), currency :: String.t()) ::
          {:ok, Deposit.t()} | {:error, :wrong_arguments}
  def new_deposit(amount, currency) do
    case Deposit.new(amount, currency) do
      :wrong_arguments ->
        {:error, :wrong_arguments}

      deposit_operation ->
        {:ok, deposit_operation}
    end
  end

  @spec new_withdraw(amount :: number(), currency :: String.t()) ::
          {:ok, Withdraw.t()} | {:error, :wrong_arguments}
  def new_withdraw(amount, currency) do
    case Withdraw.new(amount, currency) do
      :wrong_arguments ->
        {:error, :wrong_arguments}

      withdraw_operation ->
        {:ok, withdraw_operation}
    end
  end

  @spec new_transfer(type :: atom(), amount :: number(), currency :: String.t()) ::
          {:ok, Transfer.t()} | {:error, :wrong_arguments}
  def new_transfer(type, amount, currency) do
    case Transfer.new(type, amount, currency) do
      :wrong_arguments ->
        {:error, :wrong_arguments}

      transfer_operation ->
        {:ok, transfer_operation}
    end
  end

  @spec new_balance(username :: String.t(), currency :: String.t()) ::
          {:ok, Balance.t()} | {:error, :wrong_arguments}
  def new_balance(username, currency) do
    case Balance.new(username, currency) do
      :wrong_arguments ->
        {:error, :wrong_arguments}

      balance_operation ->
        {:ok, balance_operation}
    end
  end
end
