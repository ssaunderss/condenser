defmodule CondenserWeb.StatsControllerTest do
  use CondenserWeb.ConnCase, async: true

  require Logger
  alias Condenser.AccessHistories
  alias Condenser.URLs
  alias CondenserWeb.Helpers

  setup do
    client_ip =
      {127, 0, 0, 1}
      |> Helpers.stringify_ip()

    valid_url_1 = "https://austinsaunders.io"
    valid_url_2 = "https://www.google.com"
    {:ok, url_1} = URLs.create_short_url(valid_url_1, client_ip)
    {:ok, url_2} = URLs.create_short_url(valid_url_2, client_ip)
    AccessHistories.insert(url_1.id, client_ip)
    AccessHistories.insert(url_1.id, client_ip)
    AccessHistories.insert(url_2.id, client_ip)

    %{url_1: url_1, url_2: url_2}
  end

  describe "GET /s/stats" do
    test "successfully loads and renders page", %{conn: conn, url_1: url_1, url_2: url_2} do
      conn = get(conn, ~p"/s/stats")
      assert html_response(conn, 200) =~ url_1.long_url
      assert html_response(conn, 200) =~ url_2.long_url
    end
  end

  describe "GET /s/csv" do
    test "successfully downloads file", %{conn: conn, url_1: url_1, url_2: url_2} do
      conn = get(conn, ~p"/s/csv")
      assert conn.resp_body =~ url_1.long_url
      assert conn.resp_body =~ url_2.long_url
    end
  end
end
