defmodule Dictionary.Runtime.Application do
  alias Dictionary.Runtime.Server
  use Application

  def start(_type, _args) do
    Server.start_link()
  end
end
