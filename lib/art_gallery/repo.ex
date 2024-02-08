defmodule ArtGallery.Repo do
  use Ecto.Repo,
    otp_app: :art_gallery,
    adapter: Ecto.Adapters.Postgres
end
