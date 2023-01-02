defmodule Condenser.AccessHistoriesTest do
  use ExUnit.Case, async: true
  use Condenser.DataCase

  alias Condenser.AccessHistory
  alias Condenser.AccessHistories
  alias Condenser.URLs
  alias CondenserWeb.Helpers

  setup do
    client_ip =
      {127, 0, 0, 1}
      |> Helpers.stringify_ip()

    valid_url_1 = "https://austinsaunders.io"
    valid_url_2 = "https://www.google.com"
    assert {:ok, url_1} = URLs.create_short_url(valid_url_1, client_ip)
    assert {:ok, url_2} = URLs.create_short_url(valid_url_2, client_ip)

    %{
      client_ip: client_ip,
      url_1: url_1,
      url_2: url_2
    }
  end

  describe "[insert/2]" do
    test "correct inputs insert successfully", %{client_ip: client_ip, url_1: url} do
      assert {:ok, %AccessHistory{}} = AccessHistories.insert(url.id, client_ip)
    end

    test "unknown id returns error", %{client_ip: client_ip} do
      assert_raise Ecto.ConstraintError, fn ->
        AccessHistories.insert(9000, client_ip)
      end
    end
  end

  describe "[aggregate_access_history/1]" do
    test "no access history returns empty list" do
      assert [] == AccessHistories.aggregate_access_history(100)
    end

    test "returns correct aggregation when data present", %{
      client_ip: client_ip,
      url_1: url_1,
      url_2: url_2
    } do
      assert {:ok, %AccessHistory{}} = AccessHistories.insert(url_1.id, client_ip)
      assert {:ok, %AccessHistory{}} = AccessHistories.insert(url_1.id, client_ip)
      assert {:ok, %AccessHistory{}} = AccessHistories.insert(url_2.id, client_ip)
      assert [stat1, stat2] = AccessHistories.aggregate_access_history(100)
      assert stat1.count_hits == 2
      assert stat2.count_hits == 1
    end
  end
end
