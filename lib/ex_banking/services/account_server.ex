defmodule ExBanking.Services.AccountServer do
  @moduledoc false

  use GenServer

  alias ExBanking.Services.AccountRegistry

  alias ExBanking.Core

  # Public functions

  def start_link(account) do
    GenServer.start_link(__MODULE__, account, name: via(account.username))
  end

  def deposit(username, amount, currency) do
    GenServer.call(via(username), {:deposit, amount, currency})
  end

  defp via(username) do
    {:via, Registry, {AccountRegistry, username}}
  end

  # Callback function

  def init(account) do
    {:ok, account}
  end

  def handle_call({:deposit, amount, currency}, _from, account) do
    updated_account = Core.increase_account_wallet(account, amount, currency)
    updated_balance = Core.format_balance_from_wallet(updated_account, currency)

    {:reply, updated_balance, updated_account}
  end
end
