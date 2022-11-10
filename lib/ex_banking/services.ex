defmodule ExBanking.Services do
  @moduledoc false

  alias ExBanking.Core.Account
  alias ExBanking.Services.{AccountCreator, AccountRegistry}

  require Logger

  @spec create_account_service(account :: Account.t()) ::
          :ok | {:error, :user_already_exists}
  def create_account_service(%Account{username: username} = account) do
    if account_service_already_started?(username) do
      {:error, :user_already_exists}
    else
      case AccountCreator.start_service(account) do
        {:ok, _pid} ->
          :ok

        {:error, reason} ->
          Logger.error("Error on AccountCreator service: #{inspect(reason)}")
      end
    end
  end

  defp account_service_already_started?(user) do
    case Registry.lookup(AccountRegistry, user) do
      [] ->
        false

      [{_pid, nil}] ->
        true
    end
  end
end
