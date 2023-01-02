defmodule Condenser.Repo do
  use Ecto.Repo,
    otp_app: :condenser,
    adapter: Ecto.Adapters.Postgres
end
