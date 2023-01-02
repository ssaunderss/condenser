defmodule CondenserWeb.ShortControllerTest do
  use CondenserWeb.ConnCase, async: true

  alias CondenserWeb.Helpers
  alias Condenser.URLs

  setup do
    client_ip =
      {127, 0, 0, 1}
      |> Helpers.stringify_ip()

    valid_url = "https://austinsaunders.io"
    {:ok, url} = URLs.create_short_url(valid_url, client_ip)

    %{url: url}
  end

  describe "POST /s/shorten" do
    test "valid long url returns short url", %{conn: conn} do
      conn = post(conn, ~p"/s/shorten", %{"long_url" => "https://austinsaunders.io"})
      assert html_response(conn, 200) =~ "Your shortened url:"
    end

    test "invalid long url redirects back to home page", %{conn: conn} do
      conn = post(conn, ~p"/s/shorten", %{"long_url" => "austinsaunders.io"})
      assert redirected_to(conn, 302) =~ "/"
    end
  end

  describe "GET /:short_slug" do
    test "valid short slug redirects to target long url", %{conn: conn, url: url} do
      conn = get(conn, ~p"/#{url.short_slug}")
      assert redirected_to(conn, 302) =~ url.long_url
    end

    test "invalid short slug redirects to home page", %{conn: conn} do
      conn = get(conn, ~p"/corndog")
      assert redirected_to(conn, 302) =~ ~p"/"
    end
  end
end
