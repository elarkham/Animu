defmodule Animu.Web.RpcView do
  use Animu.Web, :view

  def render("rpc.json", %{success: success}) do
    %{success: success}
  end

end
