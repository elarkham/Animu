defmodule Owl do
  use Application

  def start(_,_) do
    Owl.Supervisor.start_link
  end

end
