defmodule ArtGalleryWeb.GalleryLive.FormComponent do
  use ArtGalleryWeb, :live_component

  alias ArtGallery.Galleries

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage gallery records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="gallery-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:author]} type="text" label="Author" />
        <.live_file_input upload={@uploads.image} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Gallery</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{gallery: gallery} = assigns, socket) do
    changeset = Galleries.change_gallery(gallery)
    form_data = to_form(changeset)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:form, form_data)
     |> assign(:uploaded_files, [])
     |> allow_upload(:image, accept: ~w(.jpg .png .jpeg), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"gallery" => gallery_params}, socket) do
    changeset =
      socket.assigns.gallery
      |> Galleries.change_gallery(gallery_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("save", %{"gallery" => gallery_params}, socket) do
    # Upload image file
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:art_gallery), "static", "uploads", Path.basename(path)])

        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    # Extract uploaded image URL
    image_url = List.first(uploaded_files)

    # Prepare gallery params with the image URL
    gallery_params_with_image = Map.put(gallery_params, "art_image", image_url)

    # Save gallery to the database
    case socket.assigns.action do
      :edit ->
        save_gallery(socket, :edit, gallery_params_with_image)
      :new ->
        save_gallery(socket, :new, gallery_params_with_image)
    end
  end

  defp save_gallery(socket, :edit, gallery_params) do
    case Galleries.update_gallery(socket.assigns.gallery, gallery_params) do
      {:ok, gallery} ->
        notify_parent({:saved, gallery})

        {:noreply,
         socket
         |> put_flash(:info, "Gallery updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_gallery(socket, :new, gallery_params) do
    case Galleries.create_gallery(gallery_params) do
      {:ok, gallery} ->
        notify_parent({:saved, gallery})

        {:noreply,
         socket
         |> put_flash(:info, "Gallery created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
