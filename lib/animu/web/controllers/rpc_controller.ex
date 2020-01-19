defmodule Animu.Web.RpcController do
  use Animu.Web, :controller

  action_fallback Animu.Web.FallbackController

  def rpc(conn, %{"augur" => %{"exec" => "scan"}}) do
    Augur.Scanner.scan
    render(conn, "rpc.json", success: true)
  end

end
