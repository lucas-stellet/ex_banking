defmodule ExBanking.Services.AccountOperations do
  @moduledoc false
  use Agent

  alias ExBanking.Services.AccountRegistry

  defstruct running: [], finished: []

  def start_link(username) do
    Agent.start_link(fn -> %__MODULE__{} end, name: via(username))
  end

  def via(username) do
    key = username <> "_operations"

    {:via, Registry, {AccountRegistry, key}}
  end
end
