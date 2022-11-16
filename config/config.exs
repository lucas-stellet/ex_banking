import Config

config :ex_banking, ExBanking.Operations, max_operations_per_user: 10

import_config "#{config_env()}.exs"
