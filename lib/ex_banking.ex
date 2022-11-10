defmodule ExBanking do
  @moduledoc false

  alias ExBanking.Core
  alias ExBanking.Operations
  alias ExBanking.Services

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    with {:ok, account} <- Core.create_account(user),
         :ok <- Services.create_account_service(account) do
      :ok
    else
      error ->
        error
    end
  end

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with :ok <- Services.check_account_service_creation(user),
         {:ok, deposit_operation} <- Operations.new_deposit(amount, currency),
         :ok <- Services.start_operation(user, deposit_operation),
         new_balance <- Services.update_balance_account(user, deposit_operation) do
      Services.finish_operation(user, deposit_operation)
      {:ok, new_balance}
    else
      {:error, _reason} = error ->
        error
    end
  end

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}

  def withdraw(user, amount, currency) do
    operation = Operations.new_withdraw(amount, currency)

    with :ok <- Services.check_account_service_creation(user),
         {:ok, withdraw_operation} <- operation,
         :ok <- Services.start_operation(user, withdraw_operation),
         {:ok, new_balance} <- Services.update_balance_account(user, withdraw_operation) do
      Services.finish_operation(user, withdraw_operation)
      {:ok, new_balance}
    else
      {:error, :not_enough_money} = error ->
        {:ok, withdraw_operation} = operation
        Services.finish_operation(user, withdraw_operation)

        error

      {:error, _reason} = error ->
        error
    end
  end
end
