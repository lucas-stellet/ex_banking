defmodule ExBanking.Services.AccountSupervisor do
  @moduledoc false

  use Supervisor, restart: :transient

  alias ExBanking.Core.Account
  alias ExBanking.Services.{AccountOperations, AccountServer}

  @spec start_link(account :: Account.t()) :: GenServer.on_start()
  def start_link(account) do
    Supervisor.start_link(__MODULE__, account)
  end

  @impl true
  def init(account) do
    children = [
      {AccountOperations, account.username},
      {AccountServer, account}
    ]

    options = [
      strategy: :one_for_one
    ]

    Supervisor.init(children, options)
  end
end
