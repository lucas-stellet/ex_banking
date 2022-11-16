defmodule ExBanking.Operations do
  @moduledoc false
  use GenServer

  # Public functions

  @spec start_link(initial_args :: any()) :: GenServer.on_start()
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec start_operation(username :: String.t()) ::
          :ok | {:error, :too_many_requests_to_user}
  def start_operation(username) do
    GenServer.call(__MODULE__, {:start_operation, username})
  end

  @spec finish_operation(username :: String.t()) ::
          :ok
  def finish_operation(username) do
    GenServer.call(__MODULE__, {:finish_operation, username})
  end

  # Callback functions

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call({:start_operation, username}, _from, operations) do
    current_counter = Map.get(operations, username, 0)
    new_counter = current_counter + 1

    if current_counter >= max_operations_per_user() do
      {:reply, {:error, :too_many_requests_to_user}, operations}
    else
      {:reply, :ok, Map.put(operations, username, new_counter)}
    end
  end

  @impl true
  def handle_call({:finish_operation, username}, _from, operations) do
    {:reply, :ok, Map.update(operations, username, 0, &(&1 - 1))}
  end

  defp max_operations_per_user do
    Application.get_env(:ex_banking, __MODULE__)[
      :max_operations_per_user
    ]
  end
end
