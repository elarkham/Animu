defmodule Animu.Web.Router do
  use Animu.Web, :router

  #pipeline :browser do
  #  plug :accepts, ["html"]
  #  plug :fetch_session
  #  plug :fetch_flash
  #  plug :protect_from_forgery
  #  plug :put_secure_browser_headers
  #end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/api", Animu.Web do
    pipe_through :api

    # Latest API
    resources "/users", UserController, except: [:new, :edit]
    get "/current_user", CurrentUserController, :show

    post   "/session", SessionController, :create
    delete "/session", SessionController, :delete

    post   "/rpc", RpcController, :rpc

    # Union of franchise and series
    get "/media", MediaController, :index

    # /franchises/:id/series/:id/episode/:id
    resources "/franchises", FranchiseController, except: [:new, :edit] do
      resources "/series", SeriesController, except: [:new, :edit] do
        resources "/episodes", EpisodeController, except: [:new, :edit]
      end
    end

    # /series/:id/episodes/:id
    resources "/series", SeriesController, except: [:new, :edit] do
      resources "/episodes", EpisodeController, except: [:new, :edit]
    end

    resources "/episodes", EpisodeController, except: [:new, :edit]

    # Versioned API
    scope "/v1" do
      resources "/users", UserController, except: [:new, :edit]
      get "/current_user", CurrentUserController, :show

      post   "/session", SessionController, :create
      delete "/session", SessionController, :delete

      post   "/rpc", RpcController, :rpc

      resources "/franchises", FranchiseController, except: [:new, :edit]
      resources "/series", SeriesController, except: [:new, :edit]
      resources "/episodes", EpisodeController, except: [:new, :edit]
    end

  end


  #scope "/", Animu.Web do
  #  pipe_through :browser # Use the default browser stack

  #  get "/*path", PageController, :index
  #end
end
