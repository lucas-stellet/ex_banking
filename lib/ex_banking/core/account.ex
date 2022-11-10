defmodule ExBanking.Core.Account do
  alias ExBanking.Core.Wallet

  defstruct [:username, :wallets]

  @type t :: %__MODULE__{
          username: String.t(),
          wallets: list(Wallet.t()) | Wallet.t()
        }

  @spec new(username :: String.t()) :: t() | :wrong_arguments
  def new(username) do
    if is_valid_username?(username) do
      %__MODULE__{
        username: username,
        wallets: Wallet.new()
      }
    else
      :wrong_arguments
    end
  end

  defp is_valid_username?(username),
    do: is_binary(username) and true
end
