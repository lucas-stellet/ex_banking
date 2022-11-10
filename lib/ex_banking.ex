defmodule ExBanking do
  @moduledoc false

  alias ExBanking.Core
  alias ExBanking.Services

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    with {:ok, account} <- Core.create_account(user),
         :ok <- Services.create_account_service(account) do
      :ok
    else
      error ->
        error
    end
  end
end
