defmodule ExBanking.Services.AccountOperations do
  @moduledoc false
  use Agent

  alias ExBanking.Operations
  alias ExBanking.Services.AccountRegistry

  defstruct running: [], finished: []

  def start_link(username) do
    Agent.start_link(fn -> %__MODULE__{} end, name: via(username))
  end

  @spec start_operation(username :: String.t(), operation :: Operations.t()) ::
          :ok | :too_many_requests_to_user
  def start_operation(username, operation) do
    if count_running_operation(username) > 10 do
      :too_many_requests_to_user
    else
      Agent.update(via(username), fn operations ->
        %__MODULE__{operations | running: [operation | operations.running]}
      end)
    end
  end

  @spec finish_operation(username :: String.t(), operation :: Operations.t()) ::
          :ok
  def finish_operation(username, operation) do
    Agent.update(via(username), fn operations ->
      updated_running_operations = remove_operation_from_running(operations.running, operation)

      %__MODULE__{
        running: updated_running_operations,
        finished: [operation | operations.finished]
      }
    end)

    :ok
  end

  defp remove_operation_from_running(running_operations, operation),
    do: Enum.reject(running_operations, &(&1.id == operation.id))

  defp count_running_operation(username) do
    Agent.get(via(username), &Enum.count(&1.running))
  end

  def via(username) do
    key = username <> "_operations"

    {:via, Registry, {AccountRegistry, key}}
  end
end
