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

    # Union of franchise and anime
    get "/media", MediaController, :index

    # /franchises/:id/anime/:num/episode/:num
    resources "/media/franchises", FranchiseController, except: [:new, :edit] do
      resources "/anime", AnimeController, param: "num", except: [:new, :edit] do
        resources "/episodes", EpisodeController, param: "num", except: [:new, :edit]
      end
    end

    # /anime/:id/episodes/:num
    resources "/media/anime", AnimeController, except: [:new, :edit] do
      resources "/episodes", EpisodeController, param: "num", except: [:new, :edit]
    end

    resources "/media/episodes", EpisodeController, except: [:new, :edit]
  end

end
