defmodule ExBanking.ServicesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias ExBanking.Operations
  alias ExBanking.Services

  describe "start_operation/2" do
    setup do
      initial_config = Application.get_env(:ex_banking, :services)[:max_operations_per_user]

      Application.put_env(:ex_banking, :services, max_operations_per_user: 5)

      on_exit(fn ->
        Application.put_env(:ex_banking, :services, max_operations_per_user: initial_config)
      end)
    end

    @tag :performance
    test "should start a operation (with a random delay between 2 and 4 milliSeconds) olny if the limit of 5 has not been reached" do
      [user, _] = fixture()

      {:ok, user_operation} = Operations.new_deposit(10, "USD")

      result =
        1..15
        |> Task.async_stream(fn _ ->
          case Services.start_operation(user, user_operation) do
            :ok ->
              random_delay(4)
              Services.finish_operation(user, user_operation)

            {:error, :too_many_requests_to_user} ->
              :error
          end
        end)
        |> Enum.map(fn {_, v} -> v end)

      Enum.count(result, &(&1 == :ok)) |> IO.inspect()

      Enum.count(result, &(&1 == :error)) |> IO.inspect()
    end
  end

  defp random_delay(n) do
    n
    |> :timer.seconds()
    |> :timer.sleep()
  end

  defp fixture do
    user_1 = Faker.Internet.user_name()
    user_2 = Faker.Internet.user_name()

    :ok = ExBanking.create_user(user_1)
    :ok = ExBanking.create_user(user_2)

    [user_1, user_2]
  end
end
