defmodule Dictionary.Runtime.Application do
  alias Dictionary.Runtime.Server
  use Application

  def start(_type, _args) do
    children = [
      {Server, []}
    ]

    options = [
      name: Dictionary.Runtime.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, options)
  end
end
