defmodule Animu.Web.Router do
  use Animu.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Animu.Auth.Pipeline
  end

  ## Latest API

  # No Auth
  scope "/api", Animu.Web do
    pipe_through :api

    post   "/session", SessionController, :create
  end

  scope "/api", Animu.Web do
    pipe_through [:api, :auth]

    resources "/users", UserController, except: [:new, :edit]
    get "/current_user", CurrentUserController, :show

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
  end

  ## Versioned API

  # No Auth
  scope "/api/v1", Animu.Web do
    pipe_through :api

    post   "/session", SessionController, :create
  end

  scope "/api/v1", Animu.Web do
    pipe_through [:api, :auth]

    resources "/users", UserController, except: [:new, :edit]
    get "/current_user", CurrentUserController, :show

    post   "/rpc", RpcController, :rpc

    resources "/franchises", FranchiseController, except: [:new, :edit]
    resources "/series", SeriesController, except: [:new, :edit]
    resources "/episodes", EpisodeController, except: [:new, :edit]
  end
end
