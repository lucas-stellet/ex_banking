defmodule ExBanking do
  @moduledoc false

  alias ExBanking.Accounts
  alias ExBanking.Operations

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    with :ok <- Accounts.validate_account_creation(user),
         :ok <- Accounts.create_account(user) do
      :ok
    else
      {:error, _reason} = error ->
        error
    end
  end

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with :ok <- Accounts.validate_deposit(user, amount, currency),
         :ok <- Operations.start_operation(user),
         {:ok, new_balance} <- Accounts.deposit_into_account(user, amount, currency),
         :ok <- Operations.finish_operation(user) do
      {:ok, new_balance}
    else
      {:error, _reason} = error ->
        Operations.finish_operation(user)
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
    with :ok <- Accounts.validate_withdraw(user, amount, currency),
         :ok <- Operations.start_operation(user),
         {:ok, new_balance} <- Accounts.withdraw_from_account(user, amount, currency),
         :ok <- Operations.finish_operation(user) do
      {:ok, new_balance}
    else
      {:error, _reason} = error ->
        Operations.finish_operation(user)
        error
    end
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with :ok <- Accounts.validate_balance(user, currency),
         :ok <- Operations.start_operation(user),
         {:ok, balance} <- Accounts.get_balance_from_account_wallet(user, currency),
         :ok <- Operations.finish_operation(user) do
      {:ok, balance}
    else
      {:error, _reason} = error ->
        Operations.finish_operation(user)
        error
    end
  end

  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) do
    with :ok <- Accounts.validate_transfer(from_user, to_user, amount, currency),
         :ok <- start_operation_to("sender", from_user),
         :ok <- start_operation_to("receiver", to_user),
         {:ok, sender_balance, receiver_balance} <-
           Accounts.send_money_from_one_account_to_another(from_user, to_user, amount, currency),
         :ok <- Operations.finish_operation(from_user),
         :ok <- Operations.finish_operation(to_user) do
      {:ok, sender_balance, receiver_balance}
    else

      {:error, :too_many_requests_to_receiver} = error ->
        Operations.finish_operation(from_user)

      {:error, _reason} = error ->
        Operations.finish_operation(from_user)
        Operations.finish_operation(to_user)
        error
    end
  end

  defp start_operation_to(who, username) do
    case Operations.start_operation(username) do
      {:error, :too_many_requests_to_user} ->
        {:error, String.to_existing_atom("too_many_requests_to_" <> who)}

      :ok ->
        :ok
    end
  end
end
