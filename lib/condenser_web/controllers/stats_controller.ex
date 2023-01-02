defmodule CondenserWeb.StatsController do
  use CondenserWeb, :controller

  alias Condenser.AccessHistories
  alias Condenser.CsvHelpers

  def index(conn, _params) do
    # this is just hardcoded to grab top 100 by volume
    data =
      top_hits_limit()
      |> AccessHistories.aggregate_access_history()

    render(conn, "stats.html", data: data)
  end

  # td: These CSVs should really live in an S3 bucket or somewhere else
  def csv(conn, _params) do
    uuid = Ecto.UUID.autogenerate()

    top_hits_limit()
    |> AccessHistories.aggregate_access_history()
    |> CsvHelpers.to_csv("priv/csvs/top-hits-#{uuid}.csv")

    path = Application.app_dir(:condenser, "priv/csvs/top-hits-#{uuid}.csv")
    send_download(conn, {:file, path})
  end

  defp top_hits_limit(), do: Application.fetch_env!(:condenser, :top_hits_limit)
end
