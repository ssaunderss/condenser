defmodule Condenser.AccessHistories do
  @moduledoc """
  A collection of queries for interacting with the
  `access_history` table.
  """
  import Ecto.Query

  require Logger

  alias Condenser.Repo
  alias Condenser.AccessHistory
  alias Condenser.URL

  @doc """
  Given a url_id and a client ip, inserts record
  into access_history table for analytics purposes.
  """
  @spec insert(non_neg_integer(), String.t()) :: {:ok, AccessHistory.t()} | {:error, term()}
  def insert(url_id, client_ip) do
    params = %{
      client_ip: client_ip,
      url_id: url_id
    }

    AccessHistory.changeset(%AccessHistory{}, params)
    |> Repo.insert()
  end

  @doc """
  Async wrapper for the insert/2 function, since this table
  is strictly used for analytical purposes this is a way to
  fire and forget access logs which leads to faster response times
  """
  @spec async_insert(non_neg_integer(), String.t()) :: {:ok, pid()}
  def async_insert(url_id, client_ip) do
    Task.start(fn ->
      try do
        insert(url_id, client_ip)
      rescue
        error ->
          Logger.error(
            "[access histories] could not successfully record client access, error: #{inspect(error)}"
          )
      end
    end)
  end

  # aggregate
  @doc """
  General purpose aggregation query for grabbing the
  top 100 hits by volume
  """
  @spec aggregate_access_history(non_neg_integer()) :: [map(), ...]
  def aggregate_access_history(num_records) do
    # first run the raw aggregation as a subquery
    sub =
      from a in AccessHistory,
        limit: ^num_records,
        group_by: a.url_id,
        select: %{
          url_id: a.url_id,
          count_hits: count(a.id)
        }

    main =
      from s in subquery(sub),
        join: u in URL,
        on: s.url_id == u.id,
        select: %{
          long_url: u.long_url,
          short_slug: u.short_slug,
          count_hits: s.count_hits
        },
        order_by: [desc: s.count_hits]

    Repo.all(main)
  end
end
