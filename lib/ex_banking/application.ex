defmodule ExBanking.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ExBanking.Services.AccountRegistry},
      {PartitionSupervisor,
       child_spec: DynamicSupervisor, name: ExBanking.Services.AccountCreators},
      {Cachex, name: :account_cashbook}
    ]

    opts = [strategy: :one_for_one, name: ExBanking.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
