defmodule Condenser.URL do
  @moduledoc """
  Table for recording short url to long url mappings
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Condenser.AccessHistory

  @fields [:long_url, :short_slug, :creator_ip]

  schema "urls" do
    field :creator_ip, :string
    field :long_url, :string
    field :short_slug, :string

    has_many :access_histories, AccessHistory

    timestamps()
  end

  @doc false
  def changeset(url, attrs) do
    url
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:short_slug)
    |> unique_constraint(:long_url)
  end
end
