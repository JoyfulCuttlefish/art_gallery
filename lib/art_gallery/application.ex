defmodule ArtGallery.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ArtGalleryWeb.Telemetry,
      ArtGallery.Repo,
      {DNSCluster, query: Application.get_env(:art_gallery, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ArtGallery.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ArtGallery.Finch},
      # Start a worker by calling: ArtGallery.Worker.start_link(arg)
      # {ArtGallery.Worker, arg},
      # Start to serve requests, typically the last entry
      ArtGalleryWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ArtGallery.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ArtGalleryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
