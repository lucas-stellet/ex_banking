defmodule ExBanking.Repository do
  @moduledoc false

  @cachex_name :accounts

  defdelegate update(key, value, db \\ @cachex_name), to: __MODULE__, as: :insert

  defdelegate update!(key, value, db \\ @cachex_name), to: __MODULE__, as: :insert!

  def insert(key, value, db \\ @cachex_name) do
    case Cachex.put(db, key, value) do
      {:ok, true} ->
        :ok

      error ->
        error
    end
  end

  def insert!(key, value, db \\ @cachex_name) do
    Cachex.put!(db, key, value)
  end

  def get(key, db \\ @cachex_name) do
    case Cachex.get(db, key) do
      {:ok, nil} -> nil
      {:ok, value} -> value
    end
  end

  def get!(key, db \\ @cachex_name) do
    Cachex.get!(db, key)
  end

  def exists?(key, db \\ @cachex_name) do
    case Cachex.exists?(db, key) do
      {:ok, true} ->
        true

      {:ok, false} ->
        false
    end
  end

  @spec transaction(keys :: list(binary()) | binary(), function :: function()) ::
          {:ok, any()} | {:error, any()}
  def transaction(keys, function) when not is_list(keys) do
    Cachex.transaction(@cachex_name, List.wrap(keys), fn cache ->
      function.(cache)
    end)
  end

  def transaction(keys, function) do
    Cachex.transaction(@cachex_name, keys, fn cache ->
      function.(cache)
    end)
  end
end
