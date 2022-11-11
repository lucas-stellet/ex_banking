defmodule ExBanking.Services.AccountServer do
  @moduledoc false

  use GenServer

  alias ExBanking.Core
  alias ExBanking.Core.Account
  alias ExBanking.Services.{AccountCashbook, AccountRegistry}

  require Logger

  # Public functions

  @spec start_link(account :: Account.t()) :: GenServer.on_start()
  def start_link(account) do
    case AccountCashbook.get_last_wallets(account.username) do
      nil ->
        GenServer.start_link(__MODULE__, account, name: via(account.username))

      wallets ->
        GenServer.start_link(__MODULE__, Map.put(account, :wallets, wallets),
          name: via(account.username)
        )
    end
  end

  @spec deposit(username :: String.t(), amount :: Decimal.t(), currency :: String.t()) ::
          term()
  def deposit(username, amount, currency) do
    GenServer.call(via(username), {:deposit, amount, currency})
  end

  @spec withdraw(username :: String.t(), amount :: Decimal.t(), currency :: String.t()) ::
          term()
  def withdraw(username, amount, currency) do
    GenServer.call(via(username), {:withdraw, amount, currency})
  end

  @spec get_balance_from_wallet(username :: String.t(), currency :: String.t()) ::
          number() | :no_wallet_with_given_currency
  def get_balance_from_wallet(username, currency) do
    GenServer.call(via(username), {:balance, currency})
  end

  defp update_account_cashbook(username, wallets) do
    Task.async(fn ->
      AccountCashbook.register_last_wallets(username, wallets)
    end)
  end

  defp via(username) do
    {:via, Registry, {AccountRegistry, username}}
  end

  # Callback function

  @impl true
  def init(account) do
    {:ok, account}
  end

  @impl true
  def handle_call({:deposit, amount, currency}, _from, account) do
    updated_account = Core.increase_account_wallet(account, amount, currency)
    updated_balance = Core.format_balance_from_wallet(updated_account, currency)

    update_account_cashbook(account.username, updated_account.wallets)

    {:reply, updated_balance, updated_account}
  end

  @impl true
  def handle_call({:withdraw, amount, currency}, _from, account) do
    case Core.decrease_account_wallet(account, amount, currency) do
      :not_enough_money = error ->
        {:reply, error, account}

      updated_account ->
        updated_balance = Core.format_balance_from_wallet(updated_account, currency)

        update_account_cashbook(account.username, updated_account.wallets)

        {:reply, updated_balance, updated_account}
    end
  end

  @impl true
  def handle_call({:balance, currency}, _from, account) do
    {:reply, Core.format_balance_from_wallet(account, currency), account}
  end

  @impl true
  def handle_info({_pid, :ok}, account) do
    Logger.info("Account Cashbook registry for #{account.username} update")
    {:noreply, account}
  end

  @impl true
  def handle_info({:DOWN, _pid, :process, _other_pid, :normal}, account) do
    {:noreply, account}
  end
end
