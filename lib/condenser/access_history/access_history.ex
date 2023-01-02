defmodule Condenser.AccessHistory do
  @moduledoc """
  Table for Recording Client Access History
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Condenser.URL

  @fields [:client_ip, :url_id]

  schema "access_history" do
    field :client_ip, :string

    belongs_to :urls, URL, foreign_key: :url_id

    timestamps()
  end

  @doc false
  def changeset(access_history, attrs) do
    access_history
    |> cast(attrs, @fields)
    |> validate_required([:client_ip])
  end
end
