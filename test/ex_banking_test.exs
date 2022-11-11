defmodule ExBankingTest do
  @moduledoc false

  use ExUnit.Case, async: true

  describe "create_user" do
    test "should returns :ok when the user is created" do
      user = Faker.Internet.user_name()

      assert :ok = ExBanking.create_user(user)
    end

    test "should returns {:error, :wrong_arguments} when the given param not is a string" do
      assert {:error, :wrong_arguments} == ExBanking.create_user(123)
    end

    test "should returns {:error, :user_already_exists} when the user already was created" do
      user = Faker.Internet.user_name()

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

  describe "get_balance" do
    test "should returns {:ok, 10.0} when return the balance correctly" do
      user = create_user()

      assert {:ok, 10.0} = ExBanking.deposit(user, 10, "USD")

      assert {:ok, 10.0} = ExBanking.get_balance(user, "USD")
    end

    test "should returns {:error, :wrong_arguments} when there is no wallet from given currency" do
      user = create_user()

      assert {:error, :wrong_arguments} = ExBanking.get_balance(user, "USD")
    end

    test "should returns {:error, :user_does_not_exist} when the given user does not exist" do
      assert {:error, :user_does_not_exist} = ExBanking.get_balance("user", "USD")
    end
  end

  describe "send" do
    test "should returns {:ok, 0.0, 10.0} when sender send money to receiver successfully" do
      [sender, receiver] = create_sender_and_receiver()

      {:ok, 10.0} = ExBanking.deposit(sender, 10, "USD")

      assert {:ok, 0.0, 10.0} = ExBanking.send(sender, receiver, 10, "USD")
    end

    test "should returns {:error, not_enough_money} when sender tries to send money to receiver but he does not has enough money" do
      [sender, receiver] = create_sender_and_receiver()

      {:ok, 5.0} = ExBanking.deposit(sender, 5, "USD")

      assert {:error, :not_enough_money} = ExBanking.send(sender, receiver, 10, "USD")
    end

    test "should returns {:error, not_enough_money} when sender tries to send money to receiver from a nonexistent wallet " do
      [sender, receiver] = create_sender_and_receiver()

      assert {:error, :not_enough_money} = ExBanking.send(sender, receiver, 10, "USD")
    end

    test "should returns {:error, :sender_does_not_exist} when the sender user does not exist" do
      receiver = create_user()

      assert {:error, :sender_does_not_exist} = ExBanking.send("uswe", receiver, 10, "USD")
    end

    test "should returns {:error, :receiver_does_not_exist} when the receiver user does not exist" do
      sender = create_user()

      assert {:error, :receiver_does_not_exist} = ExBanking.send(sender, "user", 10, "USD")
    end

    test "should returns {:error, :wrong_arguments} when the given amount is not a number" do
      [sender, receiver] = create_sender_and_receiver()

      assert {:error, :wrong_arguments} = ExBanking.send(sender, receiver, "ten", "USD")
    end

    test "should returns {:error, :wrong_arguments} when the given currency is not a string" do
      [sender, receiver] = create_sender_and_receiver()

      assert {:error, :wrong_arguments} = ExBanking.send(sender, receiver, 10, :dollars)
    end
  end

  defp create_user do
    user = Faker.Internet.user_name()

    :ok = ExBanking.create_user(user)

    user
  end

  defp create_sender_and_receiver, do: [create_user(), create_user()]
end
