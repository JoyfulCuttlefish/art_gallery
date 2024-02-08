defmodule ArtGallery.GalleriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ArtGallery.Galleries` context.
  """

  @doc """
  Generate a gallery.
  """
  def gallery_fixture(attrs \\ %{}) do
    {:ok, gallery} =
      attrs
      |> Enum.into(%{
        author: "some author",
        name: "some name"
      })
      |> ArtGallery.Galleries.create_gallery()

    gallery
  end
end
