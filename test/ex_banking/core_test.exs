defmodule ExBanking.CoreTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias ExBanking.Core

  describe "create_account/1" do
    test "should return an account with given username as string" do
      username = Faker.Internet.user_name()

      assert {:ok, %Core.Account{username: ^username}} = Core.create_account(username)
    end

    test "should return {:error, :wrong_arguments} when the given username is not a string" do
      assert {:error, :wrong_arguments} = Core.create_account(10)
    end
  end
end
