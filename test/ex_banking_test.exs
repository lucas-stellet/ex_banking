defmodule ExBankingTest do
  @moduledoc false

  use ExUnit.Case

  describe "create_user" do
    test "should returns :ok when the user is created" do
      assert :ok = ExBanking.create_user("thor")
    end

    test "should returns {:error, :wrong_arguments} when the given param not is a string" do
      assert {:error, :wrong_arguments} == ExBanking.create_user(123)
    end

    test "should returns {:error, :user_already_exists} when the user already was created" do
      user = "thor"

      :ok = ExBanking.create_user(user)

      assert {:error, :user_already_exists} == ExBanking.create_user(user)
    end
  end

  describe "deposit" do
    test "should returns {:ok, 10.0} when the deposit happens correctly" do
      user = create_user()

      assert {:ok, 10.0} = ExBanking.deposit(user, 10, "USD")
    end

    test "should returns {:error, :wrong_arguments} when the given amount is not a number" do
      user = create_user()

      assert {:error, :wrong_arguments} = ExBanking.deposit(user, "10", "USD")
    end

    test "should returns {:error, :wrong_arguments} when the given currency is not a string" do
      user = create_user()

      assert {:error, :wrong_arguments} = ExBanking.deposit(user, 10, 10)
    end

    test "should returns {:error, :user_does_not_exist} when the given user does not exist" do
      assert {:error, :user_does_not_exist} = ExBanking.deposit("user", 10, 10)
    end
  end

  describe "withdraw" do
    test "should returns {:ok, 5.0} when the withdraw happens correctly" do
      user = create_user()

      ExBanking.deposit(user, 100, "USD")

      assert {:ok, 5.0} = ExBanking.withdraw(user, 95.0, "USD")
    end

    test "should returns {:error, :wrong_arguments} when the given amount is not a number" do
      user = create_user()

      assert {:error, :wrong_arguments} = ExBanking.withdraw(user, "10", "USD")
    end

    test "should returns {:error, :wrong_arguments} when the given currency is not a string" do
      user = create_user()

      assert {:error, :wrong_arguments} = ExBanking.withdraw(user, 10, 10)
    end

    test "should returns {:error, :user_does_not_exist} when the given user does not exist" do
      assert {:error, :user_does_not_exist} = ExBanking.withdraw("user", 10, "USD")
    end

    test "should returns {:error, :not_enough_money} when there is not enough money to withdraw" do
      user = create_user()

      ExBanking.deposit(user, 10, "USD")

      assert {:error, :not_enough_money} = ExBanking.withdraw(user, 10.5, "USD")
    end

    test "should returns {:error, :not_enough_money} when there is no wallet" do
      user = create_user()

      assert {:error, :not_enough_money} = ExBanking.withdraw(user, 10.5, "USD")
    end
  end

  defp create_user(user \\ "thor") do
    :ok = ExBanking.create_user(user)

    user
  end
end
