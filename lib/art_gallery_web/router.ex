defmodule ArtGalleryWeb.Router do
  use ArtGalleryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ArtGalleryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ArtGalleryWeb do
    pipe_through :browser

    live "/", GalleryLive.Index, :index
    live "/galleries", GalleryLive.Index, :index
    live "/galleries/new", GalleryLive.Index, :new
    live "/galleries/:id/edit", GalleryLive.Index, :edit
    live "/galleries/:id", GalleryLive.Show, :show
    live "/galleries/:id/show/edit", GalleryLive.Show, :edit
  end

  scope "/galleries", ArtGalleryWeb, as: :galleries do
    pipe_through :browser


  end
  # Other scopes may use custom stacks.
  # scope "/api", ArtGalleryWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:art_gallery, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ArtGalleryWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
