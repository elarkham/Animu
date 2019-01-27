defmodule Animu.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :animu,
    error_handler: Animu.Auth.ErrorHandler,
    module: Animu.Auth.Guardian

  #plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader, realm: :none
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
