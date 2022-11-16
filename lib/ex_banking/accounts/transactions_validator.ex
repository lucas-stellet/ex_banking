defmodule ExBanking.Accounts.TransactionsValidator do
  @moduledoc false

  @spec validate_account_creation(username :: String.t()) ::
          :ok | {:error, :wrong_arguments}
  def validate_account_creation(username) do
    if are_args_valid?(username) do
      :ok
    else
      {:error, :wrong_arguments}
    end
  end

  @spec validate_deposit_or_withdraw(
          username :: String.t(),
          amount :: number(),
          currency :: String.t()
        ) ::
          :ok | {:error, :wrong_arguments}
  def validate_deposit_or_withdraw(username, amount, currency) do
    if are_args_valid?(username, amount, currency) do
      :ok
    else
      {:error, :wrong_arguments}
    end
  end

  @spec validate_balance(
          username :: String.t(),
          currency :: String.t()
        ) ::
          :ok | {:error, :wrong_arguments}
  def validate_balance(username, currency) do
    if are_args_valid?(username, currency) do
      :ok
    else
      {:error, :wrong_arguments}
    end
  end

  @spec validate_transfer(
          sender_username :: String.t(),
          receiver_username :: String.t(),
          amount :: number(),
          currency :: String.t()
        ) ::
          :ok | {:error, :wrong_arguments}
  def validate_transfer(sender_username, receiver_username, amount, currency) do
    if are_args_valid?(sender_username, receiver_username, amount, currency) do
      :ok
    else
      {:error, :wrong_arguments}
    end
  end

  defp are_args_valid?(username),
    do:
      is_bitstring(username) and
        true

  defp are_args_valid?(username, currency),
    do:
      is_bitstring(currency) and is_bitstring(username) and
        true

  defp are_args_valid?(username, amount, currency),
    do:
      amount >= 0 and is_number(amount) and is_bitstring(currency) and is_bitstring(username) and
        true

  defp are_args_valid?(sender_username, receiver_username, amount, currency),
    do:
      amount >= 0 and is_number(amount) and is_bitstring(currency) and
        is_bitstring(sender_username) and is_bitstring(receiver_username) and
        true
end
