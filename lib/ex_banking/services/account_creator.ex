defmodule ExBanking.Services.AccountCreator do
  @moduledoc false

  use DynamicSupervisor

  alias ExBanking.Core.Account
  alias ExBanking.Services.{AccountCreators, AccountSupervisor}

  require Logger

  @spec start_service(account :: Account.t()) :: DynamicSupervisor.on_start_child()
  def start_service(account) do
    DynamicSupervisor.start_child(
      {:via, PartitionSupervisor, {AccountCreators, self()}},
      {AccountSupervisor, account}
    )
  end

  # coveralls-ignore-start

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # coveralls-ignore-stop
end
