defmodule DemoWeb.UserLive.New do
  use Phoenix.LiveView

  alias DemoWeb.UserLive
  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts
  alias Demo.Accounts.User

  def mount(_session, socket) do
    {:ok,
     assign(assign_changeset(socket, Accounts.change_user(%User{})), %{
       count: 0,
       avatar_progress: 0,
       other_progress: 0,
       other: nil,
       avatar: nil
     })}
  end

  def render(assigns), do: DemoWeb.UserView.render("new.html", assigns)

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> Demo.Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:noreply, assign_changeset(socket, changeset)}
  end

  def handle_event("upload_progress", %{"user" => %{"avatar" => avatar}}, socket) do
    {:noreply, assign(socket, avatar_progress: round((avatar["uploaded"] / avatar["size"]) * 100))}
  end

  def handle_event("upload_progress", %{"user" => %{"other" => other}}, socket) do
    {:noreply, assign(socket, other_progress: round((other["uploaded"] / other["size"]) * 100))}
  end

  def handle_event("upload_progress", _, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:stop,
         socket
         |> put_flash(:info, "user created")
         |> redirect(to: Routes.live_path(socket, UserLive.Show, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign_changeset(socket, changeset)
        {:noreply, assign(socket, avatar: user_params["avatar"], other: user_params["other"])}
    end
  end

  def assign_changeset(socket, changeset) do
    form = Phoenix.HTML.Form.form_for(changeset, "#", [phx_change: :validate, phx_submit: :save, multipart: true])
    assign(socket, %{changeset: changeset, form: form})
  end
end
