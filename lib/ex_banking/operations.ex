defmodule ExBanking.Operations do
  @moduledoc false

  alias ExBanking.Operations.{Deposit, Withdraw}

  @type t :: Deposit.t() | Withdraw.t()

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
end
