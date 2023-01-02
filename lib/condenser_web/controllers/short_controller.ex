defmodule CondenserWeb.ShortController do
  use CondenserWeb, :controller

  require Logger

  alias Condenser.URLs
  alias CondenserWeb.Helpers

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  def shorten(conn, %{"long_url" => long_url} = _params) do
    with remote_ip <- Helpers.stringify_ip(conn.remote_ip) do
      case URLs.create_short_url(long_url, remote_ip) do
        {:ok, short_url} ->
          shortened_url = url(~p"/#{short_url.short_slug}")
          render(conn, :success, shortened_url: shortened_url, layout: false)

        {:error, error} ->
          conn
          |> put_flash(:error, "Error: #{inspect(error)}")
          |> redirect(to: ~p"/")
      end
    end
  end

  def forward(conn, %{"short_slug" => short_slug} = _params) do
    with remote_ip <- Helpers.stringify_ip(conn.remote_ip) do
      case URLs.get_by_short_slug(short_slug) do
        {:ok, url} ->
          Condenser.AccessHistories.async_insert(url.id, remote_ip)
          redirect(conn, external: url.long_url)

        {:error, error} ->
          conn
          |> put_flash(:error, "Error: #{inspect(error)}")
          |> redirect(to: ~p"/")
      end
    end
  end
end
