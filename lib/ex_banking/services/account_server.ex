defmodule ExBanking.Services.AccountServer do
  @moduledoc false

  use GenServer

  alias ExBanking.Services.AccountRegistry

  # Public functions

  def start_link(account) do
    GenServer.start_link(__MODULE__, account, name: via(account.username))
  end

  def via(username) do
    {:via, Registry, {AccountRegistry, username}}
  end

  # Callback function

  def init(account) do
    {:ok, account}
  end
end
