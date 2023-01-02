defmodule Condenser.Repo.Migrations.CreateAccessHistory do
  use Ecto.Migration

  def change do
    create table(:access_history) do
      add :client_ip, :string
      add :url_id, references(:urls, on_delete: :nothing)

      timestamps()
    end

    create index(:access_history, [:url_id])
  end
end
