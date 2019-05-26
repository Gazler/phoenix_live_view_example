defmodule DemoWeb.UserLive.New do
  use Phoenix.LiveView

  alias DemoWeb.UserLive
  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts
  alias Demo.Accounts.User

  def mount(_session, socket) do
    {:ok,
     assign(socket, %{
       count: 0,
       avatar_progress: 0,
       other_progress: 0,
       changeset: Accounts.change_user(%User{})
     })}
  end

  def render(assigns), do: DemoWeb.UserView.render("new.html", assigns)

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> Demo.Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
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
        {:noreply, assign(socket, changeset: changeset, avatar: user_params["avatar"], other: user_params["other"])}
    end
  end
end
