defmodule ExBanking.Accounts do
  @moduledoc false

  alias ExBanking.Accounts.{TransactionsValidator, Wallet}
  alias ExBanking.Repository

  require Logger

  defdelegate validate_account_creation(username),
    to: TransactionsValidator,
    as: :validate_account_creation

  defdelegate validate_deposit(username, amount, currency),
    to: TransactionsValidator,
    as: :validate_deposit_or_withdraw

  defdelegate validate_withdraw(username, amount, currency),
    to: TransactionsValidator,
    as: :validate_deposit_or_withdraw

  defdelegate validate_balance(username, currency),
    to: TransactionsValidator,
    as: :validate_balance

  defdelegate validate_transfer(sender_username, receiver_username, amount, currency),
    to: TransactionsValidator,
    as: :validate_transfer

  def create_account(username) do
    with nil <- Repository.get(username),
         :ok <- Repository.insert(username, [Wallet.new()]) do
      :ok
    else
      [%Wallet{} | _] ->
        {:error, :user_already_exists}

      error ->
        Logger.error("Error when creating an account :: #{inspect(error)}")
    end
  end

  def deposit_into_account(username, amount, currency) do
    if Repository.exists?(username) do
      Repository.transaction(username, fn db ->
        wallets = Repository.get!(username, db)

        updated_wallets =
          case find_wallet(wallets, currency) do
            %Wallet{} = wallet ->
              wallet
              |> Wallet.increase_wallet_balance(amount)
              |> merge_wallet_into_wallets(wallets, currency)

            nil ->
              amount
              |> Wallet.new(currency)
              |> merge_wallet_into_wallets(wallets, currency)
          end

        Repository.update!(username, updated_wallets, db)

        updated_wallets
        |> find_wallet(currency)
        |> Wallet.format_balance()
      end)
    else
      {:error, :user_does_not_exist}
    end
  end

  def withdraw_from_account(username, amount, currency) do
    if Repository.exists?(username) do
      Repository.transaction(username, fn db ->
        account = Repository.get!(username, db)

        with %Wallet{} = wallet <- find_wallet(account, currency),
             %Wallet{} = decreased_wallet <- Wallet.decrease_wallet_balance(wallet, amount),
             updated_account <- merge_wallet_into_wallets(decreased_wallet, account, currency) do
          Repository.update!(username, updated_account, db)

          balance =
            updated_account
            |> find_wallet(currency)
            |> Wallet.format_balance()

          {:ok, balance}
        else
          _ ->
            {:error, :not_enough_money}
        end
      end)
      |> then(fn
        {:ok, {:ok, balance}} ->
          {:ok, balance}

        {:ok, {:error, reason}} ->
          {:error, reason}
      end)
    else
      {:error, :user_does_not_exist}
    end
  end

  def get_balance_from_account_wallet(username, currency) do
    if Repository.exists?(username) do
      username
      |> Repository.get!()
      |> find_wallet(currency)
      |> case do
        nil ->
          {:ok, 0}

        %Wallet{} = wallet ->
          {:ok, Wallet.format_balance(wallet)}
      end
    else
      {:error, :user_does_not_exist}
    end
  end

  def send_money_from_one_account_to_another(sender_username, receiver_username, amount, currency) do
    with :ok <- check_receiver_account_existence(receiver_username),
         :ok <- check_sender_account_existence(sender_username) do
      Repository.transaction([sender_username, receiver_username], fn db ->
        receiver_wallets = Repository.get!(receiver_username, db)
        sender_wallets = Repository.get!(sender_username, db)

        with %Wallet{} = sender_wallet <- find_wallet(sender_wallets, currency),
             %Wallet{} = updated_sender_wallet <-
               Wallet.decrease_wallet_balance(sender_wallet, amount) do
          updated_receiver_wallet =
            receiver_wallets
            |> find_wallet(currency)
            |> case do
              nil ->
                Wallet.new(amount, currency)

              %Wallet{} = wallet ->
                Wallet.increase_wallet_balance(wallet, amount)
            end

          Repository.update!(
            sender_username,
            merge_wallet_into_wallets(updated_sender_wallet, sender_wallets, db)
          )

          Repository.update!(
            receiver_username,
            merge_wallet_into_wallets(updated_receiver_wallet, receiver_wallets, db)
          )

          {:ok, Wallet.format_balance(updated_sender_wallet),
           Wallet.format_balance(updated_receiver_wallet)}
        else
          nil ->
            {:error, :not_enough_money}

          :not_enough_money ->
            {:error, :not_enough_money}
        end
      end)
      |> then(fn
        {:ok, {:ok, sender_balance, receiver_balance}} ->
          {:ok, sender_balance, receiver_balance}

        {:ok, {:error, reason}} ->
          {:error, reason}
      end)
    else
      error ->
        error
    end
  end

  defp check_receiver_account_existence(username) do
    if Repository.exists?(username) do
      :ok
    else
      {:error, :receiver_does_not_exist}
    end
  end

  defp check_sender_account_existence(username) do
    if Repository.exists?(username) do
      :ok
    else
      {:error, :sender_does_not_exist}
    end
  end

  defp find_wallet([%Wallet{currency: "no_currency"}], _currency),
    do: nil

  defp find_wallet(wallets, currency),
    do: Enum.find(wallets, &(&1.currency == currency))

  defp merge_wallet_into_wallets(
         new_wallet,
         current_wallets,
         currency
       ) do
    [new_wallet | remove_wallet(current_wallets, currency)]
  end

  defp remove_wallet(wallets, currency),
    do: Enum.reject(wallets, &(&1.currency == currency))
end
