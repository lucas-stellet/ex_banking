defmodule ExBanking.Services.AccountServer do
  @moduledoc false

  use GenServer

  alias ExBanking.Services.AccountRegistry

  alias ExBanking.Core
  alias ExBanking.Core.Account

  # Public functions

  @spec start_link(account :: Account.t()) :: GenServer.on_start()
  def start_link(account) do
    GenServer.start_link(__MODULE__, account, name: via(account.username))
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

    {:reply, updated_balance, updated_account}
  end

  @impl true
  def handle_call({:withdraw, amount, currency}, _from, account) do
    case Core.decrease_account_wallet(account, amount, currency) do
      :not_enough_money = error ->
        {:reply, error, account}

      updated_account ->
        updated_balance = Core.format_balance_from_wallet(updated_account, currency)

        {:reply, updated_balance, updated_account}
    end
  end
end
