defmodule Condenser.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :long_url, :string, size: 2048
      add :short_slug, :string
      add :creator_ip, :string

      timestamps()
    end

    create unique_index(:urls, [:short_slug])
    create unique_index(:urls, [:long_url])
  end
end
