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

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    operation = Operations.new_balance(user, currency)

    with :ok <- Services.check_account_service_creation(user),
         {:ok, balance_operation} <- operation,
         :ok <- Services.start_operation(user, balance_operation),
         {:ok, balance} <- Services.get_balance_from_account(balance_operation) do
      Services.finish_operation(user, balance_operation)
      {:ok, balance}
    else
      {:error, :no_wallet_with_given_currency} ->
        {:ok, balance_operation} = operation

        Services.finish_operation(user, balance_operation)

        {:error, :wrong_arguments}

      {:error, _reason} = error ->
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
    from_user_operation = Operations.new_transfer(:sender, amount, currency)
    to_user_operation = Operations.new_transfer(:receiver, amount, currency)

    with {:ok, _from_user} <-
           pack_condition_to_sender(Services.check_account_service_creation(from_user)),
         {:ok, _to_user} <-
           pack_condition_to_receiver(Services.check_account_service_creation(to_user)),
         {{:ok, from_user_transfer_operation}, _from_user} <-
           pack_condition_to_sender(from_user_operation),
         {{:ok, to_user_transfer_operation}, _to_user} <-
           pack_condition_to_receiver(to_user_operation),
         {:ok, _} <-
           pack_condition_to_sender(
             Services.start_operation(from_user, from_user_transfer_operation)
           ),
         {:ok, _} <-
           pack_condition_to_receiver(
             Services.start_operation(to_user, to_user_transfer_operation)
           ),
         {{:ok, sender_balance}, _from_user} <-
           pack_condition_to_sender(Services.send_money(from_user, from_user_transfer_operation)),
         {{:ok, receiver_balance}, _from_user} <-
           pack_condition_to_receiver(Services.receive_money(to_user, to_user_transfer_operation)) do
      Services.finish_operation(from_user, unpack_user_operation(from_user_operation))
      Services.finish_operation(to_user, unpack_user_operation(to_user_operation))

      {:ok, sender_balance, receiver_balance}
    else
      {{:error, :user_does_not_exist}, who} ->
        {:error, format_error_response_to_person(who, "_does_not_exist")}

      {{:error, :too_many_requests_to_user}, who} ->
        {:error, format_error_response_to_person(who, "_too_many_requests_to")}

      {{:error, reason}, _} ->
        Services.finish_operation(from_user, unpack_user_operation(from_user_operation))
        Services.finish_operation(to_user, unpack_user_operation(to_user_operation))
        {:error, reason}
    end
  end

  defp format_error_response_to_person(who, error_message) do
    String.to_atom(who <> error_message)
  end

  defp unpack_user_operation(packed_user_operation), do: elem(packed_user_operation, 1)

  defp pack_condition_to_sender(condition), do: {condition, "sender"}
  defp pack_condition_to_receiver(condition), do: {condition, "receiver"}
end
