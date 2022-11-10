defmodule ExBanking.Operations do
  @moduledoc false

  alias ExBanking.Operations.Deposit

  @type t :: Deposit.t()

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
end
