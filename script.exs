[{"lucas", "noah"}, {"noah", "tatiane"}, {"tatiane", "lilly"}, {"lilly", "lucas"}]
|> Task.async_stream(fn {sender, receiver} ->
  ExBanking.send(sender, receiver, 10, "USD")
  ExBanking.send(receiver, sender, 20, "USD")

  b1 = {ExBanking.get_balance(sender, "USD"), ExBanking.get_balance(receiver, "USD")}

  ExBanking.send(sender, receiver, 20, "USD")
  ExBanking.send(receiver, sender, 10, "USD")

  b2 = {ExBanking.get_balance(sender, "USD"), ExBanking.get_balance(receiver, "USD")}

  {b1, b2}
end
)
|> Enum.map(fn {_, v} -> v end)


["lucas", "noah", "tatiane", "lilly"]
|> Task.async_stream(fn name ->
  ExBanking.create_user(name)
  ExBanking.deposit(name, 100, "USD")
end)
|> Enum.map(fn {_, v} -> v end)