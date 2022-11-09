defmodule ExBanking.Core.Account do
  alias ExBanking.Core.Wallet

  defstruct [:username, :wallets]

  @type t :: %__MODULE__{
          username: String.t(),
          wallets: list(Wallet.t()) | Wallet.t()
        }

  def new(username) do
    %__MODULE__{
      username: username,
      wallets: Wallet.new()
    }
  end
end
