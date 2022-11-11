defmodule ExBanking.Services.AccountOperations do
  @moduledoc false
  use GenServer

  alias ExBanking.Operations
  alias ExBanking.Services.AccountRegistry

  defstruct running: [], finished: []

  # Public functions

  @spec start_link(username :: String.t()) :: GenServer.on_start()
  def start_link(username) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: via(username))
  end

  @spec start_operation(username :: String.t(), operation :: Operations.t()) ::
          :ok | :too_many_requests_to_user
  def start_operation(username, operation) do
    GenServer.call(via(username), {:start_operation, operation})
  end

  @spec finish_operation(username :: String.t(), operation :: Operations.t()) ::
          :ok
  def finish_operation(username, operation) do
    GenServer.cast(via(username), {:finish_operation, operation})
  end

  @spec via(username :: String.t()) :: tuple()
  def via(username) do
    key = username <> "_operations"

    {:via, Registry, {AccountRegistry, key}}
  end

  # Callback functions

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:count_running_operations, _from, operations) do
    {:reply, operations.running, operations}
  end

  @impl true
  def handle_call({:start_operation, operation}, _from, operations) do
    if Enum.count(operations.running) >= max_operations_per_user() do
      {:reply, :too_many_requests_to_user, operations}
    else
      operations = %__MODULE__{operations | running: [operation | operations.running]}

      {:reply, :ok, operations}
    end
  end

  @impl true
  def handle_cast({:finish_operation, operation}, operations) do
    operations = %__MODULE__{
      running: remove_operation_from_running(operations.running, operation),
      finished: [operation | operations.finished]
    }

    {:noreply, operations}
  end

  defp remove_operation_from_running(running_operations, operation),
    do: Enum.reject(running_operations, &(&1.id == operation.id))

  defp max_operations_per_user do
    Application.get_env(:ex_banking, :services)[
      :max_operations_per_user
    ]
  end
end
