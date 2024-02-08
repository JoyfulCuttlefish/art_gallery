defmodule ArtGalleryWeb.GalleryLive.Index do
  use ArtGalleryWeb, :live_view

  alias ArtGallery.Galleries
  alias ArtGallery.Galleries.Gallery

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :galleries, Galleries.list_galleries())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Gallery")
    |> assign(:gallery, Galleries.get_gallery!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Gallery")
    |> assign(:gallery, %Gallery{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Galleries")
    |> assign(:gallery, nil)
  end

  @impl true
  def handle_info({ArtGalleryWeb.GalleryLive.FormComponent, {:saved, gallery}}, socket) do
    {:noreply, stream_insert(socket, :galleries, gallery)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    gallery = Galleries.get_gallery!(id)
    {:ok, _} = Galleries.delete_gallery(gallery)

    {:noreply, stream_delete(socket, :galleries, gallery)}
  end
end
