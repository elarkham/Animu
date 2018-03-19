defmodule Animu.Web.RpcController do
  use Animu.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Animu.Web.SessionController
  action_fallback Animu.Web.FallbackController

  def rpc(conn, %{"augur" => %{"exec" => "rebuild_cache"}}) do
    Augur.rebuild_cache()
    render(conn, "rpc.json", success: true)
  end

  def rpc(conn, %{"augur" => %{"exec" => "scan"}}) do
    Augur.Scanner.scan(Augur.cache)
    render(conn, "rpc.json", success: true)
  end
end
