defmodule CondenserWeb.Router do
  use CondenserWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CondenserWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CondenserWeb do
    pipe_through :browser

    get "/", ShortController, :home
    get "/:short_slug", ShortController, :forward

    get "/s/stats", StatsController, :index
    post "/s/shorten", ShortController, :shorten
    get "/s/csv", StatsController, :csv
  end
end
