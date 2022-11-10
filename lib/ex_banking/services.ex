defmodule ExBanking.Services do
  @moduledoc false

  alias ExBanking.Core.Account
  alias ExBanking.Operations
  alias ExBanking.Services.{AccountCreator, AccountOperations, AccountRegistry, AccountServer}

  require Logger

  @spec create_account_service(account :: Account.t()) ::
          :ok | {:error, :user_already_exists}
  def create_account_service(%Account{username: username} = account) do
    if account_service_already_started?(username) do
      {:error, :user_already_exists}
    else
      case AccountCreator.start_service(account) do
        {:ok, _pid} ->
          :ok

        {:error, reason} ->
          Logger.error("Error on AccountCreator service: #{inspect(reason)}")
      end
    end
  end

  @spec check_account_service_creation(username :: String.t()) ::
          :ok | {:error, :user_does_not_exist}
  def check_account_service_creation(username) do
    if account_service_already_started?(username) do
      :ok
    else
      {:error, :user_does_not_exist}
    end
  end

  defp account_service_already_started?(username) do
    case Registry.lookup(AccountRegistry, username) do
      [] ->
        false

      [{_pid, nil}] ->
        true
    end
  end

  @spec start_operation(username :: String.t(), operation :: Operations.t()) ::
          :ok | {:error, :too_many_requests_to_user}
  def start_operation(username, operation) do
    case AccountOperations.start_operation(username, operation) do
      :too_many_requests_to_user ->
        {:error, :too_many_requests_to_user}

      :ok ->
        :ok
    end
  end

  @spec finish_operation(username :: String.t(), operation :: Operations.t()) ::
          :ok
  def finish_operation(username, operation) do
    AccountOperations.finish_operation(username, operation)
  end

  @spec update_balance_account(username :: String.t(), operation :: Operations.t()) ::
          term()
  def update_balance_account(username, %Operations.Deposit{amount: amount, currency: currency}) do
    AccountServer.deposit(username, amount, currency)
  end

  def update_balance_account(username, %Operations.Withdraw{amount: amount, currency: currency}) do
    case AccountServer.withdraw(username, amount, currency) do
      :not_enough_money ->
        {:error, :not_enough_money}

      updated_account ->
        updated_account
    end
  end

  @spec get_balance_from_account(operation :: Operations.t()) ::
          {:error, :no_wallet_with_given_currency} | {:ok, number()}
  def get_balance_from_account(%Operations.Balance{username: username, currency: currency}) do
    case AccountServer.get_balance_from_wallet(username, currency) do
      :no_wallet_with_given_currency ->
        {:error, :no_wallet_with_given_currency}

      balance ->
        {:ok, balance}
    end
  end
end
