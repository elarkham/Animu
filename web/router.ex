defmodule Animu.Router do
  use Animu.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/api", Animu do
    pipe_through :api

    scope "/v1" do
      post "/register", RegistrationController, :create

      post   "/session", SessionController, :create
      delete "/session", SessionController, :delete

      get "/current_user", CurrentUserController, :show

    end
  end

  scope "/", Animu do
    pipe_through :browser # Use the default browser stack

    get "*path", PageController, :index
  end

end
