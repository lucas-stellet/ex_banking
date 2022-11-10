defmodule ExBankingTest do
  @moduledoc false

  use ExUnit.Case

  describe "create_user" do
    test "should returns :ok when the user is created" do
      assert :ok = ExBanking.create_user("user")
    end

    test "should returns {:error, :wrong_arguments} when the given param not is a string" do
      assert {:error, :wrong_arguments} == ExBanking.create_user(123)
    end

    test "should returns {:error, :user_already_exists} when the user already was created" do
      user = "user"

      :ok = ExBanking.create_user(user)

      assert {:error, :user_already_exists} == ExBanking.create_user(user)
    end
  end
end
