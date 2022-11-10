defmodule ExBanking.Services.AccountSupervisor do
  @moduledoc false

  use Supervisor, restart: :temporary

  alias ExBanking.Services.{AccountOperations, AccountServer}

  def start_link(account) do
    Supervisor.start_link(__MODULE__, account)
  end

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
